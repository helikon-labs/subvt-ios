//
//  CGFloat.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 12.07.2022.
//

import SwiftUI

extension CGFloat {
    func between(a: CGFloat, b: CGFloat) -> Bool {
        return self >= Swift.min(a, b) && self <= Swift.max(a, b)
    }
}
