//
//  EntityManager.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class EntityManager {
        
    private var entities: [[String: Component]]
    
    private var used: [Int]
    private var unused: [Int]
    
    init() {
        entities = []
        used = []
        unused = []
    }
    
    public func Create() -> Int {
        if unused.isEmpty {
            Expand()
        }
        
        let id = unused[0]
        unused.remove(at: 0)
        used.append(id)
        
        guard let transform: Transform = GetComponent(entity: id) else {
            fatalError("No Transform found in component")
        }
    
        transform.SetActive(true)
        
        return id;
    }
    
    public func Destroy(id: Int) {
        if let index = used.firstIndex(of: id) {
            used.remove(at: index)
            
            for component in entities[id] {
                component.value.Initialize()
                component.value.SetActive(false)
            }
            
            unused.append(id)
        }
    }
        
    public func AddComponent<ComponentType: Component>(entity id: Int) -> ComponentType? {
        if id > entities.count {
            return nil
        }
        
        let name = ComponentType.self.typeName
        
        if let component = entities[id][name] {
            return component as? ComponentType
        } else {
            let component = ComponentType()
            component.entity = id;
            component.Initialize()
            
            entities[id][name] = component
            
            return component
        }
    }
    
    public func GetComponent<ComponentType: Component>(entity id: Int) -> ComponentType? {
        if id > entities.count {
            return nil
        }
        
        let index = ComponentType.self.typeName
        return entities[id][index] as? ComponentType
    }
    
    private func Expand() {
        let id = entities.count
        entities.append([:])
        unused.append(id)
        
        let _: Transform? = AddComponent(entity: id)
    }
    
}


