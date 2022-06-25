//
//  UI+Dimension+TabBar.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 25.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum TabBar {
        static var height: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 66
                } else {
                    return 74
                }
            }
        }
        static let cornerRadius: CGFloat = 16
    }
}
