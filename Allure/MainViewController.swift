//
//  ViewController.swift
//  Allure
//
//  Created by James on 14/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var manager: CollectionManager!
    
    private var headerContainer: UIView!
    private var header: HeaderViewController!
    
    // canvas
    
    private var canvasContainer: UIView!
    private var canvas: CanvasViewController!
    
    // editor
    
    private var editorContainer: UIView!
    private var editor: EditorViewController!
    
    private var editorHeight: NSLayoutConstraint!
    
    private var editorCornerRadius: CGFloat!
    private var editorMinHeight: CGFloat!
    private var editorMaxHeight: CGFloat {
        return view.frame.height - view.frame.width - header.minHeight
    }
    
    // constraints
    
    private var portraitConstraints: [NSLayoutConstraint]!
    private var landscapeConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CollectionManager()
        
        // Getting window insets
        // - top safe area
        // - bottom safe area
        
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        window.tintColor = .systemPink
        
        // initialising variables
        // - portrait constraints array
        // - landscape constraints array
        
        portraitConstraints = []
        landscapeConstraints = []
        
        // Header
        // - set minimum height
        // - create container
        // - presenting view controller
        // - constraints

        headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        
        header = HeaderViewController()
        header.minHeight = 44
        header.view.translatesAutoresizingMaskIntoConstraints = false
        header.didMove(toParent: self)
        addChild(header)
        headerContainer.addSubview(header.view)
        
        header.heightConstraint = header.view.heightAnchor.constraint(equalToConstant: header.minHeight)
        
        portraitConstraints.append(contentsOf: [
            headerContainer.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            header.view.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: topPadding),
            header.view.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            header.view.leftAnchor.constraint(equalTo: headerContainer.leftAnchor),
            header.view.rightAnchor.constraint(equalTo: headerContainer.rightAnchor),
            header.heightConstraint
        ])
        
        // Canvas
        // - create container
        // - presenting view controller
        // - constraints
        
        canvasContainer = UIView()
        canvasContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasContainer)
        
        canvas = CanvasViewController()
        canvas.view.translatesAutoresizingMaskIntoConstraints = false
        canvas.didMove(toParent: self)
        addChild(canvas)
        canvasContainer.addSubview(canvas.view)
        
        portraitConstraints.append(contentsOf: [
            canvasContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            canvasContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvasContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        landscapeConstraints.append(contentsOf: [
            canvasContainer.topAnchor.constraint(equalTo: view.topAnchor),
            canvasContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasContainer.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        NSLayoutConstraint.FillBounds(child: canvas.view, parent: canvasContainer)
        
        // Editor
        // - setting minimum height and corner radius
        // - create container
        // - pan gesture
        // - embed view controller in navigation view
        // - present navigation view
        // - drag indicator
        // - constraints
        
        editorMinHeight = bottomPadding * 4
        editorCornerRadius = bottomPadding
        
        editorContainer = UIView()
        editorContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editorContainer)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.PanHandler(_:)))
        pan.delegate = self
        editorContainer.addGestureRecognizer(pan)
        
        editor = EditorViewController()
        
        let navigation = UINavigationController(rootViewController: editor)
        navigation.navigationBar.prefersLargeTitles = true
        navigation.view.translatesAutoresizingMaskIntoConstraints = false
        navigation.didMove(toParent: self)
        addChild(navigation)
        editorContainer.addSubview(navigation.view)
        
        let indicator = UIView()
        indicator.backgroundColor = .systemGray3
        indicator.layer.cornerRadius = 2.5
        indicator.translatesAutoresizingMaskIntoConstraints = false
        editorContainer.addSubview(indicator)
        
        editorHeight = editorContainer.heightAnchor.constraint(equalToConstant: editorMinHeight)
        
        portraitConstraints.append(contentsOf: [
            editorContainer.topAnchor.constraint(equalTo: canvasContainer.bottomAnchor),
            editorContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editorContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            editorContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            editorHeight,
            indicator.centerXAnchor.constraint(equalTo: editorContainer.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: editorContainer.layoutMarginsGuide.topAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 35),
            indicator.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        landscapeConstraints.append(contentsOf: [
            editorContainer.topAnchor.constraint(equalTo: view.topAnchor),
            editorContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editorContainer.leftAnchor.constraint(equalTo: canvasContainer.rightAnchor),
            editorContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            editorContainer.widthAnchor.constraint(equalTo: editorContainer.heightAnchor)
        ])
        
        NSLayoutConstraint.FillBounds(child: navigation.view, parent: editorContainer)
        
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        header.SetManager(manager)
        editor.SetEmitter(canvas.emitter)
        manager.emitter = canvas.emitter
        manager.LoadData()
        manager.SetCurrent(name: "Standard")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let dH = editorMaxHeight - editorMinHeight
        let d = editorHeight.constant - editorMinHeight
        let ratio = 1.0 - d / dH
        editorContainer.layer.cornerRadius = ratio * editorCornerRadius
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait(traitCollection: traitCollection)
    }
    
    private func layoutTrait(traitCollection: UITraitCollection) {
        if !portraitConstraints[0].isActive {
           NSLayoutConstraint.activate(portraitConstraints)
        }
        
        // portrait
        if traitCollection.verticalSizeClass == .regular {
            if landscapeConstraints[0].isActive {
                NSLayoutConstraint.deactivate(landscapeConstraints)
            }
            
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            if portraitConstraints[0].isActive {
                NSLayoutConstraint.deactivate(portraitConstraints)
            }
            
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    @objc func PanHandler(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        if abs(translation.x) > abs(translation.y) || abs(velocity.x) > abs(velocity.y) {
            return
        }

        let h = editorHeight.constant
        let newHeight = h - translation.y
        if newHeight <= editorMaxHeight && newHeight >= editorMinHeight {
            editorHeight.constant = newHeight
            gesture.setTranslation(CGPoint.zero, in: view)
        }

        if gesture.state == .ended {
            var duration =  velocity.y < 0 ? Double((h - editorMaxHeight) / -velocity.y) : Double((editorMinHeight - h) / velocity.y)
            duration = duration > 1.3 ? 1 : duration

            if velocity.y >= 0 {
                editorHeight.constant = editorMinHeight
            } else {
                editorHeight.constant = editorMaxHeight
            }

            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        let velocity = gesture.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        let direction = gesture.velocity(in: view).y
        
        let h = editorHeight.constant
        if (h == editorMaxHeight && editor.tableView.contentOffset.y <= 0 && direction > 0) || (h == editorMinHeight) {
            editor.tableView.isScrollEnabled = false
        } else {
            editor.tableView.isScrollEnabled = true
        }
        
        return false
    }
}
