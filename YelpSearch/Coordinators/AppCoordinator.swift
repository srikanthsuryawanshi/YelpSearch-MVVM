//
//  AppCoordinator.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import UIKit

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController : UINavigationController { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    let appDelegate =  UIApplication.shared.delegate as! AppDelegate
    init(navCon : UINavigationController) {
        self.navigationController = navCon
        let _ = Reachability.shared
    }
    
    func start() {
        print("App Coordinator Start")
        goToHome()
    }
    
    
    func goToHome() {
        //Instantiate View Controller
        let homeVC =  HomeViewController.instantiate()
        //ViewModel
        guard let homeViewModel = appDelegate.container.resolve(HomeViewModel.self),
              let yelpProvider = appDelegate.container.resolve(YelpProvider.self),
              let locationService = appDelegate.container.resolve(LocationService.self),
              let googleProvider = appDelegate.container.resolve(PositionProvider.self)
        else  {
            return
        }
        //set coordinator
        homeViewModel.coordinator = self
        homeViewModel.yelpProvider = yelpProvider
        homeViewModel.googleProvider = googleProvider
        homeViewModel.locationService = locationService
        homeViewModel.reachability = Reachability.shared
        homeViewModel.setupObservers()
        //set viewmodel to viewcontroller
        homeVC.viewModel = homeViewModel
        //push it
        navigationController.pushViewController(homeVC, animated: true)
    }

    func goToSearch(location: YelpLocation, searchType: SearchByCategory ) {
        
        // Instantiate
        let searchVC =  SearchViewController.instantiate()
        
        guard let searchViewModel = appDelegate.container.resolve(SearchViewModel.self),
              let yelpProvider = appDelegate.container.resolve(YelpProvider.self)
        else  {
            return
        }
        searchViewModel.provider = yelpProvider
        searchViewModel.reachability = Reachability.shared
        searchViewModel.setupObservers()
        searchViewModel.currentLocation = location
        searchViewModel.currentSearchCategory = searchType

        // Set the Coordinator to the ViewModel
        searchViewModel.coordinator = self
        // Set the ViewModel to ViewController
        searchVC.viewModel = searchViewModel
        // Push it.
        navigationController.pushViewController(searchVC, animated: true)
        
        
    }
    
    func goToRestaurant(detail:RestaurantDetail) {
        //Instantiate
        let restaurantDetailVC = RestaurantDetailViewController.instantiate()
        //viewModel
        guard let restaurantDetailViewModel = appDelegate.container.resolve(RestaurantDetailViewModel.self)
        else  {
            return
        }
        // set detail
        restaurantDetailViewModel.detail = detail
        
        //set coordinator
        restaurantDetailViewModel.coordinator = self
        restaurantDetailVC.viewModel = restaurantDetailViewModel
        //push
        navigationController.pushViewController(restaurantDetailVC, animated: true)
    }
    
}

