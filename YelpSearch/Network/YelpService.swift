//
//  YelpService.swift
//  YelpSearch
//
//  Created by Srikanth SP on 23/03/22.
//

import Foundation

enum YelpService {
    case search(searchText: String, location: YelpLocation)
    case searchBy(location:YelpLocation)
    case productInfo(restaurantId: String)
}

let Yelp_API_KEY = "rqL4ykq-m82360jzzoczMQU3PgA-NF-ttODOHXw5BIe_NDnnMwpqbKdJ72Vh0S2d5WDG25apoWddEAEE6i_6pnXUgJ-w6-fl7U0Vvg41aP4YrpylQT89hHC3QrNBYnYx"

extension YelpService: Service {
    var baseURL: String {
        return "https://api.yelp.com"
    }

    var path: String {
        switch self {
        case .search(searchText: _, location: _):
            return "/v3/businesses/search"
        case .searchBy(location: _):
            return "/v3/businesses/search"
        case .productInfo(restaurantId: let restaurantId):
            return "v3/businesses/\(restaurantId)"
        }
    }

    var parameters: [String: String]? {
        // default params
        var params = [String: String]()
        params["radius"] = "40000"

        switch self {
        case .search(searchText: let searchText, location: let location):
            params["term"] = searchText
            params["latitude"] = String(location.latitude)
            params["longitude"] = String(location.longitude)
            
        case .searchBy(location: let location):
            params["radius"] = "40000"
            params["latitude"] = String(location.latitude)
            params["longitude"] = String(location.longitude)
            
        case .productInfo(restaurantId: _):  break
        }
        return params
    }

    var method: ServiceMethod {
        return .get
    }
    
    var urlRequest: URLRequest {
        guard let url = self.url else {
            fatalError("URL could not be built")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        let bearerValue = "Bearer \(Yelp_API_KEY)"
        request.addValue(bearerValue, forHTTPHeaderField: "Authorization")
        return request
    }
}
