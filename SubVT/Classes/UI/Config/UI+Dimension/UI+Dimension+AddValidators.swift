//
//  UI+Dimension+AddValidators.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 21.09.2022.
//

import SwiftUI

extension UI.Dimension {
    enum AddValidators {
        static let networkIconSize = UI.Dimension(24, 24)
        
        static let snackbarHiddenYOffset: CGFloat = 92
        static let snackbarVisibleYOffset: CGFloat = -UI.Dimension.Common.bottomNotchHeight - UI.Dimension.Common.padding
    }
}
