//
//  Renderer.swift
//  Allure
//
//  Created by James on 26/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import MetalKit

protocol Renderer {
    var entities: EntityManager! { get set }
    var pipelineState: MTLRenderPipelineState! { get set }
    
    func Initialise()
    func SetProperties(entities: EntityManager, pipelineState: MTLRenderPipelineState)
    func Render(camera: Camera, drawable: CAMetalDrawable, encoder: MTLRenderCommandEncoder)
    func ActiveHandler(_ data: Any)
}
