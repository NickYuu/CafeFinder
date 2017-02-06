//
//  MainViewController.swift
//  CafeFinder
//
//  Created by Tsung Han Yu on 2017/1/24.
//  Copyright © 2017年 Tsung Han Yu. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MainViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let clusteringManager = FBClusteringManager()
    var Shops: [Cafe] = []
    var array:[FBAnnotation] = []
    var isFirstGetLocation = false
    var currentLocation: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLocation()
        
        loadData { [weak self](json, error) in
            guard error == nil      else { return }
            guard let json = json   else { return }
            self?.Shops = json.arrayValue.map{Cafe(json: $0)}
            _ = self?.Shops.map{
                let annotation = FBAnnotation()
                annotation.title = $0.name
                annotation.coordinate = $0.coordinate
                annotation.cafe = $0
                self?.array.append(annotation)
            }
            self?.clusteringManager.add(annotations: self!.array)
            
        }
        
    }
    

}

// MARK: - Helper
extension MainViewController {
    func requestLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            present( alertController, animated: true, completion: nil)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}


// MARK: - Network
extension MainViewController {
    
    var netTool: NetworkTools { return .default }
    var urlString: String {
        return "https://cafenomad.tw/api/v1.0/cafes"
    }
    var parameters: [String:AnyObject]? {
        return nil
    }
    
    func loadData(finished:@escaping (_ result: JSON?, _ error: Error?) -> ()) {
        DispatchQueue.global().async { [weak self] in
            self?.netTool.requestJson(urlString: (self?.urlString)!, parameters: self?.parameters) { (result, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        finished(nil, error!)
                    }
                    return
                }
                guard let result = result else { return }
                let json = JSON(result)
                DispatchQueue.main.async {
                    finished(json, nil)
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    
    // 顯示使用者目前位置
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.isFirstGetLocation == false {
            isFirstGetLocation = true
            currentLocation = userLocation.location
            let region = MKCoordinateRegion(center: userLocation.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            mapView.region = region
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale: scale)
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView: mapView)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            (annotation as! MKUserLocation).title = ""
            return nil
        }
        var reuseId = ""
        if annotation is FBAnnotationCluster {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                
                clusterView =  FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.default())
            } else {
                clusterView?.annotation = annotation
            }
            return clusterView
        } else {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.pinTintColor = UIColor.green
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        }
    }
    
}
