//
//  PositionStackService.swift
//  YelpSearch
//
//  Created by Srikanth SP on 13/05/22.
//

import Foundation


enum PositionStackService {
    case reverseGeoCode(lat:Double, long: Double)
}

let PositionStackAPIkey = "2bb040387e46a33f4c1a0473b6569faf"


extension PositionStackService: Service {
    
    var baseURL: String {
        return "http://api.positionstack.com"
    }
        
    var path: String {
        switch self {
        case .reverseGeoCode(lat: _, long: _) :
            return "/v1/reverse"
        }
    }
    
    var parameters: [String: String]? {
        var params = [String: String]()
        switch self {
        case .reverseGeoCode(let lat, let long):
        params["limit"] = "1"
        params["output"] = "json"
        params["query"] = "\(lat),\(long)"
        params["fields"] = "results.label"
        }
        
        params["access_key"] =  PositionStackAPIkey

        return params
    }
    
    var method: ServiceMethod {
        return .get
    }
    
    var urlRequest: URLRequest {
        return defaultUrlRequest
    }
    
}
