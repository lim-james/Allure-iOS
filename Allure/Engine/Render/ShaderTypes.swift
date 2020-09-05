//
//  ShaderTypes.swift
//  Allure
//
//  Created by James on 15/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd

struct StandardInstance {
    var model: matrix_float4x4
    var uvRect: simd_float4
    var color: simd_float4
}

struct TintInstance {
    var model: matrix_float4x4
    var color: simd_float4
}

struct Uniforms {
    var view: matrix_float4x4
    var projection: matrix_float4x4
}
