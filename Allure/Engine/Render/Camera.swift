//
//  Camera.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class Camera: Component {
    
    public var clearColor: vector_float4
    
    public var nearPlane: Float {
        didSet {
            UpdateProjection()
        }
    }
    
    public var farPlane: Float {
        didSet {
            UpdateProjection()
        }
    }
    
    public var size: Float {
        didSet {
            UpdateViewport()
            UpdateProjection()
        }
    }
    
    public var viewportRect: vector_float4 {
        didSet {
            UpdateViewport()
            UpdateProjection()
        }
    }
    
    public var depth: Float {
        didSet { EventManager.Instance.Trigger(name: "CAMERA_DEPTH", data: self) }
    }
    
    public var match: Float {
        didSet {
            UpdateViewport()
            UpdateProjection()
        }
    }
    
    private var aspectRatio: Float
    private var left, right, bottom, top: Float
    private(set) var viewport: vector_float4
    
    private(set) var projection: matrix_float4x4
    
    public var canvasSize: vector_float2 {
        didSet {
            UpdateViewport()
            UpdateProjection()
        }
    }
    
    required init() {
        clearColor = vector_float4(0, 0, 0, 0)
        
        nearPlane = 0.01
        farPlane = 100.0
        
        size = 1.0
        depth = 0.0
        viewportRect = vector_float4(0, 0, 1, 1)
        
        match = 0.0
        aspectRatio = 1.0
        left = -1.0
        right = 1.0
        bottom = -1.0
        top = 1.0
        viewport = vector_float4(0, 0, 1, 1)
        
        canvasSize = vector_float2(1, 1)
        
        projection = Math.Orthographic(left: left, right: right, bottom: bottom, top: top, nearPlane: nearPlane, farPlane: farPlane)
    }
    
    override public func Initialize() {
        super.Initialize()
        
        clearColor = vector_float4(0, 0, 0, 0)
        
        nearPlane = 0.01
        farPlane = 100.0
        
        size = 1.0
        depth = 0.0
        viewportRect = vector_float4(0, 0, 1, 1)
        
        match = 0.0
        aspectRatio = 1.0
        left = -1.0
        right = 1.0
        bottom = -1.0
        top = 1.0
        viewport = vector_float4(0, 0, 1, 1)
        
        canvasSize = vector_float2(1, 1)
        
        EventManager.Instance.Subscribe(name: "CANVAS_RESIZE", callback: #selector(Camera.CanvasResizeHandler(_:)), context: self)
    }
    
    override public func SetActive(_ _state: Bool) {
        super.SetActive(_state)
        EventManager.Instance.Trigger(name: "CAMERA_ACTIVE", data: self)
    }
    
    public func ScreenToWorldSpace(mousePosition: vector_float2) -> vector_float2 {
        let viewportPosition = mousePosition - vector_float2(viewport.x, viewport.y)

        var unitPosition = viewportPosition / vector_float2(viewport.z, viewport.w)
        unitPosition = unitPosition * 4.0 - 2.0

        let invMatch = 1.0 - match
        var result = unitPosition * size
        result.x = aspectRatio * invMatch * result.x + match * result.x
        result.y = aspectRatio * match * result.y + invMatch * result.y
        result.y = -result.y

        return result;
    }
    
    @objc private func CanvasResizeHandler(_ event: Any) {
        guard let size = event as? vector_float2 else { return }
        canvasSize = size
    }
    
    private func UpdateViewport() {
        viewport = vector_float4(canvasSize.x, canvasSize.y, canvasSize.x, canvasSize.y) * viewportRect
        
        let invMatch = 1.0 - match
        aspectRatio = (viewport.z * invMatch + viewport.w * match) / (viewport.z * match + viewport.w * invMatch)
        
        let unit = aspectRatio * size
        let w = unit * invMatch + size * match
        let h = unit * match + size * invMatch
        
        left = -w
        right = w
        bottom = -h
        top = h
    }
    
    private func UpdateProjection() {
        projection = Math.Orthographic(left: left, right: right, bottom: bottom, top: top, nearPlane: nearPlane, farPlane: farPlane)
    }
    
}
