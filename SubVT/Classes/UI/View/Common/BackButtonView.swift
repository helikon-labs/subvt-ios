//
//  BackButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SwiftUI

struct BackButtonView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        UI.Image.Common.backArrow(self.colorScheme)
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Button(
            action: {},
            label: {
                BackButtonView()
            }
        )
        .buttonStyle(PushButtonStyle())
    }
}
