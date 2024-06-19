//
//  UIConfig+Image.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI
import SubVTData

extension UI {
    enum Image {
        enum Common {
            static let iconWithLogo = SwiftUI.Image("IconWithLogo")
            static func networkIcon(
                network: Network
            ) -> SwiftUI.Image {
                return SwiftUI.Image("\(network.chain.capitalized)Icon")
            }
        }
        
        enum Home {
            static let iconWithLogo = SwiftUI.Image("IconWithLogoHome")
        }
    }
}
