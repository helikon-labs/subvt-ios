//
//  OnboardingPage1View.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingPage1View: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Image(colorScheme == .light ? "3DLogoLargeLight" : "3DLogoLargeDark")
                            .padding(0)
                    } else {
                        Image(colorScheme == .light ? "3DLogoLight" : "3DLogoDark")
                            .padding(0)
                    }
                    Spacer()
                }
            }
            VStack {
                Text("Welcome to SubVT")
                    .font(LexendDeca.semiBold.withSize(24))
                Spacer()
                    .frame(height: 18)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
                    .padding(.top, 0)
                    .frame(width: 260)
                    .font(LexendDeca.light.withSize(14))
                Spacer()
            }
            .padding(.top, 143)
            
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPage1View_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage1View()
    }
}
