//
//  UIConfig+Font.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import WatchKit
import SwiftUI

extension UI {
    enum Font {
        enum Common {
            static let actionButton = LexendDeca.regular.withSize(14)
            static var title: SwiftUI.Font {
                switch WKInterfaceDevice.currentWatchModel {
                case .w44, .w45:
                    LexendDeca.semiBold.withSize(16)
                default:
                    LexendDeca.semiBold.withSize(14)
                }
            }
            static var dataPanelTitle: SwiftUI.Font {
                switch WKInterfaceDevice.currentWatchModel {
                case .w44, .w45:
                    LexendDeca.light.withSize(12)
                default:
                    LexendDeca.light.withSize(11)
                }
            }
            static let dataMedium = LexendDeca.semiBold.withSize(12)
            static let info = LexendDeca.regular.withSize(13)
        }
        
        enum Home {
            static var menuIcon: SwiftUI.Font {
                switch WKInterfaceDevice.currentWatchModel {
                case .w44, .w45:
                    LexendDeca.regular.withSize(14)
                default:
                    LexendDeca.regular.withSize(12)
                }
            }
            static var menuItem: SwiftUI.Font {
                switch WKInterfaceDevice.currentWatchModel {
                case .w44, .w45:
                    return LexendDeca.regular.withSize(16)
                default:
                    return LexendDeca.regular.withSize(14)
                }
            }
        }
        
        enum NetworkStatus {
            static let dataSmall = LexendDeca.regular.withSize(11)
            static let dataLarge: SwiftUI.Font = LexendDeca.semiBold.withSize(20)
            static let dataXLarge: SwiftUI.Font = LexendDeca.semiBold.withSize(22)
            static var eraEpochTimestamp: SwiftUI.Font {
                switch WKInterfaceDevice.currentWatchModel {
                case .w44, .w45:
                    LexendDeca.regular.withSize(12)
                default:
                    LexendDeca.regular.withSize(11)
                }
            }
            static let network = LexendDeca.regular.withSize(13)
        }
        
        enum ValidatorSummary {
            static let display = LexendDeca.semiBold.withSize(12)
            static let balance = LexendDeca.light.withSize(11)
        }
        
        enum Income {
            static let income = LexendDeca.regular.withSize(14)
        }
    }
}
