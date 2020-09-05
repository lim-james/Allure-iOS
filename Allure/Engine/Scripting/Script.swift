//
//  Script.swift
//  Allure
//
//  Created by James on 17/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class Script: Component {
    
    public var entities: EntityManager!
    public var transform: Transform!
    
    override public func SetActive(_ _state: Bool) {
        super.SetActive(_state)
        EventManager.Instance.Trigger(name: "SCRIPT_ACTIVE", data: self)
    }
    
    // when the script becomes active
    public func Awake() { }
    // when the scene enters
    public func Start() { }
    // every frame
    public func Update(dt: Float) { }
    // when the scene exits
    public func Stop() { }
    // when the script becomes inactive or scene is destroyed
    public func OnDestroy() { }
    
    internal func AddComponent<ComponentType: Component>() -> ComponentType? {
        return entities.AddComponent(entity: entity)
    }
    
    internal func GetComponent<ComponentType: Component>() -> ComponentType? {
        return entities.GetComponent(entity: entity)
    }
    
}
