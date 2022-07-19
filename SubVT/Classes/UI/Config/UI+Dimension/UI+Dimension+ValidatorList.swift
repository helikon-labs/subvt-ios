//
//  UI+Dimension+ValidatorList.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SwiftUI

extension UI.Dimension {
    enum ValidatorList {
        static var titleMarginLeft: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 8
                } else {
                    return 24
                }
            }
        }
    }
    
    enum ValidatorSummary {
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 18
        static let iconSpacing: CGFloat = 6
        static let balanceTopMargin: CGFloat = 12
    }
}
