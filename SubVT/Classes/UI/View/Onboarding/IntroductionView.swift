//
//  IntroductionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct IntroductionView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var appState: AppState
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    var body: some View {
        ZStack {
            BgMorphView()
                .offset(
                    x: 0,
                    y: UI.Dimension.BgMorph.yOffset(
                        displayState: self.displayState
                    )
                )
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .animation(
                    .easeOut(duration: 0.75),
                    value: self.displayState
                )
                
            // 3D volume
            VStack {
                Spacer()
                HStack {
                    UI.Image.Introduction.iconVolume(colorScheme)
                        .offset(
                            x: UI.Dimension.Introduction.iconVolumeOffset(
                                displayState: self.displayState
                            ).0,
                            y: UI.Dimension.Introduction.iconVolumeOffset(
                                displayState: self.displayState
                            ).1
                        )
                    Spacer()
                }
                .animation(
                    .spring(
                        response: 1.0,
                        dampingFraction: 0.70,
                        blendDuration: 0.0
                    ),
                    value: self.displayState
                )
            }
            .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: UI.Dimension.Introduction.titleMarginTop)
                // text
                Group {
                    Text(LocalizedStringKey("introduction.title"))
                        .font(UI.Font.Introduction.title)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: UI.Dimension.Introduction.subtitleMarginTop)
                    Text(LocalizedStringKey("introduction.subtitle"))
                        .frame(width: UI.Dimension.Introduction.subtitleWidth)
                        .font(UI.Font.Introduction.subtitle)
                        .foregroundColor(Color("Text"))
                        .lineSpacing(UI.Dimension.Common.lineSpacing)
                        .multilineTextAlignment(.center)
                }
                .offset(
                    x: 0,
                    y: UI.Dimension.Introduction.textYOffset(
                        displayState: self.displayState
                    )
                )
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .animation(
                    .easeOut(duration: 0.75),
                    value: self.displayState
                )
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginTop)
                } else {
                    Spacer()
                }
                Button(LocalizedStringKey("introduction.get_started")) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.displayState = .dissolved
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.appState.stage = .onboarding
                        }
                    }
                }
                .buttonStyle(ActionButtonStyle(isEnabled: .constant(true)))
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .offset(
                    x: 0,
                    y: UI.Dimension.Common.actionButtonYOffset(
                        displayState: self.displayState
                    )
                )
                .animation(
                    .easeOut(duration: 0.75),
                    value: self.displayState
                )
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginBottom)
                }
            }
            
        }
        .onAppear() {
            self.displayState = .appeared
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}
