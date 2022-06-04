//
//  OnboardingPage1View.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingPage1View: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State var volumeIsVisible = false
    
    var body: some View {
        ZStack {
            BgMorphView()
            VStack {
                Spacer()
                HStack {
                    UI.Image.Onboarding.get3DVolume(colorScheme: colorScheme)
                        .opacity(volumeIsVisible ? 1 : 0)
                        .offset(
                            x: volumeIsVisible ? 0 : -50,
                            y: volumeIsVisible ? 0 : 100
                        )
                    Spacer()
                }
                .animation(Animation.easeInOut(duration: 1.5).delay(0.25))
                .onAppear() {
                    volumeIsVisible = true
                }
            }
            VStack {
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.titleMarginTop)
                Text(LocalizedStringKey("onboarding.title"))
                    .font(UI.Font.Onboarding.title)
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.subtitleMarginTop)
                Text(LocalizedStringKey("onboarding.subtitle"))
                    .frame(width: UI.Dimension.Onboarding.subtitleWidth)
                    .font(UI.Font.Onboarding.subtitle)
                    .multilineTextAlignment(.center)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UI.Dimension.Onboarding.getStartedButtonMarginTop)
                } else {
                    Spacer()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(UI.Color.actionButtonBg)
                        .frame(
                            width: UI.Dimension.Onboarding.getStartedButtonWidth * 12 / 13,
                            height: UI.Dimension.Onboarding.getStartedButtonHeight
                        )
                        .offset(x: 0, y: 10)
                        .opacity(0.5)
                        .blur(radius: 10)
                    Button(
                        action: {
                            print("Rounded Button")
                        },
                        label: {
                            Text(LocalizedStringKey("onboarding.get_started"))
                                .frame(
                                    width: UI.Dimension.Onboarding.getStartedButtonWidth,
                                    height: UI.Dimension.Onboarding.getStartedButtonHeight
                                )
                                .foregroundColor(UI.Color.actionButtonText)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .background(UI.Color.actionButtonBg.cornerRadius(10))
                                )
                                .font(UI.Font.actionButton)
                        }
                    )
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Onboarding.getStartedButtonMarginBottom)
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
