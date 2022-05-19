//
//  CategoryHeaderView.swift
//  YelpSearch
//
//  Created by Srikanth SP on 22/03/22.
//

import UIKit


class CategoryHeaderView: UICollectionReusableView {
    
    var label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Section Title"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
