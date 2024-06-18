//
//  OnboardingView.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 17.06.2024.
//

import Foundation
import SwiftUI
import WatchConnectivity

struct OnboardingView: View {
    @AppStorage(WatchAppStorageKey.initialSyncInProgress) private var initialSyncInProgress = false
    @AppStorage(WatchAppStorageKey.initialSyncFailed) private var initialSyncFailed = false
    @AppStorage(WatchAppStorageKey.initialSyncCompleted) private var initialSyncCompleted = false
    @AppStorage(WatchAppStorageKey.hasBeenOnboarded) private var hasBeenOnboarded = false
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack(alignment: .center) {
            UI.Image.Common.iconWithLogo
            Spacer()
                .frame(height: UI.Dimension.Common.listItemSpacing * 2)
            if !WCSession.isSupported() {
                Text(localized("watch.onboarding.connectivity_not_supported"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
            } else if !WCSession.default.isCompanionAppInstalled {
                Text(localized("watch.onboarding.companion_app_not_installed"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
            } else if self.initialSyncInProgress {
                Text(localized("watch.onboarding.initial_sync_progress"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
            } else if !self.initialSyncCompleted && WCSession.default.isReachable {
                Text(localized("watch.onboarding.connectivity_not_reachable"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
            } else if self.initialSyncFailed {
                Text(localized("watch.onboarding.initial_sync_failed"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
                Spacer()
                Button {
                    self.viewModel.sendInitialSyncMessage()
                } label: {
                    Text(localized("common.retry"))
                        .font(UI.Font.Common.actionButton)
                        .foregroundColor(Color("Text"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(UI.Dimension.Common.lineSpacing)
                        .frame(alignment: .bottom)
                }
            } else if !self.hasBeenOnboarded {
                Text(localized("watch.onboarding.onboarding_not_complete"))
                    .font(UI.Font.Onboarding.info)
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: 0,
            trailing: UI.Dimension.Common.padding
        ))
    }
}
