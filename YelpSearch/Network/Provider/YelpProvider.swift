//
//  YelpProvider.swift
//  YelpSearch
//
//  Created by Srikanth SP on 01/04/22.
//

import Foundation


protocol YelpProviderContract {
    func nearByRestaurants(location: YelpLocation, completion:@escaping (Result<[RestaurantDetail]>) -> Void)
    func search(type: SearchByCategory, location: YelpLocation, text: String?, completion:@escaping (Result<[RestaurantDetail]>) -> Void)
    func restaurant(id: String, completion:@escaping (Result<RestaurantDetail>) -> Void)
}


class YelpProvider: YelpProviderContract {
    
    var serviceProvider = ServiceProvider<YelpService>()
    
    func handleNearbyRestaurants(response: SearchResponse) -> [RestaurantDetail] {
        var restaurantList = [RestaurantDetail]()
        if let restaurants =  response.businesses {
            for r in restaurants {
                if let id = r.id {
                    var detail = RestaurantDetail(id: id)
                    detail.name = r.name
                    detail.address = r.completeAddress()
                    detail.phone = r.phone
                    detail.price = r.price
                    detail.imageUrl = r.image_url
                    detail.ratings = r.rating
                    detail.starRatings = r.starRatings()
                    restaurantList.append(detail)
                }
            }
        }
        
        return restaurantList
    }
    
    func handleSearchResults(response: SearchResponse) -> [RestaurantDetail] {
        var searchResponse = [RestaurantDetail]()
        if let restaurants =  response.businesses {
            for r in restaurants {
                if let id = r.id {
                    //cache details
                    var detail = RestaurantDetail(id: id)
                    detail.name = r.name
                    detail.address = r.completeAddress()
                    detail.phone = r.phone
                    detail.price = r.price
                    detail.imageUrl = r.image_url
                    detail.ratings = r.rating
                    detail.starRatings = r.starRatings()
                    searchResponse.append(detail)
                }
            }
        }
        return searchResponse
    }
    
    
    func nearByRestaurants(location: YelpLocation, completion: @escaping (Result<[RestaurantDetail]> ) -> Void) {
        serviceProvider.load(service: .searchBy(location: location), decodeType: SearchResponse.self) { [weak self] result in
            guard let self = self else {
                print("Unexpected Error @ nearByRestaurants call")
                return
            }
            switch result {
            case .success(let response):
                return completion(.success(self.handleNearbyRestaurants(response: response)))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    
    func search(type: SearchByCategory, location: YelpLocation, text: String?, completion: @escaping (Result<[RestaurantDetail]>) -> Void) {
        var searchText = type.rawValue
        if let text = text {
            searchText = text
        }
        serviceProvider.load(service: .search(searchText: searchText, location: location), decodeType: SearchResponse.self) { [weak self] result in
            guard let self = self else {
                print("Unexpected Error @ search call")
                return
            }
            switch result {
            case .success(let response):
                return completion(.success(self.handleSearchResults(response: response)))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        
        

    }
    
    func restaurant(id: String, completion: @escaping (Result<RestaurantDetail>) -> Void) {
        //not needed now
    }
    
}
