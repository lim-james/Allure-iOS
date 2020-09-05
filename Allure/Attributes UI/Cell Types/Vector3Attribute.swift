//
//  Vector3Attribute.swift
//  Allure
//
//  Created by James on 22/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit
import simd

class Vector3AttributeCell: AttributeCell, UITextFieldDelegate {
    
    override public var path: String! {
        didSet {
            if let label = label {
                label.text = path.Separate()
            }
             
            do {
                let dictionary = try emitter.ToDictionary()
                let data = dictionary[path] as! [Float]
                
                for i in 0...2 {
                    textFields[i].text = String(data[i])
                }
            } catch {
                fatalError("Failed to convert to dictionary.")
            }
        }
    }
    
    private var textFields: [UITextField]!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        removeConstraint(labelBottom)
        NSLayoutConstraint.activate([label.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin)])
        
        textFields = []
        
        for i in 0...2 {
            let field = UITextField()
            field.delegate = self
            field.tag = i
            field.textAlignment = .center
            field.keyboardType = .numbersAndPunctuation
            field.autocorrectionType = .no
            field.addTarget(self, action: #selector(Vector3AttributeCell.textFieldDidChange(_:)), for: .editingChanged)
            field.translatesAutoresizingMaskIntoConstraints = false
            addSubview(field)
            
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: spacing),
                field.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -yMargin)
            ])
            
            if i > 0 {
                NSLayoutConstraint.activate([field.widthAnchor.constraint(equalTo: textFields[i - 1].widthAnchor)])
            }
            
            textFields.append(field)
        }
        
        NSLayoutConstraint.activate([
            textFields[0].leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: xMargin),
            textFields[1].leftAnchor.constraint(equalTo: textFields[0].rightAnchor, constant: spacing),
            textFields[2].leftAnchor.constraint(equalTo: textFields[1].rightAnchor, constant: spacing),
            textFields[2].rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin)
        ])
    }
    
    @objc private func textFieldDidChange(_ target: UITextField) {
        do {
            var dictionary = try emitter.ToDictionary()
            var data = dictionary[path] as! [Float]
            data[target.tag] = Float(target.text!) ?? 0
            dictionary[path] = data
            emitter.Set(try emitter.Parse(from: dictionary))
        } catch {
            fatalError("Failed to convert to dictionary.")
        }
    }
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let tableView = superview as? UITableView {
            tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
        }

        return true
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(self)
    }
}
