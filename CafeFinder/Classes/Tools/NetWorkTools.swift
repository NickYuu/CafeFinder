//
//  NetWorkTool.swift
//  Alamofire_SwiftyJSON
//
//  Created by YU on 2017/1/3.
//  Copyright © 2017年 YU. All rights reserved.
//

import UIKit
import Alamofire

class NetworkTools {
    private init() {}
    static let `default` = NetworkTools()
}

extension NetworkTools {
    func requestJson(methodType: HTTPMethod = .get, urlString: String, parameters: [String : AnyObject]?, finished:@escaping (_ result: AnyObject?, _ error: Error?) -> ()) {
        
        let resultCallBack = { (response: DataResponse<Any>) in
            if response.result.isSuccess {
                finished(response.result.value as AnyObject?, nil)
            } else {
                finished(nil, response.result.error)
            }
        }
        
        let httpMethod: HTTPMethod = methodType
        request(urlString, method: httpMethod, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: resultCallBack)
    }
    
    func requestData(methodType: HTTPMethod = .get, urlString: String, parameters: [String : AnyObject]?, finished:@escaping (_ result: AnyObject?, _ error: Error?) -> ()) {
        
        let resultCallBack = { (response: DataResponse<Data>) in
            if response.result.isSuccess {
                finished(response.result.value as AnyObject?, nil)
            } else {
                finished(nil, response.result.error)
            }
        }
        
        let httpMethod: HTTPMethod = methodType
        request(urlString, method: httpMethod, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: resultCallBack)
        
    }
    
    
    
    
}
