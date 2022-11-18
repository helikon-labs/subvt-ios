//
//  Dictionary.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.11.2022.
//

import Foundation

extension Dictionary: RawRepresentable where Key == UInt64, Value == [String] {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),  // convert from String to Data
              let result = try? JSONDecoder().decode([UInt64:[String]].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),   // data is Data type
              let result = String(data: data, encoding: .utf8) // coerce NSData to String
        else {
            return "[:]"  // empty Dictionary rspresented as String
        }
        return result
    }

}
