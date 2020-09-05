//
//  StandardRenderer.swift
//  Allure
//
//  Created by James on 26/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import MetalKit

class StandardRenderer: NSObject, Renderer {

    internal var entities: EntityManager!
    internal var pipelineState: MTLRenderPipelineState! {
        didSet {
            device = pipelineState.device
        }
    }
    
    private var componentBatches: [String: (MTLTexture, [Render])]!
    private var device: MTLDevice!
    
    public func Initialise() {
        EventManager.Instance.Subscribe(name: "STANDARD_RENDERER_ACTIVE", callback: #selector(StandardRenderer.ActiveHandler(_:)), context: self)
        
        EventManager.Instance.Subscribe(name: "TEXTURE_PATH_CHANGE", callback: #selector(StandardRenderer.TextureChangeHandler(_:)), context: self)
    }
    
    public func SetProperties(entities: EntityManager, pipelineState: MTLRenderPipelineState) {
        self.entities = entities
        self.pipelineState = pipelineState
        
        self.componentBatches = [:]
    }
    
    public func Render(camera: Camera, drawable: CAMetalDrawable, encoder: MTLRenderCommandEncoder) {
        componentBatches.forEach { (key: String, value: (MTLTexture, [Render])) in
            let texture = value.0
            let components = value.1
            
            var instances: [StandardInstance] = []
            // batch instances
            components.forEach { r in
                let transform: Transform = entities.GetComponent(entity: r.entity)!
                instances.append(StandardInstance(model: transform.localTransform, uvRect: r.uvRect, color: r.tint))
            }
            
            if instances.isEmpty {
                return
            }
            
            let instanceSize = MemoryLayout<StandardInstance>.size
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
            // set fragment textures
            encoder.setFragmentTexture(texture, index: 3)
            // set arguments for vertex function
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
    }
    
    @objc public func ActiveHandler(_ data: Any) {
        guard let component = data as? Render else {
            fatalError("Invalid event type.")
        }
        
        let components = componentBatches[component.texture]
        
        if component.IsActive() {
            // check if texture batch exists
            if components == nil {
                // texture does not exists
                if !component.texture.isEmpty,
                    let uiImage = UIImage(named: component.texture),
                    let cgImage = uiImage.cgImage {
                    let loader = MTKTextureLoader(device: device)
                    // create textures
                    do {
                        let texture = try loader.newTexture(cgImage: cgImage, options: nil)
                        componentBatches[component.texture] = (texture, [component])
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                // append component to batch if it does not exists
                if let components = components,
                    components.1.firstIndex(of: component) != nil {
                    componentBatches[component.texture]!.1.append(component)
                }
            }
        } else {
            // remove component if it exists in batch
            if let components = components,
                let index = components.1.firstIndex(of: component) {
                componentBatches[component.texture]!.1.remove(at: index)
            }
        }
    }
    
    @objc public func TextureChangeHandler(_ data: Any) {
        guard let event = data as? Render.TextureChangeEvent else {
            fatalError("Invalid event type.")
        }
        
        let component = event.component
        
        if !component.IsActive() {
            return
        }
        
        // delete from previous batch
        if let components = componentBatches[event.previous],
            let index = components.1.firstIndex(of: component) {
            componentBatches[event.previous]!.1.remove(at: index)
        }
        
        let components = componentBatches[component.texture]
        
        // check if texture batch exists
        if components == nil {
            // texture does not exists
            if !component.texture.isEmpty,
                let uiImage = UIImage(named: component.texture),
                let cgImage = uiImage.cgImage {
                let loader = MTKTextureLoader(device: device)
                // create textures
                do {
                    let texture = try loader.newTexture(cgImage: cgImage, options: nil)
                    componentBatches[component.texture] = (texture, [component])
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            // append component to batch if it does not exists
            if let components = components,
                components.1.firstIndex(of: component) != nil {
                componentBatches[component.texture]!.1.append(component)
            }
        }
    
    }
    
}
