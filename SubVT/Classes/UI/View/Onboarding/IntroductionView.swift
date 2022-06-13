//
//  IntroductionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct IntroductionView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var appData: AppData
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    var bgMorphViewYOffset: CGFloat {
        get {
            switch self.displayState {
            case .notAppeared:
                return -100
            case .appeared:
                return 0
            case .dissolved:
                return -100
            }
        }
    }
    
    var textYOffset: CGFloat {
        get {
            switch self.displayState {
            case .notAppeared:
                return -50
            case .appeared:
                return 0
            case .dissolved:
                return 50
            }
        }
    }
    
    var opacity: Double {
        get {
            switch self.displayState {
            case .notAppeared:
                return 0
            case .appeared:
                return 1
            case .dissolved:
                return 0
            }
        }
    }
    
    var iconVolumeOffset: (CGFloat, CGFloat) {
        get {
            switch self.displayState {
            case .notAppeared:
                return (-350, 350)
            case .appeared:
                return (0, 0)
            case .dissolved:
                return (-350, 350)
            }
        }
    }
    
    var buttonYOffset: CGFloat {
        get {
            switch self.displayState {
            case .notAppeared:
                return 70
            case .appeared:
                return 0
            case .dissolved:
                return 70
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            Color("IntroductionBg").ignoresSafeArea()
            BgMorphView()
                .offset(
                    x: 0,
                    y: self.bgMorphViewYOffset
                )
                .opacity(self.opacity)
            // 3D volume
            VStack {
                Spacer()
                HStack {
                    UI.Image.Introduction.iconVolume(colorScheme)
                        .offset(
                            x: self.iconVolumeOffset.0,
                            y: self.iconVolumeOffset.1
                        )
                    Spacer()
                }
                .animation(Animation.easeOut(duration: 0.75).delay(0))
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
                .offset(x: 0,y: self.textYOffset
                )
                .opacity(self.opacity)
                .animation(Animation.easeOut(duration: 0.5))
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
                            withAnimation {
                                self.appData.currentView = .onboarding
                            }
                        }
                    }
                }
                .buttonStyle(ActionButtonStyle())
                .opacity(self.opacity)
                .offset(x: 0, y: self.buttonYOffset)
                .animation(Animation.easeOut(duration: 0.35))
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginBottom)
                }
            }
            
        }
        // .ignoresSafeArea()
        .onAppear() {
            self.displayState = .appeared
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
