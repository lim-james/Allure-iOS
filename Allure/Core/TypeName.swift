//
//  TypeName.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

protocol TypeName: AnyObject {
    static var typeName: String { get }
}

extension TypeName {
    static var typeName: String {
        let type = String(describing: self)
        return type
    }
}
