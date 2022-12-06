//
//  UIConfig+Dimension.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import UIKit
import SwiftUI

extension UI {
    struct Dimension {
        let phone: CGFloat
        let tablet: CGFloat
        
        init(_ phone: CGFloat, _ tablet: CGFloat) {
            self.phone = phone
            self.tablet = tablet
        }
        
        func get() -> CGFloat {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return self.phone
            } else {
                return self.tablet
            }
        }
    }
}
