//
//  IntroductionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SubVTData
import SwiftUI

struct IntroductionView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.hasResetKeychain) private var hasResetKeychain = false
    @AppStorage(AppStorageKey.hasCompletedIntroduction) private var hasCompletedIntroduction = false
    @StateObject private var viewModel = IntroductionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var actionButtonState : ActionButtonView.State = .enabled
    @State private var snackbarIsVisible = false
    
    private func onCreateUserSuccess(user: User) {
        self.actionButtonState = .enabled
        self.displayState = .dissolved
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hasCompletedIntroduction = true
        }
    }
    
    private func onCreateUserError(error: APIError) {
        self.snackbarIsVisible = true
        self.actionButtonState = .enabled
        self.displayState = .appeared
    }
    
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
                ZStack {
                    Button(
                        action: {
                            self.snackbarIsVisible = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.actionButtonState = .loading
                                self.viewModel.createUser(
                                    onSuccess: self.onCreateUserSuccess,
                                    onError: self.onCreateUserError
                                )
                            }
                        },
                        label: {
                            ActionButtonView(
                                title: localized("introduction.get_started"),
                                state: self.actionButtonState
                            )
                        }
                    )
                    .buttonStyle(ActionButtonStyle(state: self.actionButtonState))
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
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginBottom)
                }
            }
            SnackbarView(
                message: localized("introduction.error.create_user"),
                type: .error(canRetry: false)
            ) {
                self.snackbarIsVisible = false
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(
                y: UI.Dimension.Introduction.snackbarYOffset(
                    isVisible: self.snackbarIsVisible
                )
            )
            .opacity(UI.Dimension.Introduction.snackbarOpacity(
                isVisible: self.snackbarIsVisible
            ))
            .animation(
                .spring(),
                value: self.snackbarIsVisible
            )
        }
        .onAppear() {
            self.displayState = .appeared
            if !self.hasResetKeychain {
                SubVTData.reset()
                self.hasResetKeychain = true
                
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
            .preferredColorScheme(.dark)
    }
}
