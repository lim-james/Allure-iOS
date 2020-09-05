//
//  Handler.swift
//  Allure
//
//  Created by James on 16/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

struct Handler {
    var context: NSObject
    var callback: Selector
    var subscribed: Bool
}
