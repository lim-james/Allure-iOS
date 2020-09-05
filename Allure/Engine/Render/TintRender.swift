//
//  TintRenderer.swift
//  Allure
//
//  Created by James on 26/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class TintRender: Component {
    
    public var tint: vector_float4
    
    required init() {
        tint = vector_float4(1.0, 1.0, 1.0, 1.0)
    }
    
    override public func Initialize() {
        super.Initialize()
        tint = vector_float4(1.0, 1.0, 1.0, 1.0)
    }
    
    override public func SetActive(_ _state: Bool) {
        super.SetActive(_state)
        EventManager.Instance.Trigger(name: "TINT_RENDERER_ACTIVE", data: self)
    }
    
}
