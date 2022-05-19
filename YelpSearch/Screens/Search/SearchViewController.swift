//
//  SearchViewController.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import UIKit
import IHProgressHUD

class SearchViewController: UIViewController,Storyboarded {

    var viewModel: SearchViewModel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Search"
        setupControls()
                
        viewModel.searchResultsUpdated = { [weak self] in
            guard let self = self else { return }
            self.refreshSearchList()
        }
        
        viewModel.loadStatusUpdated = {
            self.updateLoadingIndicator()
        }
        
        viewModel.networkError = {[weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.throwErrorAlert(title: "Error", text: error)
            }
        }
        viewModel.viewDidLoad()
    }
    
    func updateLoadingIndicator() {
        if viewModel.isLoading {
            IHProgressHUD.show()
        } else {
            IHProgressHUD.dismiss()
        }
    }
    
    func setupControls() {
        searchList.register(UITableViewCell.self, forCellReuseIdentifier: "restaurantSearchCell")
        searchBar.delegate = self
        searchList.delegate = self
        searchList.dataSource = self
        searchBar.text = " Search \(viewModel.currentSearchCategory.rawValue)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterTapped))
    }
    
    @objc private func filterTapped(sender: UIBarButtonItem) {
        print("FILTER TAPPED")
    }
    
    
    func refreshSearchList() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.searchList.reloadData()
            if self.viewModel.restaurants.isEmpty {
                self.throwEmptyAlert(title: "Search Result")
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            viewModel.searchRestaurants(text: text)
        }
    }
}

extension SearchViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = viewModel.searchResponse[indexPath.row]
        viewModel.coordinator.goToRestaurant(detail: detail)
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "restaurantSearchCell")

        let model = viewModel.restaurants[indexPath.row]
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = String(model.startRatings ?? "")
        return cell
    }
    
    
}
