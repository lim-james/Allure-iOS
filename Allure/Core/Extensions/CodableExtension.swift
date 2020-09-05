//
//  Codable.swift
//  Allure
//
//  Created by James on 22/3/20.
//  Copyright © 2020 jams. All rights reserved.
//

import Foundation

extension Encodable {
    public func ToDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try  JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Decodable {
    public mutating func Parse(from: Any) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sszzz"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode(Self.self, from: data)
    }
}
