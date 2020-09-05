//
//  Math.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

struct Math {
    static public let PI: Float = 3.14159
    static public let ToRad: Float = PI / 180.0
    static public let ToDeg: Float = 180.0 / PI
    
    static public func Clamp<T: Comparable>(_ value: T, min a: T, max b: T) -> T {
        return max(a, min(b, value))
    }
    
    static public func Round<T: FloatingPoint>(_ value: T, sf: T) -> T {
        return round(value * sf) / sf
    }
    
    static public func RandomRange(_ value: Float) -> Float {
        let mag = abs(value)
        return Float.random(in: -mag...mag)
    }
    
    static public func RandomRange(_ value: vector_float3) -> vector_float3 {
        return vector_float3(
            RandomRange(value.x),
            RandomRange(value.y),
            RandomRange(value.z)
        )
    }
    
    static public func RandomRange(_ value: vector_float4) -> vector_float4 {
        return vector_float4(
            RandomRange(value.x),
            RandomRange(value.y),
            RandomRange(value.z),
            RandomRange(value.w)
        )
    }
}
