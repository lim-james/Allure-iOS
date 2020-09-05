//
//  ParticleSystem.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import simd
import UIKit

class ParticleSystem: System {
    
    private let MAX_THREADS = 8
    
    private var device: MTLDevice!
    private var library: MTLLibrary!
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLComputePipelineState!
    
    private var emitters: [ParticleEmitter: ([vector_float2], [Int])] = [:]
    
    override public func Initialize() {
        EventManager.Instance.Subscribe(name: "NEW_DEVICE", callback: #selector(ParticleSystem.DeviceHandler(_:)), context: self)
        EventManager.Instance.Subscribe(name: "EMITTER_ACTIVE", callback: #selector(ParticleSystem.EmitterActiveHandler(_:)), context: self)
        EventManager.Instance.Subscribe(name: "EMITTER_MASK", callback: #selector(ParticleSystem.EmitterMaskHandler(_:)), context: self)
    }
    
    override public func Update(dt: Float) {
        for emitter in emitters.keys {
            let emitterTransform: Transform = entities.GetComponent(entity: emitter.entity)!
            let position = emitterTransform.translation
            
            for i in (0 ..< emitters[emitter]!.1.count).reversed() {
                let id = emitters[emitter]!.1[i]

                let particle: Particle = entities.GetComponent(entity: id)!
                if particle.age < 0 {
                    particle.age += dt
                    continue
                }

                let transform: Transform = entities.GetComponent(entity: id)!
                let render: TintRender = entities.GetComponent(entity: id)!

                transform.translation += particle.velocity * dt
                particle.velocity += emitter.gravity * dt

                let diff = transform.translation - position
                let len = length(diff)
                if len > 0.0 {
                    let vAccelRad = Math.RandomRange(emitter.accelRadRange)
                    let dir = diff / len
                    particle.velocity += (emitter.accelRad + vAccelRad) * dt * dir
                }
	
                particle.velocity *= 1.0 - (emitter.drag * dt)

                let ratio = particle.age / particle.lifetime

                let dSize = particle.endSize - particle.startSize
                transform.scale = dSize * ratio + particle.startSize

                let dColor = particle.endColor - particle.startColor
                render.tint = dColor * ratio + particle.startColor

                particle.age += dt

                if particle.age >= particle.lifetime {
                    entities.Destroy(id: id)
                    emitters[emitter]!.1.remove(at: i)
                }
            }
            
            if !emitter.IsActive() {
                continue
            }
            
            if emitter.duration > 0 {
                if emitter.age > emitter.duration {
                    if emitter.loop && emitters[emitter]!.1.isEmpty {
                        emitter.age = 0.0
                    } else {
                        continue
                    }
                }

                emitter.age += dt
            }
            
            if emitter.age < 0 {
                emitter.age += dt
                continue
            }
            
            emitter.spawnTimer -= dt
            if emitter.spawnTimer <= 0.0 {
                let spawnPositions = emitters[emitter]!.0
                
                var burst = max(0, emitter.burstAmount)
                if emitter.duration > 0 && !spawnPositions.isEmpty {
                    burst = spawnPositions.count
                }
                
                for _ in 0 ..< burst {
                    let entity = CreateParticle()
                    emitters[emitter]!.1.append(entity)

                    let particle: Particle = entities.GetComponent(entity: entity)!
                    let transform: Transform = entities.GetComponent(entity: entity)!
                    let render: TintRender = entities.GetComponent(entity: entity)!

                    particle.age = -emitter.delay
                    particle.lifetime = emitter.lifetime + Math.RandomRange(emitter.lifetimeRange)

                    var offset: vector_float3!
                    var direction: vector_float3!
                    
                    if emitter.mask == "" || spawnPositions.isEmpty {
                        offset = Math.RandomRange(emitter.positionRange)
                        
                        let vAngle = Math.ToRad * (transform.rotation + emitter.angle + Math.RandomRange(emitter.angleRange))
                        direction = vector_float3(sin(vAngle.z), cos(vAngle.z), 0.0)
                    } else {
                        offset = vector_float3(spawnPositions[emitter.spawnIndex], 0) * emitter.positionRange

                        emitter.spawnIndex += 1
                        if emitter.spawnIndex >= spawnPositions.count {
                            emitter.spawnIndex = 0
                        }
                        
                        direction = offset
                    }
                                  
                    transform.translation = position + emitter.offset + offset

                    let vSpeed = Math.RandomRange(emitter.speedRange)
                    // made for 2D
                    particle.velocity = (emitter.speed + vSpeed) * direction

                    particle.startSize = emitter.startSize + Math.RandomRange(emitter.startSizeRange)
                    particle.endSize = emitter.endSize + Math.RandomRange(emitter.endSizeRange)
                    transform.scale = particle.startSize

                    // color
                    particle.startColor = emitter.startColor + Math.RandomRange(emitter.startColorRange)
                    particle.endColor = emitter.endColor + Math.RandomRange(emitter.endColorRange)
                    render.tint = particle.startColor

                    render.SetActive(true)
                    particle.SetActive(true)
                }

                emitter.spawnTimer = emitter.spawnInterval
            }
        }
    }
    
    @objc private func DeviceHandler(_ data: Any) {
        guard let _device = data as? MTLDevice else {
            fatalError("Invalid event type.")
        }
        
        device = _device
        
        guard let _library = device.makeDefaultLibrary() else {
            fatalError("Failed to make device default library.")
        }
        library = _library
        
        guard let maskFunction = library.makeFunction(name: "get_mask") else {
            fatalError("Failed to make function \"get_mask\".")
        }
        
        do {
            pipelineState = try device.makeComputePipelineState(function: maskFunction)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        guard let _commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to make command queue.")
        }
        commandQueue = _commandQueue
    }
    
    @objc private func EmitterActiveHandler(_ data: Any) {
        guard let component = data as? ParticleEmitter else {
            fatalError("Invalid event type.")
        }
        
        guard let _ = emitters[component] else {
            let spawnPositions = GetSpawnPositions(emitter: component)
            emitters[component] = (spawnPositions, [])
            return
        }
    }
    
    @objc private func EmitterMaskHandler(_ data: Any) {
        guard let component = data as? ParticleEmitter else {
            fatalError("Invalid event type.")
        }
        
        if let _ = emitters[component] {
            emitters[component]!.0 = GetSpawnPositions(emitter: component)
        }
    }
    
    private func CreateParticle() -> Int {
        let id = entities.Create()
        let _: TintRender = entities.AddComponent(entity: id)!
        let _: Particle = entities.AddComponent(entity: id)!
        
        return id
    }
    
    private func GetSpawnPositions(emitter: ParticleEmitter) -> [vector_float2] {
        if emitter.mask == "" { return [] }
        guard let uiImage = UIImage(named: emitter.mask) else { return [] }
        guard let cgImage = uiImage.cgImage else { return [] }
        let loader = MTKTextureLoader(device: device)
        
        var texture: MTLTexture!
        
        // create textures
        do {
            texture = try loader.newTexture(cgImage: cgImage, options: nil)
        } catch {
            print(error.localizedDescription)
            return []
        }
        
        guard let buffer = commandQueue.makeCommandBuffer() else {
            fatalError("Failed to make command buffer.")
        }
        
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            fatalError("Failed to make command encoder.")
        }
        
        let length = texture.width * texture.height
        let bufferSize = length * MemoryLayout<Bool>.size
        
        var maskColorValue = emitter.maskColor
        var thresholdValue = emitter.threshold
        
        let mask = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        let maskColor = device.makeBuffer(bytes: UnsafeRawPointer(&maskColorValue), length: MemoryLayout<vector_float4>.size, options: .storageModeShared)
        let threshold = device.makeBuffer(bytes: UnsafeRawPointer(&thresholdValue), length: MemoryLayout<vector_float4>.size, options: .storageModeShared)
        
        let groupSize = MTLSize(width: 16, height: 16, depth: 1)
        var groupCount = MTLSize()
        groupCount.width = (texture.width + groupSize.width - 1) / groupSize.width
        groupCount.height = (texture.height + groupSize.height - 1) / groupSize.height
        groupCount.depth = 1
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setTexture(texture, index: 0)
        encoder.setBuffer(mask, offset: 0, index: 1)
        encoder.setBuffer(maskColor, offset: 0, index: 2)
        encoder.setBuffer(threshold, offset: 0, index: 3)
        encoder.dispatchThreadgroups(groupCount, threadsPerThreadgroup: groupSize)
        encoder.endEncoding()
        
        buffer.commit()
        buffer.waitUntilCompleted()
        
        var result: [vector_float2] = []
        
        guard let contents = mask?.contents() else { return [] }
        for i in 0 ..< length {
            let current = contents.load(fromByteOffset: i, as: Bool.self)
            if current {
                result.append(vector_float2(
                    Float(i % texture.width) / Float(texture.width) - 0.5,
                    0.5 - Float(i / texture.width) / Float(texture.height)
                ))
            }
        }
        
        return result
    }
    
    private func RandomData(of length: Int) -> [Float] {
        var result: [Float] = []
        
        for _ in 0 ..< length {
            result.append(Float.random(in: 0...100))
        }
        
        return result
    }
    
    private func Print(buffer: MTLBuffer, count: Int) {
        let contents = buffer.contents()
        let stride = MemoryLayout<Float>.size
        
        var arr: [Float] = []
        
        for i in 0 ..< count {
            arr.append(contents.load(fromByteOffset: i * stride, as: Float.self))
        }
        
        print(arr)
    }
}
