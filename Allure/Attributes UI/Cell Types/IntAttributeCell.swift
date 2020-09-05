//
//  IntAttributeCell.swift
//  Allure
//
//  Created by James on 19/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class IntAttributeCell: AttributeCell, UITextFieldDelegate {
    
    override public var path: String! {
        didSet {
            if let label = label {
                label.text = path.Separate()
            }
            
            if let textField = textField {
                do {
                    let dictionary = try emitter.ToDictionary()
                   textField.text = "\(dictionary[path] ?? 0)"
                } catch {
                    fatalError("Failed to convert to dictionary.")
                }
            }
        }
    }
    
    private var textField: UITextField!
    
    private var original: Int!
    private var xValue: CGFloat!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField = UITextField()
        textField.delegate = self
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        
        textField.addTarget(self, action: #selector(IntAttributeCell.textFieldDidChange(_:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: yMargin),
            textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -yMargin),
            textField.leftAnchor.constraint(equalTo: label.rightAnchor, constant: spacing),
            textField.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -xMargin)
        ])
    }
    
    @objc private func textFieldDidChange(_ taget: UITextField) {
        do {
            var dictionary = try emitter.ToDictionary()
            dictionary[path] = Int(textField.text!) ?? 0
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        xValue = touch.location(in: self).x
        
        tableView?.isScrollEnabled = false
        
        overlayRight.constant = xValue - frame.width
        UIView.animate(withDuration: 0.25) {
            self.overlay.alpha = 0.25
        }
        
        do {
            let dictionary = try emitter.ToDictionary()
            original = dictionary[path] as? Int
        } catch {
            fatalError("Failed to convert to dictionary.")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let curr = touch.location(in: self).x
        
        overlayRight.constant = curr - frame.width
        
        var change = Float(curr - xValue)
        change *= sqrt(abs(change))
        change *= 0.01

        do {
            let value = original! + Int(change)
            
            var dictionary = try emitter.ToDictionary()
            dictionary[path] = value
            emitter.Set(try emitter.Parse(from: dictionary))
            
            textField.text = String(value)
        } catch {
            fatalError("Failed to convert to dictionary.")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        tableView?.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.25) {
            self.overlay.alpha = 0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        tableView?.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.25) {
            self.overlay.alpha = 0
        }
    }
}
