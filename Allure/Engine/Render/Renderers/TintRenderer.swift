//
//  TintRenderer.swift
//  Allure
//
//  Created by James on 26/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import MetalKit

class TintRenderer: NSObject, Renderer {

    internal var entities: EntityManager!
    internal var pipelineState: MTLRenderPipelineState!
    
    private var components: [TintRender]!
    
    public func Initialise() {
        EventManager.Instance.Subscribe(name: "TINT_RENDERER_ACTIVE", callback: #selector(TintRenderer.ActiveHandler(_:)), context: self)
    }
    
    public func SetProperties(entities: EntityManager, pipelineState: MTLRenderPipelineState) {
        self.entities = entities
        self.pipelineState = pipelineState
        
        self.components = []
    }
    
    public func Render(camera: Camera, drawable: CAMetalDrawable, encoder: MTLRenderCommandEncoder) {

        // batch instances
        
        var instances: [TintInstance] = []
        
        components.forEach { r in
            let transform: Transform = entities.GetComponent(entity: r.entity)!
            instances.append(TintInstance(model: transform.localTransform, color: r.tint))
        }
        
        if instances.isEmpty {
            return
        }
        
        let instanceSize = MemoryLayout<TintInstance>.size
        let maxSize = 4096
        let maxInstances = maxSize / instanceSize
        let drawCalls = instances.count / maxInstances + 1
        
        // set uniforms
        
        let transform: Transform = entities.GetComponent(entity: camera.entity)!
        
        var uniforms = Uniforms(
            view: transform.localLookAt,
            projection: camera.projection
        )

        // set a render pipeline state
        encoder.setRenderPipelineState(pipelineState)
        // bind vertices and uniforms
        encoder.setVertexBytes(RenderSystem.squareVertices, length: RenderSystem.squareVertices.count * MemoryLayout<vector_float2>.stride, index: 0)
        encoder.setVertexBytes(UnsafeRawPointer(&uniforms), length: MemoryLayout<Uniforms>.stride, index: 1)
        // bind instances
        if drawCalls <= 1 {
            encoder.setVertexBytes(instances, length: instances.count * instanceSize, index: 2)
            // render vertices
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: instances.count)
        } else {
            for i in 0 ..< drawCalls {
                let batch = Array(instances[i * maxInstances ..< min((i + 1) * maxInstances, instances.count)])
                if batch.isEmpty { break }
                
                encoder.setVertexBytes(batch, length: batch.count * instanceSize, index: 2)
                // render vertices
                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: batch.count)
            }
        }
    }
    
    @objc public func ActiveHandler(_ data: Any) {
        guard let component = data as? TintRender else {
            fatalError("Invalid event type.")
        }
        
        let index = components.firstIndex(where: { $0.entity == component.entity })
        
        if component.IsActive() {
            if index == nil {
                components.append(component)
            }
        } else {
            if let index = index {
                components.remove(at: index)
            }
        }
    }
    
}
