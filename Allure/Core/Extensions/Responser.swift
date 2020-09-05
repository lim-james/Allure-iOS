//
//  Responser.swift
//  Allure
//
//  Created by James on 23/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import UIKit

extension UIResponder {
    func next<U: UIResponder>(of type: U.Type = U.self) -> U? {
        return self.next.flatMap({ $0 as? U ?? $0.next() })
    }
}
