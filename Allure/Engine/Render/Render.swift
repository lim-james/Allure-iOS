//
//  Render.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import Metal
import simd
import UIKit

class Render: Component {
    
    struct TextureChangeEvent {
        public var previous: String
        public var component: Render
    }
    
    public var uvRect: vector_float4
    public var tint: vector_float4
    public var texture: String {
        didSet {
            EventManager.Instance.Trigger(name: "TEXTURE_PATH_CHANGE", data: TextureChangeEvent(previous: oldValue, component: self))
        }
    }
    
    required init() {
        uvRect = vector_float4(0.0, 0.0, 1.0, 1.0)
        tint = vector_float4(1.0, 1.0, 1.0, 1.0)
        texture = ""
    }
    
    override public func Initialize() {
        super.Initialize()
        uvRect = vector_float4(0.0, 0.0, 1.0, 1.0)
        tint = vector_float4(1.0, 1.0, 1.0, 1.0)
        texture = ""
    }
    
    override public func SetActive(_ _state: Bool) {
        super.SetActive(_state)
        EventManager.Instance.Trigger(name: "STANDARD_RENDERER_ACTIVE", data: self)
    }
    
}
