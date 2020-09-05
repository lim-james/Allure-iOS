//
//  System.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class System: NSObject, TypeName {
    
    internal var entities: EntityManager
    
    required init(entities manager: EntityManager) {
        entities = manager
    }
    
    public func Initialize() {
        fatalError("System not initialized.")
    }
    
    public func Update(dt: Float) {
        fatalError("System update not implemented.")
    }
    
}
