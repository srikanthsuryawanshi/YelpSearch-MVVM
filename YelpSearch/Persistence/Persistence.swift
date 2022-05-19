//
//  Persistence.swift
//  YelpSearch
//
//  Created by Srikanth SP on 28/03/22.
//

import Foundation


protocol PersistenceProtocol {
    func save(restaurant: RestaurantDetail)
    func recentVisits() -> [RestaurantDetail]
}





