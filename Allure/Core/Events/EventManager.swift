//
//  EventsManager.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

class EventManager {
    
    static private var _instance: EventManager?
    
    static public var Instance: EventManager {
        if let result  = _instance {
            return result
        } else {
            _instance = EventManager()
            return _instance!
        }
    }
    
    private var callbacks: [String: [Handler]]
    
    init() {
        callbacks = [:]
    }
    
    public func Subscribe(name: String, callback: Selector, context: NSObject) {
        let handler = Handler(context: context, callback: callback, subscribed: true)
        
        if let _ = callbacks[name] {
            callbacks[name]!.append(handler)
        } else {
            callbacks[name] = [handler]
        }
    }
    
    public func Trigger(name: String, data: Any? = nil) {
        if let list = callbacks[name] {
            list.forEach { handler in
                if (handler.subscribed) {
                    handler.context.performSelector(
                        onMainThread: handler.callback,
                        with: data, waitUntilDone: true
                    )
                }
            }
        }
    }
    
}
