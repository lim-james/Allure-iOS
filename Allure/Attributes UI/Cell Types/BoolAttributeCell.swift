//
//  BoolAttributeCell.swift
//  Allure
//
//  Created by James on 19/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class BoolAttributeCell: AttributeCell {
    
    override public var path: String! {
        didSet {
            if let label = label {
                label.text = path.Separate()
            }
            
            if let boolSwitch = boolSwitch {
                do {
                    let dictionary = try emitter.ToDictionary()
                    boolSwitch.isOn = dictionary[path] as! Bool
                } catch {
                    fatalError("Failed to convert to dictionary.")
                }
            }
        }
    }

    private var boolSwitch: UISwitch!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        boolSwitch = UISwitch()
        boolSwitch.addTarget(self, action: #selector(BoolAttributeCell.OnSwitch(_:)), for: .valueChanged)
        boolSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(boolSwitch)
        
        
        NSLayoutConstraint.activate([
            boolSwitch.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: yMargin),
            boolSwitch.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -yMargin),
            boolSwitch.leftAnchor.constraint(equalTo: label.rightAnchor, constant: spacing),
            boolSwitch.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin)
        ])
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        boolSwitch.setOn(!boolSwitch.isOn, animated: true)
        OnSwitch(boolSwitch)
    }
    
    @objc private func OnSwitch(_ target: UISwitch) {
        do {
            var dictionary = try emitter.ToDictionary()
            dictionary[path] = target.isOn
            emitter.Set(try emitter.Parse(from: dictionary))
        } catch {
            fatalError("Failed to convert to dictionary.")
        }
    }
    
}
