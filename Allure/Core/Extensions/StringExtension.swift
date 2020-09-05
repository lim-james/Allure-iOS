//
//  StringExtension.swift
//  Allure
//
//  Created by James on 23/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

extension String {
    
    public func Separate() -> String {
        var result = ""
        
        for c in self {
            if c.isUppercase {
                result += " "
            }
            
            result.append(c)
        }
        
        return result.capitalized
    }
    
}
