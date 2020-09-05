//
//  RenderSystem.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import simd
import Metal
import MetalKit

class RenderSystem: System {
    
    static let squareVertices = [
        simd_float2(-0.5,  0.5),
        simd_float2(-0.5, -0.5),
        simd_float2( 0.5, -0.5),
        simd_float2(-0.5,  0.5),
        simd_float2( 0.5, -0.5),
        simd_float2( 0.5,  0.5)
    ]
    
    // rendering pipeline attributes
    
    private var device: MTLDevice!
    private var library: MTLLibrary!
    private var commandQueue: MTLCommandQueue!
    private var standardPipelineState: MTLRenderPipelineState!
    private var tintPipelineState: MTLRenderPipelineState!
    private var layer: CAMetalLayer!
    
    // system attributes
    
    private var cameras: [Camera] = []
    // renderers
    private var renderers: [Renderer] = []
    
    required init(entities manager: EntityManager) {
        super.init(entities: manager)
        
        renderers.append(StandardRenderer())
        renderers.append(TintRenderer())
    }
    
    public func SetContext(view: MTKView) {
        // get default device for communication
        guard let _device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to get default device.")
        }
        device = _device
        
        EventManager.Instance.Trigger(name: "NEW_DEVICE", data: device)
        
        // make default library from device
        guard let _library = device.makeDefaultLibrary() else {
            fatalError("Failed to make default library.")
        }
        library = _library

        // to send tasks to gpu
        guard let _commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create command queue.")
        }
        commandQueue = _commandQueue
    
        // iniialise view
        view.device = device;
        view.clearColor = MTLClearColorMake(0, 0.0, 0.0, 1.0)
        view.enableSetNeedsDisplay = true
 
        // create render pipeline states
        do {
            renderers[0].SetProperties(
                entities: entities,
                pipelineState: try CreatePipelineState(vertexName: "standardVertexShader", fragmentName: "standardFragmentShader", view: view)
            )
        } catch {
            fatalError("Failed to creare Render Pipeline State.")
        }
        
        do {
            renderers[1].SetProperties(
                entities: entities,
                pipelineState: try CreatePipelineState(vertexName: "tintVertexShader", fragmentName: "tintFragmentShader", view: view)
            )
        } catch {
            fatalError("Failed to creare Render Pipeline State.")
        }
        
        layer = view.layer as? CAMetalLayer
    }
    
    override public func Initialize() {
        renderers.forEach { $0.Initialise() }
        EventManager.Instance.Subscribe(name: "CAMERA_ACTIVE", callback: #selector(RenderSystem.CameraActiveHandler(_:)), context: self)
        EventManager.Instance.Subscribe(name: "CAMERA_DEPTH", callback: #selector(RenderSystem.CameraDepthHandler(_:)), context: self)
    }
    
    override public func Update(dt: Float) {
        for camera in cameras {
            guard let drawable = layer.nextDrawable() else {
                fatalError("Failed to get view's drawable.")
            }

            // used for creating render pass
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double(camera.clearColor.x),
                green: Double(camera.clearColor.y),
                blue: Double(camera.clearColor.z),
                alpha: Double(camera.clearColor.w)
            )
            
            // buffer for commands
            guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                fatalError("Failed to create command buffer.")
            }
            
            // creating a render pass
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Failed to create render encoder.")
            }
             
            
            renderers.forEach { $0.Render(camera: camera, drawable: drawable, encoder: renderEncoder) }

            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    private func CreatePipelineState(vertexName: String, fragmentName: String, view: MTKView) throws -> MTLRenderPipelineState {
        // get shader functions
        guard let vertex = library.makeFunction(name: vertexName) else {
            fatalError("Failed to get function \"\(vertexName)\"")
        }

        guard let fragment = library.makeFunction(name: fragmentName) else {
            fatalError("Failed to get function \"\(fragmentName)\"")
        }

        // create pipeline descriptor for configurations
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Simple Pipeline"
        pipelineStateDescriptor.vertexFunction = vertex
        pipelineStateDescriptor.fragmentFunction = fragment
        guard let attachment = pipelineStateDescriptor.colorAttachments[0] else {
            fatalError("Failed to get color attachment")
        }
        attachment.pixelFormat = view.colorPixelFormat
        // enable alpha blending
        attachment.isBlendingEnabled = true
        // alpha blending properties
        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.sourceAlphaBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        return try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }

    @objc private func CameraActiveHandler(_ data: Any) {
        guard let component = data as? Camera else {
            fatalError("Invalid event type.")
        }
        
        let index = cameras.firstIndex(where: { $0.entity == component.entity })
        
        if component.IsActive() {
            if index == nil {
                component.canvasSize = vector_float2(Float(layer.frame.width), Float(layer.frame.size.height))
                
                for i in 0 ..< cameras.count {
                    if (cameras[i].depth >= component.depth) {
                        cameras.insert(component, at: i)
                        return
                    }
                }
                cameras.append(component)
            }
        } else {
            if let index = index {
                cameras.remove(at: index)
            }
        }
    }
    
    @objc private func CameraDepthHandler(_ data: Any) {
        guard let component = data as? Camera else {
            fatalError("Invalid event type.")
        }
        
        if component.IsActive(), let index = cameras.firstIndex(where: { $0.entity == component.entity }) {
            cameras.remove(at: index)
            for i in 0 ..< cameras.count {
                if (cameras[i].depth >= component.depth) {
                    cameras.insert(component, at: i)
                    return
                }
            }
            cameras.append(component)
        }
    }
}
