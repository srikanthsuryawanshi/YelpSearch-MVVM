//
//  PositionProvider.swift
//  YelpSearch
//
//  Created by Srikanth SP on 13/05/22.
//

import Foundation

enum PositionError: Error {
    case InvalidLatLong
    case NoLocationNameFound
}

protocol PositionProviderContract {
    func reverseGeocode(location: YelpLocation, completion:@escaping (Result<String>) -> Void)
}

class PositionProvider: PositionProviderContract {
    var serviceProvider = ServiceProvider<PositionStackService>()
    
    func reverseGeocode(location: YelpLocation, completion: @escaping (Result<String>) -> Void) {
        
        serviceProvider.load(service: .reverseGeoCode(lat: location.latitude, long: location.longitude), decodeType: PositionResponse.self) { result in
            switch result {
            case .success(let response):
                
                if let name = response.data.first?.label {
                    return completion(.success(name))
                }
                return completion(.failure(PositionError.NoLocationNameFound))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
}
