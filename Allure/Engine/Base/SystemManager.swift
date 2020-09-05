//
//  SystemsManager.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class SystemManager {
    
    private let entities: EntityManager
    
    private var systems: [String: System]
    // frame splitting data
    private var frameDelta: [String: Float]
    private var frameLayout: [[System]]
    private var frame: Int
    
    init(entities manager: EntityManager) {
        entities = manager
        
        systems = [:]
        frameDelta = [:]
        frameLayout = []
        frame = 1
    }
    
    public func Update(dt: Float) {
        if (frameLayout.isEmpty) {
            return
        }
        
        // update all the frame deltas
        frameDelta = frameDelta.mapValues { return $0 + dt }
        
        // call update for index 0 (updates every frame)
        frameLayout[0].forEach { system in
            system.Update(dt: dt)
        }
        
        // update current splitted frame
        if (frameLayout.count <= 1) {
            return
        }
        
        frameLayout[frame].forEach { system in
            let name = type(of: system).typeName
            system.Update(dt: frameDelta[name]!)
            frameDelta[name] = 0.0
        }
        
        frame += 1
        
        if frame >= frameLayout.count {
            frame = 1
        }
    }
    
    public func Add<SystemType: System>(frameIndex: Int) -> SystemType {
        while frameLayout.count <= frameIndex {
            frameLayout.append([])
        }
        
        let name = SystemType.self.typeName
        
        if let system = systems[name] {
            return (system as! SystemType)
        } else {
            let system = SystemType(entities: entities)
            system.Initialize()
            
            systems[name] = system
            frameDelta[name] = 0.0
            frameLayout[frameIndex].append(system)
            
            return system
        }
    }
    
}
