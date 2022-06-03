//
//  OnboardingPage1View.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingPage1View: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    UIConfig.Image.getOnboarding3DVolume(colorScheme: colorScheme)
                    Spacer()
                }
            }
            VStack {
                Spacer()
                    .frame(height: UIConfig.Dimension.onboardingTitleMarginTop)
                Text(LocalizedStringKey("onboarding.title"))
                    .font(UIConfig.Font.onboardingTitle)
                Spacer()
                    .frame(height: UIConfig.Dimension.onboardingSubtitleMarginTop)
                Text(LocalizedStringKey("onboarding.subtitle"))
                    .frame(width: UIConfig.Dimension.onboardingSubtitleWidth)
                    .font(UIConfig.Font.onboardingSubtitle)
                    .multilineTextAlignment(.center)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UIConfig.Dimension.onboardingGetStartedButtonMarginTop)
                } else {
                    Spacer()
                }
                Button(
                    action: {
                        print("Rounded Button")
                    },
                    label: {
                        Text(LocalizedStringKey("onboarding.get_started"))
                            .frame(
                                width: UIConfig.Dimension.onboardingGetStartedButtonWidth,
                                height: UIConfig.Dimension.onboardingGetStartedButtonHeight
                            )
                            .foregroundColor(UIConfig.Color.actionButtonText)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .background(UIConfig.Color.actionButtonBg.cornerRadius(10))
                            )
                            .font(UIConfig.Font.actionButton)
                    }
                )
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UIConfig.Dimension.onboardingGetStartedButtonMarginBottom)
                }
            }
            
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPage1View_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage1View()
    }
}
