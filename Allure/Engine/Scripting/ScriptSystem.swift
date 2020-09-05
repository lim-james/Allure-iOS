//
//  ScriptSystem.swift
//  Allure
//
//  Created by James on 17/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class ScriptSystem: NSObject {
    
    private var started: Bool
    
    private var entities: EntityManager
    private var scripts: [Script] = []
    
    required init(entities manager: EntityManager) {
        started = false
        entities = manager
    }
    
    public func Awake() {
        started = false
        EventManager.Instance.Subscribe(name: "SCRIPT_ACTIVE", callback: #selector(ScriptSystem.ActiveHandler(_:)), context: self)
        scripts.forEach { $0.Awake() }
    }
    
    public func Start() {
        started = true
        scripts.forEach { $0.Start() }
    }
    
    public func Update(dt: Float) {
        scripts.forEach { $0.Update(dt: dt) }
    }
    
    public func Stop() {
        started = false
        scripts.forEach { $0.Stop() }
    }
    
    @objc private func ActiveHandler(_ data: Any) {
        guard let component = data as? Script else {
            fatalError("Invalid event type.")
        }
        
        let index = scripts.firstIndex(where: { $0.entity == component.entity })
        
        if component.IsActive() {
            if index == nil {
                component.entities = entities
                component.transform = component.GetComponent()
                
                component.Awake()
                if started {
                    component.Start()
                }
                scripts.append(component)
            }
        } else {
            if let index = index {
                scripts[index].OnDestroy()
                scripts.remove(at: index)
            }
        }
    }
    
}
