//
//  CanvasViewController.swift
//  Allure
//
//  Created by James on 25/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit
import MetalKit

class CanvasViewController: UIViewController, MTKViewDelegate {
    
    // engine properties
    
    private var entities: EntityManager!
    private var systems: SystemManager!
    private var scripts: ScriptSystem!
    
    private var timer: CADisplayLink!
    
    // UI elements
    
    private var canvas: MTKView!
    
    // game objects
    
    private var mainCamera: Camera!
    private(set) var emitter: ParticleEmitter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize member attributes
        entities = EntityManager()
        systems = SystemManager(entities: entities)
        scripts = ScriptSystem(entities: entities)
        
        // add systems
        let renderer: RenderSystem = systems.Add(frameIndex: 0)
        let _: ParticleSystem = systems.Add(frameIndex: 1)
        
        scripts.Awake()
        
        canvas = MTKView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        renderer.SetContext(view: canvas)
        
        if let canvas = canvas {
            NSLayoutConstraint.FillBounds(child: canvas, parent: view)
        }
        
        // set up game objects
                
        let cameraObject = entities.Create()
        
        if let transform: Transform = entities.GetComponent(entity: cameraObject) {
            transform.translation = vector_float3(0.0, 0.0, -1.0)
        }
        
        if let camera: Camera = entities.AddComponent(entity: cameraObject) {
            camera.SetActive(true)
            camera.size = 10.0
            camera.match = 1
            camera.clearColor = vector_float4(repeating: 0)
            
            mainCamera = camera
        }
        
        let background = entities.Create()

        if let transform: Transform = entities.GetComponent(entity: background) {
            transform.scale = vector_float3(100, 100, 1)
        }

        if let render: Render = entities.AddComponent(entity: background) {
            render.SetActive(true)
            render.tint = vector_float4(repeating: 0.25)
            render.uvRect = vector_float4(0, 0, 10, 10)
            render.texture = "tile"
        }
        
        let cursor = entities.Create()

        if let emitter: ParticleEmitter = entities.AddComponent(entity: cursor) {
            emitter.SetActive(true)
            self.emitter = emitter
        }
        
        if let follow: FollowScript = entities.AddComponent(entity: cursor) {
            follow.SetActive(true)
            follow.followSpeed = 100
            follow.returnSpeed = 50
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
        // start scripts
        scripts.Start()
        
        // start game loop
        timer = CADisplayLink(target: self, selector: #selector(CanvasViewController.Step))
        timer.add(to: .main, forMode: .default)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scripts.Stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = vector_float2(Float(canvas.frame.width), Float(canvas.frame.height))
        EventManager.Instance.Trigger(name: "CANVAS_RESIZE", data: size)
    }       
    
    @objc func Step() {
        autoreleasepool {
            let dt = Float(timer.targetTimestamp - timer.timestamp)
            systems.Update(dt: dt)
            scripts.Update(dt: dt)
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        TouchHandler(touches, isDown: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        TouchHandler(touches, isDown: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        TouchHandler(touches, isDown: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        TouchHandler(touches, isDown: false)
    }
    
    private func TouchHandler(_ touches: Set<UITouch>, isDown: Bool) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: view)
        
        let worldPosition = mainCamera.ScreenToWorldSpace(
            mousePosition: vector_float2(Float(position.x), Float(position.y))
        )
        
        EventManager.Instance.Trigger(name: "TOUCH_INPUT", data: TouchInput(isDown: isDown, position: worldPosition))
    }
}
