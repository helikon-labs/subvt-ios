//
//  UIDimension+ValidatorDetails.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 28.07.2022.
//

import SwiftUI

extension UI.Dimension {
    enum ValidatorDetails {
        static var scrollContentMarginTop: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return UI.Dimension.Common.titleMarginTop
                    + UI.Dimension.Common.networkSelectorHeight
                    + UI.Dimension.Common.padding
            } else {
                return UI.Dimension.Common.titleMarginTop
                    + UI.Dimension.Common.networkSelectorHeight
                    + (UI.Dimension.Common.padding / 2)
            }
        }
        static var identiconHeight: CGFloat {
            return 274
        }
        static let identityIconMarginRight: CGFloat = 12
        static let identityIconSize: CGFloat = 24
        static let iconSize: CGFloat = 40
        static let iconContainerMarginBottom: CGFloat = UI.Dimension.Common.bottomNotchHeight
            + UI.Dimension.Common.padding
        static let balancePanelHeight: CGFloat = 62
        static let scrollContentBottomSpacerHeight: CGFloat = iconContainerMarginBottom
            + iconSize
            + UI.Dimension.Common.padding * 2
        static let actionFeedbackViewYOffset: CGFloat = -(iconContainerMarginBottom + iconSize + UI.Dimension.Common.padding)
    }
}
