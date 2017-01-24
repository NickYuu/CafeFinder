//
//  MainViewController.swift
//  CafeFinder
//
//  Created by Tsung Han Yu on 2017/1/24.
//  Copyright © 2017年 Tsung Han Yu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadData { (json, error) in
            guard error == nil      else { return }
            guard let json = json   else { return }

            print(json.arrayValue)
            
        }
        
    }
    

}


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
