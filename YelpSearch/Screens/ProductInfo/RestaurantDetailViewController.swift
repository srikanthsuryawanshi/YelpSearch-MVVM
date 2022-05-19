//
//  RestaurantDetailViewController.swift
//  YelpSearch
//
//  Created by Srikanth SP on 29/03/22.
//

import Foundation
import UIKit


class RestaurantDetailViewController: UIViewController, Storyboarded{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var viewModel:RestaurantDetailViewModel!
    
    override func viewDidLoad() {
        viewModel.imagedUpdated = { [weak self] in
            guard let self = self, let image = self.viewModel.rawImage else { return }
            self.updateImage(image: image)
        }
        viewModel.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = viewModel.detail.name
        ratingLabel.text = viewModel.detail.starRatings
        addressLabel.text = viewModel.detail.address
        priceLabel.text = viewModel.detail.price
        phoneLabel.text = viewModel.detail.phone
        viewModel.loadImage()
        navigationItem.title = viewModel.detail.name

    }
    
    func updateImage(image:UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageView.image = image
        }
    }
}
