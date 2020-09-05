//
//  FollowScript.swift
//  Allure
//
//  Created by James on 17/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

class FollowScript: Script {
    
    private var speed: Float!
    public var followSpeed: Float!
    public var returnSpeed: Float!
    
    private var target: vector_float3!

    override func Awake() {
        target = vector_float3(0, 0, 0)
        
        EventManager.Instance.Subscribe(name: "TOUCH_INPUT", callback: #selector(FollowScript.TouchHandler(_:)), context: self)
    }
    
    override func Update(dt: Float) {
        let diff = target - transform.translation
        let len = length(diff)
        if len != 0 {
            let dir = diff / len
            transform.translation += dir * dt * speed
        }
    }
    
    @objc private func TouchHandler(_ event: Any) {
        guard let touch = event as? TouchInput else { return }
        if touch.isDown {
            speed = followSpeed
            target = vector_float3(touch.position, 0)
        } else {
            speed = returnSpeed
            target = vector_float3(0, 0, 0)
        }
    }
    
}
