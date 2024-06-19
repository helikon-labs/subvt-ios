//
//  EraReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.11.2022.
//

import Charts
import SwiftUI
import SubVTData

struct EraReportView {
    enum `Type`: Hashable {
        case line
        case bar
    }
    
    struct IntDataPoint: Hashable {
        let x: Int
        let y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    struct BalanceDataPoint: Hashable {
        let x: Int
        let y: Balance
        
        init(_ x: Int, _ y: Balance) {
            self.x = x
            self.y = y
        }
    }
    
    enum Data: Hashable {
        case integer(dataPoints: [IntDataPoint], max: Int? = nil)
        case balance(dataPoints: [BalanceDataPoint], decimals: UInt8 = 2)
    }
}
