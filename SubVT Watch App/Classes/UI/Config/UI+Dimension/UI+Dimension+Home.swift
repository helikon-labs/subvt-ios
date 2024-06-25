//
//  UI+Dimension+Home.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 25.06.2024.
//

import WatchKit

extension UI.Dimension {
    
    enum Home {
        static var menuIconScale: CGFloat {
            switch WKInterfaceDevice.currentWatchModel {
            case .w44, .w45:
                0.9
            default:
                0.8
            }
        }
        static var menuIconCircleSize: CGFloat {
            switch WKInterfaceDevice.currentWatchModel {
            case .w44, .w45:
                22.0
            default:
                19.0
            }
        }
    }
}
