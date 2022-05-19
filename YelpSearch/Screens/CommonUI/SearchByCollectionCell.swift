//
//  SearchByCollectionCell.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import Foundation
import UIKit

class SearchByCollectionCell: UICollectionViewCell {
    static let reuseIdentifer = "search-by-cell-reuse-identifier"
    var viewStack = UIStackView()
    var titleLabel = UILabel()

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        viewStack.axis = .vertical
        viewStack.alignment = .center
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
    
    func configure(title: String) {
            titleLabel.text = title
    }

}
