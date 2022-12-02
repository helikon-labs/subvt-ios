//
//  Balance.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.12.2022.
//

import Charts
import Foundation
import SubVTData

extension Balance: Plottable {
    public typealias PrimitivePlottable = Double
    
    public var primitivePlottable: Double {
        Double(self.value)
    }
    
    public init?(primitivePlottable: Double) {
        self.init(integerLiteral: UInt64(primitivePlottable))
    }
}
