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
}
