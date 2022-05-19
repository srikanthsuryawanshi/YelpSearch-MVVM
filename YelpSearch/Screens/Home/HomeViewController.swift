//
//  HomeViewController.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import UIKit
import IHProgressHUD

class HomeViewController: UIViewController,Storyboarded {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel:HomeViewModel!
    let headerId = "headerId"
    let categoryHeaderId = "categoryHeaderId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Yelp"

        setupCollectionView()
        
        viewModel.locationUpdated = { [weak self] in
            //location updated - fetch new location
            guard let self = self else { return }
            self.updateLocationLabel()
        }
        
        viewModel.nearbyRestaurantsUpdated = { [weak self] in
            guard let self = self else { return }
            //refresh table
            self.refreshNearbySection()
        }
        
        viewModel.loadStatusUpdated = {
            self.updateLoadingIndicator()
        }
        
        viewModel.handlError = { [weak self]  error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.throwErrorAlert(title: "Error", text: error)
            }
        }
        
        viewModel.collectionSectionsUpdated = {
            self.collectionView.reloadData()
        }
        
        viewModel.findCurrentLocation()
        // Do any additional setup after loading the view.
    }
    
    
    func updateLoadingIndicator() {
        if viewModel.isLoading {
            IHProgressHUD.show()
        } else {
            IHProgressHUD.dismiss()
        }
    }
    
    
    func refreshNearbySection() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.viewModel.currentSectionStyle == .Online {
                self.collectionView.performBatchUpdates({
                    let indexSet = IndexSet(integer: 1)
                    self.collectionView.reloadSections(indexSet)
                }, completion: nil)
                
                if self.viewModel.nearByRestaurantCollection.isEmpty {
                    self.throwEmptyAlert(title: "Alert")
                }
            }
           
        }
    }
    
    func updateLocationLabel(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.locationLabel.text = self.viewModel.locationLabel()
        }
    }
    
    func setupCollectionView() {
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: categoryHeaderId, withReuseIdentifier: headerId)

        collectionView.register(SearchByCollectionCell.self, forCellWithReuseIdentifier: SearchByCollectionCell.reuseIdentifer)
        
        collectionView.register(RestaurantCollectionCell.self, forCellWithReuseIdentifier: RestaurantCollectionCell.reuseIdentifer)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            switch sectionNumber {
            case 0: return  (self.viewModel.currentSectionStyle == .Offline) ? self.recentVisitsLayoutSection() : self.searchByLayoutSection()
            default: return self.nearByRestaurantLayoutSection()
            }
        }
    }
    
    private func searchByLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.bottom = 15
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.3))//0.5
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 2)
       
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets.leading = 15

        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment: .top)
        ]
        return section
    }
    
    private func nearByRestaurantLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(500))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = 15
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment: .top)
        ]
        
        return section
    }
    
    private func recentVisitsLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(150))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 15, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(800))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = 15
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: categoryHeaderId, alignment: .top)
        ]
        
        return section
    }
    
    
    private func nearByCell(indexPath: IndexPath) -> RestaurantCollectionCell {
        let restaurantCell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantCollectionCell.reuseIdentifer, for: indexPath) as! RestaurantCollectionCell
        
        let cellModel = viewModel.nearByRestaurantCollection[indexPath.row]
        
        restaurantCell.configure(withImageName: cellModel.imageName, title: cellModel.title, stars: cellModel.starRatings)
        return restaurantCell
    }
    
    private func searchByCell(indexPath: IndexPath) -> SearchByCollectionCell {
        let searchBycell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchByCollectionCell.reuseIdentifer, for: indexPath) as! SearchByCollectionCell
        searchBycell.configure(title: viewModel.searchByCollectionItems[indexPath.row].title)
        return searchBycell
    }
    
    private func recentVisitCell(indexPath: IndexPath) -> RestaurantCollectionCell {
        let restaurantCell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantCollectionCell.reuseIdentifer, for: indexPath) as! RestaurantCollectionCell

        let cellModel = viewModel.recentVisitCells[indexPath.row]

        restaurantCell.configure(withImageName: cellModel.imageName, title: cellModel.title, stars: cellModel.starRatings)
        return restaurantCell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return viewModel.sectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if viewModel.currentSectionStyle == .Offline { // offline mode
            return viewModel.recentVisitCells.count
        } else { //online mode
            switch section {
                case 0:
                return viewModel.searchByCollectionItems.count
                case 1:
                return viewModel.nearByRestaurantCollection.count
                default:
                    return 1
            }
        }        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if viewModel.currentSectionStyle == .Offline { // offline mode
            return recentVisitCell(indexPath: indexPath)
        } else {
            if indexPath.section == 0 {
                return searchByCell(indexPath: indexPath)
            } else {
                return nearByCell(indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! CategoryHeaderView
        header.label.text = viewModel.sectionTitles[indexPath.section]
        return header
    }
    

}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if viewModel.currentSectionStyle == .Offline { // offline mode
            let restaurant = viewModel.recentVisitRestaurants[indexPath.row]
            viewModel.coordinator.goToRestaurant(detail: restaurant)
        } else {
            if indexPath.section == 0 {
                let category = viewModel.searchByCollectionItems[indexPath.row].type
                viewModel.showSearchScreen(category: category)
            } else if indexPath.section == 1 {
                let restaurant = viewModel.nearByResponse[indexPath.row]
                viewModel.showRestaurantDetailScreen(detail: restaurant)
            }
        }
    }
}
