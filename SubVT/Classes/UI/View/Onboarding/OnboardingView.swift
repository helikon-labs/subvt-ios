//
//  Onboarding.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            OnboardingPage1View()
            OnboardingPage2View()
            OnboardingPage3View()
            OnboardingPage4View()
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
        .onAppear(perform: {
            UIScrollView.appearance().bounces = false
         })
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
