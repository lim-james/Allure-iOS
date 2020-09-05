//
//  Particle.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class Particle: Component {
    
    public var age: Float
    public var lifetime: Float
    
    public var velocity: vector_float3
    
    public var startSize: vector_float3
    public var endSize: vector_float3
    
    public var startColor: vector_float4
    public var endColor: vector_float4
    
    required init() {
        age = 0.0
        lifetime = 1.0
        
        velocity = vector_float3(0.0, 0.0, 0.0)
        
        startSize = vector_float3(1.0, 1.0, 1.0)
        endSize = vector_float3(0.0, 0.0, 0.0)
        
        startColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        endColor = vector_float4(0.0, 0.0, 0.0, 0.0)
    }
    
    override func Initialize() {
        super.Initialize()
        
        age = 0.0
        lifetime = 1.0
        
        velocity = vector_float3(0.0, 0.0, 0.0)
        
        startSize = vector_float3(1.0, 1.0, 1.0)
        endSize = vector_float3(0.0, 0.0, 0.0)
        
        startColor = vector_float4(1.0, 1.0, 1.0, 1.0)
        endColor = vector_float4(0.0, 0.0, 0.0, 0.0)
    }
    
}
