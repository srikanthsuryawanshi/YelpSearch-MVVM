//
//  SearchResponse.swift
//  YelpSearch
//
//  Created by Srikanth SP on 28/03/22.
//

import Foundation

struct SearchResponse: Codable {
    var total = 0
    var businesses: [Restaurant]?
}


struct Restaurant: Codable {
    var rating:Double = 0.0
    var price: String?
    var phone: String?
    var id: String?
    var alias: String?
    var is_closed: Bool = true
    var categories: [Category]?
    var review_count = 0
    var name: String?
    var url:String?
    var coordinates: RestoCoordinate?
    var image_url: String?
    var location: RestoLocation?
    var distance:Double = 0.0 // returns meters
    var transactions:[String]?
    
    func completeAddress() -> String {
        var complete = ""
        if let address =  location?.address1 {
            complete.append(address)
            complete.append(", \n")

        } else if let add2 = location?.address2 {
            complete.append(add2)
            complete.append(", \n")

        } else if let add3 = location?.address3 {
            complete.append(add3)
            complete.append(", \n")
        }
        
        if let city  =  location?.city {
            complete.append(city)
            complete.append(", ")
        }
        
        if let state  =  location?.state {
            complete.append(state)
            complete.append(", \n")
        }
        
        if let country  =  location?.country {
            complete.append(country)
            complete.append(", ")

        }
        
        if let zip  =  location?.zip_code {
            complete.append(zip)
        }
        return complete
    }
    
    func starRatings() -> String {
        guard rating != 0 else { return  ""}
        
        var starRating = ""
        let fullStars = Int(rating)
        for _ in 1...fullStars {
            starRating.append(star)
        }
        if Double(fullStars) < rating {
            starRating.append(halfStar)
            starRating.append("(\(rating))")
        }
        return starRating
    }
}


struct Category: Codable {
    var alias: String?
    var title: String?
}

struct RestoCoordinate: Codable {
    var latitude:Double = 0.0
    var longitude:Double = 0.0
}

struct RestoLocation:Codable {
    var city: String?
    var country: String?
    var address1: String?
    var address2: String?
    var address3: String?
    var state: String?
    var zip_code:String?
}
