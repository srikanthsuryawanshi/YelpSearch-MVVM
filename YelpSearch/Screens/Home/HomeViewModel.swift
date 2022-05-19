//
//  HomeViewModel.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import Foundation


enum HomeScreenSection: String {
    case SearchBy = "SearchBy"
    case NearBy = "Near by restaurants"
    case RecentVisits = "Recent Visits"
}

enum SearchByCategory:String {
    case FoodType = "Food"
    case RestaurantType = "Restaurant"
}

struct SearchByCategoryCellModel {
    var title: String
    var type: SearchByCategory
    init(title:String, category:SearchByCategory = .FoodType) {
        self.type = category
        self.title = title
    }
}

struct RestaurantCellModel {
    var title: String?
    var imageName: String?
    var id:String?
    var starRatings:String?
}

enum SectionStyle {
    case Online,Offline
}

class HomeViewModel {
    
    weak var coordinator : AppCoordinator!
    var currentSectionStyle = SectionStyle.Online

    lazy var searchByCollectionItems:[SearchByCategoryCellModel] = {
        let foodCategory =  SearchByCategoryCellModel(title: "Food")
        let restaurantCategory =  SearchByCategoryCellModel(title: "Restaurant", category: .RestaurantType)
        return [foodCategory,restaurantCategory]
    }()
    
    var nearByRestaurantCollection = [RestaurantCellModel]()
    var nearByResponse = [RestaurantDetail]()
    
    var recentVisitCells = [RestaurantCellModel]()
    var recentVisitRestaurants = [RestaurantDetail]()
    
    var locationService:LocationServiceProtocol!
    private var currentLocation: YelpLocation?
    
    var isNetworkConnected = false
    
    //updates to view
    var locationUpdated:(() -> Void)?
    var nearbyRestaurantsUpdated:(() -> Void)?
    var collectionSectionsUpdated:(() -> Void)?
    var handlError:((String)->Void)?
    
    var yelpProvider: YelpProviderContract!
    var offlineProvider:PersistenceProtocol!
    var reachability: ReachabilityProtocol!
    var googleProvider: PositionProviderContract!
    
    var isLoading = false {
        didSet {
            loadStatusUpdated?()
        }
    }
    var loadStatusUpdated: (()->Void)?
    
    
    var sectionTitles: [String] {
        self.sections(isNetworkAvailable: isNetworkConnected)
    }
        
    func setupObservers() {
        initialSetup()
        locationService.delegate = self
    }
    
    
    func initialSetup() {
        reachability.observeNetworkChange {[weak self] isConnected in
            guard let self = self else { return }
            self.handleNetworkChange(isConnected: isConnected)
        }
        
        isNetworkConnected = reachability.isNetworkConnected()
        if isNetworkConnected {
            setupOnlineMode()
        } else {
            setupOfflineMode()
        }
    }
    
    func setupOfflineMode() {
        currentSectionStyle = .Offline
        loadRecentVisits()
        collectionSectionsUpdated?()
    }
    
    func setupOnlineMode() {
        currentSectionStyle = .Online
        collectionSectionsUpdated?()
        findNearbyRestaurants()
        if let currentLocation = currentLocation {
            fetchLocationName(location: currentLocation) { [self] result in
                switch result {
                case .success(let name):
                    self.currentLocation?.name = name
                    locationUpdated?()
                case .failure( _):
                    break
                }
            }
        }
    }
    
    func locationLabel() -> String {
        var label = ""
        if let name = currentLocation?.name {
            if name.count > 15 {
                let splits = name.split(separator: ",")
                if let first = splits.first {
                    label = String(first)
                }
            }
        }
        return label
    }
    
    func showRestaurantDetailScreen(detail:RestaurantDetail) {
        coordinator.goToRestaurant(detail: detail)
    }
    
    func showSearchScreen(category: SearchByCategory) {
        if let loc =  currentLocation {
            coordinator.goToSearch(location: loc, searchType: category)
        }
    }
    
    private func loadRecentVisits() {
        recentVisitCells = []
        recentVisitRestaurants = CoreController.shared.recentVisits()
        recentVisitRestaurants.forEach { detail in
            let restaurantCell = RestaurantCellModel(title: detail.name ?? "DEFAULT", imageName: detail.imageUrl, id: detail.id, starRatings: detail.starRatings)
            recentVisitCells.append(restaurantCell)
        }
        
        if recentVisitRestaurants.count == 0 {
            self.handlError?("No Recent visits found")
        }
    }
    private func sections(isNetworkAvailable: Bool) -> [String] {
        var sections = [String]()
        
        if isNetworkAvailable {
            sections.append(HomeScreenSection.SearchBy.rawValue)
            sections.append(HomeScreenSection.NearBy.rawValue)
        } else {
            sections.append(HomeScreenSection.RecentVisits.rawValue)
        }
        return sections
    }
    
    
    func handleNetworkChange(isConnected: Bool) {
        guard isNetworkConnected != isConnected else { return }
        isNetworkConnected = isConnected
        if isConnected {
            // load sections
            //fetch online data
            setupOnlineMode()
        } else {
            // load sections - recent visits
            // fetch offline data
            setupOfflineMode()
        }
        
    }
    
    func findCurrentLocation() {
        locationService.fetchCurrentLocation()
    }
    
    private func findNearbyRestaurants() {
        if let location = currentLocation {
            isLoading = true
            yelpProvider.nearByRestaurants(location: location) { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success( let restaurantList):
                    self.nearByResponse = restaurantList
                    restaurantList.forEach { r in
                        var restoCellModel = RestaurantCellModel(title: r.name, imageName: r.imageUrl, id: r.id )
                        restoCellModel.starRatings = r.starRatings
                        self.nearByRestaurantCollection.append(restoCellModel)
                    }
                    self.nearbyRestaurantsUpdated?()
                case .failure(let error):
                    //throw error dialog
//                    self.nearByResponse = []
//                    self.nearByRestaurantCollection = []
//                    self.nearbyRestaurantsUpdated?()
                    self.handlError?(error.localizedDescription)
                }
                
            }
        }
    }
    
    func fetchLocationName(location: YelpLocation, completionHandler:@escaping (_ result: Result<String>)-> Void ) {
        googleProvider.reverseGeocode(location: location, completion: completionHandler)
    }

    
}

extension HomeViewModel: LocationServiceDelegate {
    func didUpdateLocation(location: YelpLocation) {
        currentLocation = location
        
        //fetch nearby
        if isNetworkConnected {
            self.findNearbyRestaurants()
            fetchLocationName(location: location) { [self] result in
                switch result {
                case .success(let name):
                    self.currentLocation?.name = name
                    locationUpdated?()
                case .failure( _):
                    break
                }
            }
        }
    }
}
