//
//  CategoryCell.swift
//  RealmBudget
//
//  Created by Lucas on 3/19/17.
//  Copyright © 2017 Lucas. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var category: Category? {
        didSet {
            nameLabel.text = category?.name
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    
    func setupView() {
        addSubview(nameLabel)
        addConstraintsWithFormat("H:|-8-[v0]-8-|", views: nameLabel)
        addConstraintsWithFormat("H:|-8-[v0]-8-|", views: nameLabel)
    }
}
