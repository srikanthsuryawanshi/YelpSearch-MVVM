//
//  SearchViewModel.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import Foundation


struct SearchListCellModel {
    var title: String?
    var id: String?
    var rating:Double = 0.0
    var startRatings:String?
}

class SearchViewModel {
    
    weak var coordinator : AppCoordinator!

    var restaurants = [SearchListCellModel]()
    
    var searchResultsUpdated:(() -> Void)?
    var networkError:((String)->Void)?

    var provider: YelpProviderContract!
    
    var currentLocation: YelpLocation!
    
    var currentSearchCategory: SearchByCategory!
    
    var searchResponse = [RestaurantDetail]()
    
    var isLoading = false {
        didSet {
            loadStatusUpdated?()
        }
    }
    var loadStatusUpdated: (()->Void)?
    var reachability: ReachabilityProtocol!

    func viewDidLoad() {
        searchRestaurantsByCategory()
    }
    
    func setupObservers() {
        reachability.observeNetworkChange {[weak self] isConnected in
            guard let self = self else { return }
            self.handleNetworkChange(isConnected: isConnected)
        }
    }
    
    func handleNetworkChange(isConnected: Bool) {
        //PENDING
    }
    
    private func searchRestaurantsByCategory() {
        loadRestaurants(text: nil)
    }

    func searchRestaurants(text: String) {
        if text.count > 3 {
            loadRestaurants(text: text)
        }
    }
    
    private func loadRestaurants(text:String?) {
        isLoading = true
        provider.search(type: currentSearchCategory, location: currentLocation, text: text) { [weak self] result in
            guard let self = self else {
                print("Unexpected Error")
                return
            }
            self.isLoading = false
            switch result {
            case .success(let restaurantList):
                self.searchResponse = restaurantList
                self.restaurants = []
                restaurantList.forEach { r in
                    var cellModel = SearchListCellModel(title: r.name, id: r.id, rating: r.ratings)
                    cellModel.startRatings = r.starRatings
                    self.restaurants.append(cellModel)
                }
                self.searchResultsUpdated?()
            case .failure(let error):
                self.networkError?(error.localizedDescription)
//                self.restaurants = []
//                self.searchResponse = []
//                self.searchResultsUpdated?()
            }
        }
    }
    
    func showRestaurant(detail: RestaurantDetail) {
        coordinator.goToRestaurant(detail: detail)
    }
}
