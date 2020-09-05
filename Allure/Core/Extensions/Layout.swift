//
//  Layout.swift
//  Allure
//
//  Created by James on 25/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    static public func FillBounds(child: UIView, parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leftAnchor.constraint(equalTo: parent.leftAnchor),
            child.rightAnchor.constraint(equalTo: parent.rightAnchor),
        ])
    }
    
}
