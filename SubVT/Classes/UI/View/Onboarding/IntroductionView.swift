//
//  IntroductionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct IntroductionView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State var initialized = false
    
    var body: some View {
        ZStack {
            BgMorphView()
                .offset(
                    x: 0,
                    y: initialized ? 0 : -100
                )
            VStack {
                Spacer()
                HStack {
                    UI.Image.Onboarding.get3DVolume(colorScheme: colorScheme)
                        .offset(
                            x: initialized ? 0 : -50,
                            y: initialized ? 0 : 100
                        )
                    Spacer()
                }
                .animation(Animation.easeOut(duration: 1.0).delay(0))
            }
            VStack {
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.titleMarginTop)
                Group {
                    Text(LocalizedStringKey("onboarding.title"))
                        .font(UI.Font.Onboarding.title)
                    Spacer()
                        .frame(height: UI.Dimension.Onboarding.subtitleMarginTop)
                    Text(LocalizedStringKey("onboarding.subtitle"))
                        .frame(width: UI.Dimension.Onboarding.subtitleWidth)
                        .font(UI.Font.Onboarding.subtitle)
                        .multilineTextAlignment(.center)
                }
                .offset(
                    x: 0,
                    y: initialized ? 0 : -30
                )
                .opacity(
                    initialized ? 1 : 0
                )
                .animation(
                    Animation
                        .easeOut(duration: 0.5)
                )
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
                .opacity(
                    initialized ? 1 : 0
                )
                .offset(
                    x: 0,
                    y: initialized ? 0 : 70
                )
                .animation(
                    Animation
                        .easeOut(duration: 0.5)
                )
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(
                            height: UI.Dimension.Onboarding.getStartedButtonMarginBottom
                        )
                }
            }
            
        }
        .ignoresSafeArea()
        .onAppear() {
            initialized = true
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
