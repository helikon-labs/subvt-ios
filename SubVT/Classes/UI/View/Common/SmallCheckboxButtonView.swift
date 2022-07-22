//
//  SmallCheckboxButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.07.2022.
//

import SwiftUI

struct SmallCheckboxButtonView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    var isChecked: Bool
    var isPressed: Bool
    
    var body: some View {
        if self.isChecked {
            UI.Image.Common.smallCheckboxChecked(
                self.colorScheme
            )
        } else {
            if self.isPressed {
                UI.Image.Common.smallCheckboxPressed(
                    self.colorScheme
                )
            } else {
                UI.Image.Common.smallCheckboxUnchecked(
                    self.colorScheme
                )
            }
        }
    }
}

struct SmallCheckboxButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SmallCheckboxButtonView(isChecked: false, isPressed: false)
    }
}
