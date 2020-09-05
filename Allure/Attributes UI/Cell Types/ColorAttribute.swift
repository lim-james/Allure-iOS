//
//  ColorAttribute.swift
//  Allure
//
//  Created by James on 22/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit
import simd

class ColorAttributeCell: AttributeCell {
    
    override public var path: String! {
        didSet {
            if let label = label {
                label.text = path.Separate()
            }
             
            do {
                let dictionary = try emitter.ToDictionary()
                let data = dictionary[path] as! [Float]
                
                for i in 0...3 {
                    sliders[i].value = data[i]
                }

                preview.backgroundColor = UIColor(
                    red: CGFloat(data[0]),
                    green: CGFloat(data[1]),
                    blue: CGFloat(data[2]),
                    alpha: CGFloat(data[3])
                )
            } catch {
                fatalError("Failed to convert to dictionary.")
            }
        }
    }
    
    private var preview: UIView!
    private var sliders: [UISlider]!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        removeConstraint(labelBottom)
        
        spacing = 4
        
        preview = UIView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(preview)
        
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: yMargin),
            preview.leftAnchor.constraint(equalTo: label.rightAnchor, constant: spacing),
            preview.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin),
            preview.widthAnchor.constraint(equalTo: preview.heightAnchor, multiplier: 16.0 / 9.0),
            preview.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        sliders = []
        
        for i in 0...3 {
            let slider = UISlider()
            slider.tag = i
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.addTarget(self, action: #selector(ColorAttributeCell.sliderDidChange(_:)), for: .valueChanged)
            slider.translatesAutoresizingMaskIntoConstraints = false
            addSubview(slider)
            
            NSLayoutConstraint.activate([
                slider.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: xMargin),
                slider.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin),
            ])
            
            sliders.append(slider)
        }
        
        sliders[0].tintColor = .red
        sliders[1].tintColor = .green
        sliders[2].tintColor = .blue
        sliders[3].tintColor = .lightGray

        let r = sliders[0]
        let g = sliders[1]
        let b = sliders[2]
        let a = sliders[3]
        
        NSLayoutConstraint.activate([
            r.topAnchor.constraint(equalTo: label.bottomAnchor, constant: spacing),
            g.topAnchor.constraint(equalTo: r.bottomAnchor, constant: spacing),
            b.topAnchor.constraint(equalTo: g.bottomAnchor, constant: spacing),
            a.topAnchor.constraint(equalTo: b.bottomAnchor, constant: spacing),
            a.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -yMargin)
        ])
    }
    
    @objc private func sliderDidChange(_ target: UISlider) {
        do {
            var dictionary = try emitter.ToDictionary()
            var data: [Float] = [1.0, 1.0, 1.0, 1.0]

            if let temp = dictionary[path] as? [Float] {
                data = temp
            } else {
                guard let temp = dictionary[path] as? [NSNumber] else { return }
                for i in 0 ..< temp.count {
                    data[i] = temp[i].floatValue
                }
            }
            
            data[target.tag] = target.value
            dictionary[path] = data
            emitter.Set(try emitter.Parse(from: dictionary))
            
            preview.backgroundColor = UIColor(
                red: CGFloat(data[0]),
                green: CGFloat(data[1]),
                blue: CGFloat(data[2]),
                alpha: CGFloat(data[3])
            )
        } catch {
            fatalError("Failed to convert to dictionary.")
        }
    }
}
