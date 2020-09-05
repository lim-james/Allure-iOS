//
//  Extensions.swift
//  Allure
//
//  Created by James on 18/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit
import simd

extension CGRect {
    public func isPointInside(_ point: CGPoint) -> Bool {
        return point.x >= 0 && point.y >= 0 && point.x <= self.width && point.y <= self.height
    }
}

extension CGPoint {
    public func isInside(_ frame: CGRect) -> Bool {
        return self.x >= 0 && self.y >= 0 && self.x <= frame.width && self.y <= frame.height
    }
    
    public static func -(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension UITouch {
    public func isInside(_ view: UIView) -> Bool {
        return self.location(in: view).isInside(view.frame)
    }
}

extension UIColor {
    public convenience init(_ v: vector_float4) {
        self.init(red: CGFloat(v.x),
                  green: CGFloat(v.y),
                  blue: CGFloat(v.z),
                  alpha: 1)
    }
}
