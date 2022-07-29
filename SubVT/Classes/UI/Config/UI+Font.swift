//
//  UIConfig+Font.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

extension UI {
    enum Font {
        enum Common {
            static let actionButton = LexendDeca.semiBold.withSize(18)
            static var dataPanelTitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(12)
                } else {
                    return LexendDeca.light.withSize(14)
                }
            }
        }
        
        enum Snackbar {
            static let message = LexendDeca.light.withSize(15)
        }
        
        enum Introduction {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(24)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var subtitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
        }
        
        enum Onboarding {
            static let currentPage = LexendDeca.semiBold.withSize(14)
            static let pageCount = LexendDeca.light.withSize(14)
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(22)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var description: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
            static let skipButton = LexendDeca.light.withSize(18)
            static let nextButton = LexendDeca.semiBold.withSize(18)
        }
        
        enum NetworkSelection {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(24)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var subtitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
            static var network: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.medium.withSize(14)
                } else {
                    return LexendDeca.medium.withSize(18)
                }
            }
        }
        
        enum TabBar {
            static let text = LexendDeca.light.withSize(10)
        }
        
        enum NetworkStatus {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(24)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static let networkSelector = LexendDeca.regular.withSize(12)
            static let eraEpochTimestamp = LexendDeca.light.withSize(12)
            static let dataMedium = LexendDeca.semiBold.withSize(20)
            static var dataLarge: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(28)
                } else {
                    return LexendDeca.semiBold.withSize(40)
                }
            }
            static let dataXLarge = LexendDeca.semiBold.withSize(40)
            static let dataSmall = LexendDeca.light.withSize(10)
            static let lastEraTotalReward = LexendDeca.semiBold.withSize(28)
            static let lastEraTotalRewardTicker = LexendDeca.regular.withSize(28)
        }
        
        enum ValidatorList {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(18)
                } else {
                    return LexendDeca.semiBold.withSize(28)
                }
            }
            static let search = LexendDeca.regular.withSize(16)
            static let listSortSectionTitle = LexendDeca.light.withSize(12)
            static let listSortField = LexendDeca.light.withSize(14)
        }
        
        enum ValidatorSummary {
            static let display = LexendDeca.semiBold.withSize(18)
            static let balance = LexendDeca.light.withSize(12)
        }
        
        enum ValidatorDetails {
            static let identityDisplay = LexendDeca.regular.withSize(28)
        }
    }
}
