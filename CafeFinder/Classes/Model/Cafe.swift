//
//  Cafe.swift
//  CafeFinder
//
//  Created by Tsung Han Yu on 2017/1/25.
//  Copyright © 2017年 Tsung Han Yu. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation

open class Cafe: NSObject {
    var id          : String?
    var name        : String?
    var city        : String?
    var wifi        : Int = 0
    var seat        : Int = 0
    var quiet       : Int = 0
    var tasty       : Int = 0
    var cheap       : Int = 0
    var music       : Int = 0
    var url         : String?
    var address     : String?
    var coordinate  : CLLocationCoordinate2D!
    var annotation  :FBAnnotation {
        let pa = FBAnnotation()
        pa.title = name
        pa.coordinate = coordinate
        return pa
    }
    
    init(json: JSON) {
        id      = json["id"].string
        name    = json["name"].string
        city    = json["city"].string
        wifi    = json["wifi"].int ?? 0
        seat    = json["seat"].int ?? 0
        quiet   = json["quiet"].int ?? 0
        tasty   = json["tasty"].int ?? 0
        cheap   = json["cheap"].int ?? 0
        music   = json["music"].int ?? 0
        url     = json["url"].string
        address = json["address"].string
        
        coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(json["latitude"].stringValue)!, CLLocationDegrees(json["longitude"].stringValue)!)
        
    }
    
}
