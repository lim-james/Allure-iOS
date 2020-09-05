//
//  AttributesTableDatasouRCE.swift
//  Allure
//
//  Created by James on 19/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit
import simd

class AttributesDataSource: NSObject, UITableViewDataSource {
    
    private var mirror: Mirror?
    
    public var emitter: ParticleEmitter! {
        didSet {
            mirror = Mirror(reflecting: emitter!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mirror = mirror {
            return mirror.children.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let mirror = mirror {
            let children = mirror.children
            let start = children.startIndex
            let end = children.endIndex
            guard let currentIndex = children.index(start, offsetBy: indexPath.row, limitedBy: end) else {
                return cell
            }
            let child = children[currentIndex]
            
            let reflectionType = type(of: child.value)
            if reflectionType == Int.self {
                if let intCell = tableView.dequeueReusableCell(withIdentifier: "Int", for: indexPath) as? IntAttributeCell {
                    intCell.emitter = emitter
                    intCell.path = child.label
                    
                    cell = intCell
                }
            } else if reflectionType == Float.self {
                if let floatCell = tableView.dequeueReusableCell(withIdentifier: "Float", for: indexPath) as? FloatAttributeCell {
                    floatCell.emitter = emitter
                    floatCell.path = child.label
                    
                    cell = floatCell
                }
            } else if reflectionType == Bool.self {
                if let boolCell = tableView.dequeueReusableCell(withIdentifier: "Bool", for: indexPath) as? BoolAttributeCell {
                    boolCell.emitter = emitter
                    boolCell.path = child.label
                    
                    cell = boolCell
                }
            } else if reflectionType == vector_float3.self {
                if let vector3Cell = tableView.dequeueReusableCell(withIdentifier: "Vector3", for: indexPath) as? Vector3AttributeCell {
                    vector3Cell.emitter = emitter
                    vector3Cell.path = child.label
                    
                    cell = vector3Cell
                }
            } else if reflectionType == vector_float4.self {
                if let colorCell = tableView.dequeueReusableCell(withIdentifier: "Color", for: indexPath) as? ColorAttributeCell {
                    colorCell.emitter = emitter
                    colorCell.path = child.label
                    
                    cell = colorCell
                }
            }
            
//            cell.textLabel?.text = child.label
            
//            print()
        }
        
        return cell
    }
    
}
