//
//  AttributeCell.swift
//  Allure
//
//  Created by James on 22/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class AttributeCell: UITableViewCell {
    
    public var emitter: ParticleEmitter!
    public var path: String! {
        didSet {
            if let label = label {
                label.text = path.Separate()
            }
        }
    }
    
    public var yMargin: CGFloat!
    public var xMargin: CGFloat!
    public var spacing: CGFloat!
    
    public var overlay: UIView!
    public var overlayRight: NSLayoutConstraint!
    
    public var label: UILabel!
    public var labelBottom: NSLayoutConstraint!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        yMargin = 8.0
        xMargin = 0.0
        spacing = 16.0
        
        overlay = UIView()
        overlay.backgroundColor = .systemGray
        overlay.alpha = 0
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        
        overlayRight = overlay.rightAnchor.constraint(equalTo: rightAnchor)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leftAnchor.constraint(equalTo: leftAnchor),
            overlayRight
        ])
        
        label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        labelBottom = label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -yMargin)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: yMargin),
            labelBottom,
            label.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: xMargin)
        ])
    }
}
