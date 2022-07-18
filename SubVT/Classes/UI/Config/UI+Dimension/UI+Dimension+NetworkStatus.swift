//
//  UI+Dimension+NetworkStatus.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

extension UI.Dimension {
    enum NetworkStatus {
        static var connectionStatusMarginLeft = UI.Dimension(4, 9)
        static var connectionStatusSize = UI.Dimension(7, 10)
        static let networkIconSize: CGFloat = 18
        static let networkSelectorPadding: CGFloat = 10
        static var validatorCountPanelHeight = UI.Dimension(128, 190)
        static var scrollContentMarginBottom: CGFloat {
            get {
                return UI.Dimension.TabBar.marginBottom
                + UI.Dimension.TabBar.height
            }
        }
        static var blockNumberViewHeight: CGFloat = 124
        static var blockWaveViewSize = UI.Dimension(40, 74)
        static var lastEraTotalRewardViewHeight = UI.Dimension(98, 112)
        static let validatorBackingsViewHeight = UI.Dimension(112, 112)
    }
}
