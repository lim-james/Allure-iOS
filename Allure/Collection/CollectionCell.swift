//
//  CollectionCell.swift
//  Allure
//
//  Created by James on 2/4/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    public var titleLabel: UILabel!
    
    public var primaryColor: UIColor! {
        didSet {
            gradient.colors![0] = primaryColor.cgColor
        }
    }
    
    public var secondaryColor: UIColor! {
        didSet {
            gradient.colors![1] = secondaryColor.cgColor
        }
    }
    
    private var gradient: CAGradientLayer!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 20
        clipsToBounds = true
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.text = "The Apple logo"
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 2.0, weight: .heavy)
        titleLabel.textColor = .systemBackground
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
        
        gradient = CAGradientLayer()
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        
        contentView.layer.insertSublayer(gradient, at: 0)
        gradient.colors = [UIColor.darkText.cgColor, UIColor.darkText.cgColor]
    }
    
}
