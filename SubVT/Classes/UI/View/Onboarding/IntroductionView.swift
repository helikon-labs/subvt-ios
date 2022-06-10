//
//  IntroductionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct IntroductionView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State var hasAppeared = false
    
    var body: some View {
        ZStack {
            // background color morph
            BgMorphView()
                .offset(
                    x: 0,
                    y: hasAppeared ? 0 : -100
                )
            // 3D volume
            VStack {
                Spacer()
                HStack {
                    UI.Image.Onboarding.get3DVolume(colorScheme: colorScheme)
                        .offset(
                            x: hasAppeared ? 0 : -50,
                            y: hasAppeared ? 0 : 100
                        )
                    Spacer()
                }
                .animation(Animation.easeOut(duration: 1.0).delay(0))
            }
            VStack {
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.titleMarginTop)
                // text
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
                    y: hasAppeared ? 0 : -30
                )
                .opacity(
                    hasAppeared ? 1 : 0
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
                Button(LocalizedStringKey("onboarding.get_started")) {
                    print("button pressed")
                }
                .buttonStyle(ActionButtonStyle())
                .opacity(
                    hasAppeared ? 1 : 0
                )
                .offset(
                    x: 0,
                    y: hasAppeared ? 0 : 70
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
            hasAppeared = true
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
