//
//  RestaurantDetailViewModel.swift
//  YelpSearch
//
//  Created by Srikanth SP on 29/03/22.
//

import Foundation
import UIKit
import SDWebImage


struct RestaurantDetail {
    var name: String?
    var ratings: Double = 0.0
    var phone: String?
    var price: String?
    var address: String?
    var imageUrl: String?
    var id: String
    var starRatings: String?
}

class RestaurantDetailViewModel {
    var detail: RestaurantDetail!
    weak var coordinator : AppCoordinator!
    
    var rawImage: UIImage?
    var imagedUpdated:(()-> Void)?
    
    var provider = ServiceProvider<YelpService>()
    
    var downloader:SDWebImageDownloader = .shared

    let store = CoreController.shared
    
    func viewDidLoad() {
        saveResturantVisit(restaurant: detail)
    }
    
    func loadImage() {
        if let urlStr = detail.imageUrl, let url =  URL(string: urlStr) {
            downloader.downloadImage(with: url) { [weak self] image, data, error, isFinished in
                if let self = self,
                   isFinished,
                   error == nil,
                   let image = image {
                    self.rawImage = image
                    self.imagedUpdated?()
                }
            }
        }
    }
    
    func saveResturantVisit(restaurant: RestaurantDetail) {
        store.save(restaurant: restaurant)
    }
}
