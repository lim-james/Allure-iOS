//
//  Transform.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class Transform: Component {
    
    public var translation: vector_float3 {
        didSet {
            UpdateTransform()
            UpdateLookAt()
        }
    }
    
    public var rotation: vector_float3 {
        didSet {
            UpdateTransform()
            UpdateAxes()
            UpdateLookAt()
        }
    }
       
    public var scale: vector_float3 {
       didSet { UpdateTransform() }
    }
    
    private var localAxes: matrix_float3x3
    private(set) var localTransform: matrix_float4x4
    private(set) var localLookAt: matrix_float4x4
    
    required init() {
        translation = vector_float3(repeating: 0.0)
        rotation = vector_float3(repeating: 0.0)
        scale = vector_float3(repeating: 1.0)
        
        localAxes = matrix_float3x3(1.0)
        localTransform = matrix_float4x4(1.0)
        localLookAt = matrix_float4x4(1.0)
    }
    
    override public func Initialize() {
        super.Initialize()
        
        translation = vector_float3(repeating: 0.0)
        rotation = vector_float3(repeating: 0.0)
        scale = vector_float3(repeating: 1.0)
    }
    
    public func GetLocalUp() -> vector_float3 {
        return localAxes.columns.1
    }
    
    public func GetLocalFront() -> vector_float3 {
        return localAxes.columns.2
    }
    
    public func GetLocalRight() -> vector_float3 {
        return localAxes.columns.0
    }

    private func UpdateAxes() {
        let yawRad = rotation.y * Math.ToRad
        let pitchRad = -rotation.x * Math.ToRad
        let rollRad = rotation.z * Math.ToRad

        localAxes.columns.2.z = -cos(yawRad) * cos(pitchRad);
        localAxes.columns.2.y = sin(pitchRad);
        localAxes.columns.2.x = sin(yawRad) * cos(pitchRad);

        let worldUp = simd_float3(sin(rollRad), cos(rollRad), 0.0);

        localAxes.columns.0 = normalize(cross(localAxes.columns.2, worldUp));
        localAxes.columns.1 = normalize(cross(localAxes.columns.0, localAxes.columns.2));
    }
    
    private func UpdateTransform() {
        Math.SetToTransform(mat: &localTransform, translation: translation, rotation: rotation, scale: scale)
    }
    
    private func UpdateLookAt() {
        localLookAt = Math.LookAt(eye: translation, axes: localAxes)
    }
    
    override public func Debug() {
        print("Translation: ", translation)
        print("Rotation   : ", rotation)
        print("Scale      : ", scale)
    }
    
}
