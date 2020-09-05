//
//  AddCell.swift
//  Allure
//
//  Created by James on 2/4/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class AddCell: UICollectionViewCell {
    
    private var overlay: UIView!
    private var icon: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let window = UIApplication.shared.windows[0]
        
        layer.cornerRadius = 20
        layer.borderWidth = 5
        layer.borderColor = window.tintColor.cgColor
        clipsToBounds = true
        
        overlay = UIView()
        overlay.backgroundColor = window.tintColor
        overlay.alpha = 0
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        
        NSLayoutConstraint.FillBounds(child: overlay, parent: self)
        
        icon = UIImageView()
        icon.image = UIImage(systemName: "plus")
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor)
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.25) {
            self.overlay.alpha = 0.5
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.25) {
            self.overlay.alpha = 0
        }
    }
    
}
