//
//  Component.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

struct State: OptionSet {
    let rawValue: Int

    static let Active       = State(rawValue: 1 << 0)
    static let Dynamic      = State(rawValue: 1 << 1)
}

class Component: NSObject, TypeName {

    public var entity: Int
    private var state: State
    
    static func == (lhs: Component, rhs: Component) -> Bool {
        return lhs.entity == rhs.entity
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Component else { return false }
        return self.entity == other.entity
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(entity)
        return hasher.finalize()
    }
    
    required override init() {
        entity = 0
        state = [State.Active, State.Dynamic]
    }
    
    public func Initialize() {
        state = [State.Active, State.Dynamic]
    }
    
    public func IsActive() -> Bool {
        return state.contains(State.Active)
    }
    
    public func SetActive(_ _state: Bool) {
        if _state {
            state.insert(State.Active)
        } else {
            state.remove(State.Active)
        }
    }
    
    public func IsDynamic() -> Bool {
        return state.contains(State.Dynamic)
    }
    
    public func SetDynamic(_ _state: Bool) {
        if _state {
            state.insert(State.Dynamic)
        } else {
            state.remove(State.Dynamic)
        }
    }
    
    public func Debug() {
        print("Entity: ", entity)
    }
    
}
