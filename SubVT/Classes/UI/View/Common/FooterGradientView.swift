//
//  FooterGradientView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 23.07.2022.
//

import SwiftUI

struct FooterGradientView: View {
    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color("Bg"),
                        Color("BgClear")
                    ]
                ),
                startPoint: .bottom,
                endPoint: .top
            ))
            .allowsHitTesting(false)
            .frame(height: UI.Dimension.TabBar.marginBottom
                   + UI.Dimension.TabBar.height * 2)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
    }
}

struct FooterGradientView_Previews: PreviewProvider {
    static var previews: some View {
        FooterGradientView()
    }
}
