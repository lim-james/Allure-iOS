
//
//  CollectionManager.swift
//  Allure
//
//  Created by James on 2/4/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class CollectionManager: NSObject {
    
    private(set) var map: [String: ParticleEmitter]
    private var current: String
    
    public var emitter: ParticleEmitter!
    
    override init() {
        map = [:]
        current = ""
        
        super.init()
        
        // subscribe events
        // - emitter name updating
        // - emitter data updating
        
        EventManager.Instance.Subscribe(name: "EMITTER_NAME", callback: #selector(CollectionManager.UpdatedName(_:)), context: self)
        EventManager.Instance.Subscribe(name: "EMITTER_DATA", callback: #selector(CollectionManager.UpdatedData), context: self)
    }
    
    public func SetCurrent(name: String) {
        if let curr = map[name] {
            current = name
            emitter.Set(curr, false)
            
            EventManager.Instance.Trigger(name: "CURRENT_SET", data: current)
        }
    }
    
    public func SetCurrent(index: Int) {
        if index < map.count {
            current = Array(map.keys)[index]
            emitter.Set(map[current]!, false)
            
            EventManager.Instance.Trigger(name: "CURRENT_SET", data: current)
        }
    }
    
    // Create methods
    // - new emitter
    // - Set to standard properties
    
    public func NewEmitter(named: String) {
        let standard = ParticleEmitter()
        SetStandardProperties(emitter: standard)
        
        let name = GetUniqueName(named)
        map[name] = standard
        SetCurrent(name: name)
        EventManager.Instance.Trigger(name: "RELOAD_COLLECTION", data: -1)
    }
    
    private func GetUniqueName(_ name: String) -> String {
        var count = 1
        
        if let _ = map[name] {
            while let _ = map[name + " (\(count))"] {
                count += 1
            }
            
            return name + " (\(count))"
        } else {
            return name
        }
    }
    
    private func SetStandardProperties(emitter: ParticleEmitter) {
        emitter.burstAmount = 5

        emitter.lifetime = 2.0
        emitter.lifetimeRange = 2.0

        emitter.positionRange = vector_float3(0.0, 0.0, 0.0)
        emitter.angleRange = vector_float3(0.0, 0.0, 180.0)

        emitter.speed = 10.0
        emitter.speedRange = 2.0

        emitter.accelRad = -10.0

        emitter.startSize = vector_float3(0.25, 0.25, 0.25)
        emitter.endSize = vector_float3(0, 0, 0)

        emitter.startColor = vector_float4(0.5, 0.0, 0.5, 1.0)
        emitter.startColorRange = vector_float4(0.5, 0.0, 0.0, 0.0)

        emitter.endColor = vector_float4(1.0, 0.5, 0.0, 1.0)
        emitter.endColorRange = vector_float4(0.0, 0.5, 0.0, 0.0)
    }
    
    // Load methods
    // - Load data
    // - Load dummy data
    
    public func LoadData() {
        if let list = UserDefaults.standard.array(forKey: "LIST") as? [String] {
            list.forEach {
                if let raw = UserDefaults.standard.string(forKey: $0),
                    let data = raw.data(using: .utf8) {
                    do {
                        map[$0] = try JSONDecoder().decode(ParticleEmitter.self, from: data)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            LoadDummyData()
            map.keys.forEach { UpdateField(name: $0) }
        }
    }
    
    private func LoadDummyData() {
        let standard = ParticleEmitter()
        SetStandardProperties(emitter: standard)
        map["Standard"] = standard
        
        let unity = ParticleEmitter()
        unity.duration = 0.01
        unity.loop = true
        unity.burstAmount = 600
        
        unity.delay = 2.0
        unity.lifetime = 3.0
        unity.lifetimeRange = 2.0

        unity.mask = "unity"
        unity.threshold = vector_float4(repeating: 0.5)
        unity.positionRange = vector_float3(60, 31.6, 1.0)
        
        unity.speed = 0.0

        unity.accelRad = -10.0
        
        unity.startSize = vector_float3(repeating: 0.4)
        unity.endSize = vector_float3(0, 0, 0)

        unity.startColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        unity.startColorRange = vector_float4(0.0, 0.0, 0.0, 0.0)
        
        map["Unity"] = unity
        
        let apple = ParticleEmitter()
        apple.duration = 0.01
        apple.loop = true
        
        apple.delay = 2.0
        apple.lifetime = 3.0
        apple.lifetimeRange = 1.0

        apple.mask = "apple"
        apple.threshold = vector_float4(repeating: 0.5)
        apple.positionRange = vector_float3(20.0, 20.0, 1.0)
        
        apple.speed = 10.0
        apple.speedRange = 5.0

        apple.drag = 2.0
        
        apple.startSize = vector_float3(repeating: 0.35)
        apple.endSize = vector_float3(0, 0, 0)

        apple.startColor = vector_float4(0.5, 0.0, 0.5, 1.0)
        apple.startColorRange = vector_float4(0.5, 0.0, 0.0, 0.0)

        apple.endColor = vector_float4(1.0, 0.5, 0.0, 1.0)
        apple.endColorRange = vector_float4(0.0, 0.5, 0.0, 0.0)
        
        map["Apple"] = apple
    }
    
    // save methods
    // - Update name handler
    // - Update data handler
    // - Save data
    
    @objc private func UpdatedName(_ data: Any) {
        guard let new = data as? String else {
            fatalError("Invalid event type.")
        }
        
        guard let index = Array(map.keys).firstIndex(of: current) else { return }
        
        map[new] = map[current]
        map.removeValue(forKey: current)
        DeleteField(name: current)
        current = new
        UpdateField(name: current)
        
        EventManager.Instance.Trigger(name: "RELOAD_COLLECTION", data: index)
        
        if let index = Array(map.keys).firstIndex(of: current) {
            EventManager.Instance.Trigger(name: "RELOAD_COLLECTION", data: index)
        }
    }
    
    @objc private func UpdatedData() {
        map[current]?.Set(emitter, false)
        UpdateField(name: current)
        
        if let index = Array(map.keys).firstIndex(of: current) {
            EventManager.Instance.Trigger(name: "RELOAD_COLLECTION", data: index)
        }
    }
    
    // persistence data methods
    
    private func UpdateField(name: String) {
        let encoder = JSONEncoder()
        var serialised = ""

        do {
            let data = try encoder.encode(map[name])
            serialised = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        UserDefaults.standard.set(Array(map.keys), forKey: "LIST")
        UserDefaults.standard.set(serialised, forKey: name)
    }
    
    private func DeleteField(name: String) {
        UserDefaults.standard.set(Array(map.keys), forKey: "LIST")
        UserDefaults.standard.removeObject(forKey: name)
    }
    
}
