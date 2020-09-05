//
//  ParticleEmitter.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class ParticleEmitter: Component, Codable {

    public var age: Float
    public var duration: Float
    
    public var spawnInterval: Float
    public var spawnTimer: Float
    public var burstAmount: Int
    
    public var loop: Bool
    public var delay: Float
    public var lifetime: Float
    public var lifetimeRange: Float
    
    public var angle: vector_float3
    public var angleRange: vector_float3
    
    public var speed: Float
    public var speedRange: Float
    
    public var mask: String {
        didSet {
            if oldValue == mask { return }
            EventManager.Instance.Trigger(name: "EMITTER_MASK", data: self)
        }
    }
    
    public var spawnIndex: Int
    
    public var maskColor: vector_float4  {
        didSet {
            if oldValue == maskColor { return }
            EventManager.Instance.Trigger(name: "EMITTER_MASK", data: self)
        }
    }
    
    public var threshold: vector_float4  {
        didSet {
            if oldValue == threshold { return }
            EventManager.Instance.Trigger(name: "EMITTER_MASK", data: self)
        }
    }
    
    public var offset: vector_float3
    public var positionRange: vector_float3
    
    public var gravity: vector_float3
    public var drag: Float
    
    public var accelRad: Float
    public var accelRadRange: Float
    
    public var startSize: vector_float3
    public var startSizeRange: vector_float3
    
    public var endSize: vector_float3
    public var endSizeRange: vector_float3
    
    public var startColor: vector_float4
    public var startColorRange: vector_float4
    
    public var endColor: vector_float4
    public var endColorRange: vector_float4
    
    required init() {
        age = 0.0
        duration = -1.0

        spawnInterval = 0.0
        spawnTimer = 0.0
        burstAmount = 1

        loop = false
        delay = 0.0
        lifetime = 1.0
        lifetimeRange = 0.0

        angle = vector_float3(0.0, 0.0, 0.0)
        angleRange = vector_float3(0.0, 0.0, 0.0)
        
        speed = 1.0
        speedRange = 0.0
        
        mask = ""
        spawnIndex = 0
        maskColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        threshold = vector_float4(0.1, 0.1, 0.1, 0.1)
        
        offset = vector_float3(0.0, 0.0, 0.0)
        positionRange = vector_float3(0.0, 0.0, 0.0)
        
        gravity = vector_float3(0.0, 0.0, 0.0)
        drag = 0.0
        
        accelRad = 0.0
        accelRadRange = 0.0
        
        startSize = vector_float3(1.0, 1.0, 1.0)
        startSizeRange = vector_float3(0.0, 0.0, 0.0)
        
        endSize = vector_float3(0.0, 0.0, 0.0)
        endSizeRange = vector_float3(0.0, 0.0, 0.0)
            
        startColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        startColorRange = vector_float4(0.0, 0.0, 0.0, 0.0)
        
        endColor = vector_float4(0.0, 0.0, 0.0, 0.0)
        endColorRange = vector_float4(0.0, 0.0, 0.0, 0.0)
    }
    
    override public func Initialize() {
        super.Initialize()
              
        age = 0.0
        duration = -1.0

        spawnInterval = 0.0
        spawnTimer = 0.0
        burstAmount = 1

        loop = false
        delay = 0.0
        lifetime = 1.0
        lifetimeRange = 0.0

        angle = vector_float3(0.0, 0.0, 0.0)
        angleRange = vector_float3(0.0, 0.0, 0.0)
        
        speed = 1.0
        speedRange = 0.0
        
        mask = ""
        spawnIndex = 0
        maskColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        threshold = vector_float4(0.1, 0.1, 0.1, 0.1)
        
        offset = vector_float3(0.0, 0.0, 0.0)
        positionRange = vector_float3(0.0, 0.0, 0.0)
        
        gravity = vector_float3(0.0, 0.0, 0.0)
        drag = 0.0
        
        accelRad = 0.0
        accelRadRange = 0.0
        
        startSize = vector_float3(1.0, 1.0, 1.0)
        startSizeRange = vector_float3(0.0, 0.0, 0.0)
        
        endSize = vector_float3(0.0, 0.0, 0.0)
        endSizeRange = vector_float3(0.0, 0.0, 0.0)
            
        startColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        startColorRange = vector_float4(0.0, 0.0, 0.0, 0.0)
        
        endColor = vector_float4(0.0, 0.0, 0.0, 0.0)
        endColorRange = vector_float4(0.0, 0.0, 0.0, 0.0)
    }
    
    public func Set(_ value: ParticleEmitter, _ update: Bool = true) {
        age = value.age
        duration = value.duration

        spawnInterval = value.spawnInterval
        spawnTimer = value.spawnTimer
        burstAmount = value.burstAmount

        loop = value.loop
        delay = value.delay
        lifetime = value.lifetime
        lifetimeRange = value.lifetimeRange

        angle = value.angle
        angleRange = value.angleRange
        
        speed = value.speed
        speedRange = value.speedRange
        
        mask = value.mask
        spawnIndex = value.spawnIndex
        maskColor = value.maskColor
        threshold = value.threshold
        
        offset = value.offset
        positionRange = value.positionRange
        
        gravity = value.gravity
        drag = value.drag
        
        accelRad = value.accelRad
        accelRadRange = value.accelRadRange
        
        startSize = value.startSize
        startSizeRange = value.startSizeRange
        
        endSize = value.endSize
        endSizeRange = value.endSizeRange
            
        startColor = value.startColor
        startColorRange = value.startColorRange
        
        endColor = value.endColor
        endColorRange = value.endColorRange
        
        if update {
            EventManager.Instance.Trigger(name: "EMITTER_DATA")
        }
    }
    
    override public func SetActive(_ _state: Bool) {
        super.SetActive(_state)
        EventManager.Instance.Trigger(name: "EMITTER_ACTIVE", data: self)
    }
    
}
