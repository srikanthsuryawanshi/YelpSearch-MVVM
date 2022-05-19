//
//  RestaurantCollectionCell.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import Foundation
import UIKit


class RestaurantCollectionCell: UICollectionViewCell {
    static let reuseIdentifer = "restaurant-cell-reuse-identifier"
    let featuredPhotoView = UIImageView()
    var titleLabel =  UILabel()
    var viewStack = UIStackView()
    var ratingLabel = UILabel()
      
      override init(frame: CGRect) {
          
          super.init(frame: frame)
          
          viewStack.axis = .vertical
          viewStack.alignment = .center
          
          ratingLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.bounds.width - 20 , height: 20))
          ratingLabel.numberOfLines = 1
          ratingLabel.textAlignment = .right
          ratingLabel.translatesAutoresizingMaskIntoConstraints = false
          viewStack.addArrangedSubview(ratingLabel)

          
          featuredPhotoView.layer.cornerRadius = 10
          featuredPhotoView.layer.masksToBounds = true
          featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
          viewStack.addArrangedSubview(featuredPhotoView)
          
          titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.bounds.width - 20 , height: 20))
          titleLabel.numberOfLines = 2
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          viewStack.addArrangedSubview(titleLabel)

          viewStack.translatesAutoresizingMaskIntoConstraints = false
          contentView.addSubview(viewStack)
          
          contentView.layer.borderWidth = 2
          contentView.layer.borderColor = UIColor.black.cgColor
          
            NSLayoutConstraint.activate([
              viewStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
              viewStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
              viewStack.topAnchor.constraint(equalTo: contentView.topAnchor),
              viewStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
      }

      required init?(coder: NSCoder) {
          
          fatalError("init(coder:) has not been implemented")
      }
      
    func configure(withImageName name: String?, title: String?, stars:String?) {
        ratingLabel.text = stars
        titleLabel.text = title
        let placeHolderImage =  UIImage(named: "sampleRestro")
        featuredPhotoView.image = placeHolderImage
        if let name = name, let url = URL(string: name) {
            featuredPhotoView.sd_setImage(with: url, completed: nil)
        }
        
      }
}
