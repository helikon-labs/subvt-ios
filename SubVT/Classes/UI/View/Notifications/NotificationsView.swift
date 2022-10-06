//
//  NotificationsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import CoreData
import SwiftUI

struct NotificationsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage(AppStorageKey.apnsIsEnabled) private var apnsIsEnabled = false
    @AppStorage(AppStorageKey.apnsSetupHasFailed) private var apnsSetupHasFailed = false
    @AppStorage(AppStorageKey.hasCreatedDefaultNotificationRules) private var hasCreatedDefaultNotificationRules = false
    @StateObject private var viewModel = NotificationsViewModel()
    @FetchRequest(sortDescriptors: []) var notifications: FetchedResults<Notification>
    @State private var headerMaterialOpacity = 0.0
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 0) {
                    Text(localized("notifications.title"))
                        .font(UI.Font.Common.tabViewTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(width: UI.Dimension.Common.padding)
                }
                Spacer()
                NavigationLink {
                    NotificationRulesView()
                } label: {
                    ZStack {
                        UI.Image.Notifications.settingsIcon(self.colorScheme)
                    }
                    .frame(width: 36, height: 36)
                    .background(Color("NetworkSelectorClosedBg"))
                    .cornerRadius(UI.Dimension.Common.cornerRadius)
                }
                .buttonStyle(PushButtonStyle())
                .disabled(!self.hasCreatedDefaultNotificationRules)
                .opacity(!self.hasCreatedDefaultNotificationRules ? UI.Value.disabledControlOpacity : 1.0)
            }
            .frame(height: UI.Dimension.Common.networkSelectorHeight)
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
        .background(
            VisualEffectView(effect: UIBlurEffect(
                style: .systemUltraThinMaterial
            ))
            .cornerRadius(
                UI.Dimension.Common.headerBlurViewCornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
            .opacity(self.headerMaterialOpacity)
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            headerView
                .zIndex(2)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: 0) {
                        Spacer()
                            .id(0)
                            .frame(height: 20)
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                    .background(GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                    })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        self.headerMaterialOpacity = min(max($0, 0) / 40.0, 1.0)
                    }
                }
            }
            .zIndex(0)
            .disabled(self.notifications.isEmpty)
            if !self.apnsIsEnabled {
                VStack {
                    Text(localized("notifications.apns_disabled"))
                        .font(UI.Font.Notifications.noNotifications)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: UI.Dimension.Common.dataPanelSpacing)
                    Button {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    } label: {
                        ZStack {
                            Text(localized("notifications.enable_notifications"))
                                .font(UI.Font.Notifications.enableNotifications)
                                .foregroundColor(Color("EnablePushNotificationsButtonText"))
                        }
                        .frame(
                            width: UI.Dimension.Notifications.enableNotificationsButtonWidth,
                            height: UI.Dimension.Notifications.enableNotificationsButtonHeight,
                            alignment: .center
                        )
                        .background(Color("TabBarBg"))
                        .cornerRadius(UI.Dimension.Common.cornerRadius)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                    .buttonStyle(PushButtonStyle())

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(1)
            } else if self.apnsSetupHasFailed {
                VStack {
                    Text(localized("notifications.apns_setup_has_failed"))
                        .font(UI.Font.Notifications.noNotifications)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: UI.Dimension.Common.dataPanelSpacing)
                    Button {
                        UIApplication.shared.registerForRemoteNotifications()
                    } label: {
                        ZStack {
                            Text(localized("common.retry"))
                                .font(UI.Font.Notifications.enableNotifications)
                                .foregroundColor(Color("EnablePushNotificationsButtonText"))
                        }
                        .frame(
                            width: UI.Dimension.Notifications.enableNotificationsButtonWidth,
                            height: UI.Dimension.Notifications.enableNotificationsButtonHeight,
                            alignment: .center
                        )
                        .background(Color("TabBarBg"))
                        .cornerRadius(UI.Dimension.Common.cornerRadius)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                    .buttonStyle(PushButtonStyle())

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(1)
            } else if !self.hasCreatedDefaultNotificationRules {
                ZStack {
                    Text(localized("notifications.apns_setup_in_progress"))
                        .font(UI.Font.Notifications.noNotifications)
                        .foregroundColor(Color("Text"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(1)
            } else if self.notifications.isEmpty {
                ZStack {
                    Text(localized("notifications.no_notifications"))
                        .font(UI.Font.Notifications.noNotifications)
                        .foregroundColor(Color("Text"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(1)
            }
            FooterGradientView()
                .zIndex(1)
        }
        .navigationBarHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            NotificationUtil.requestAPNSAuthorization { granted in
                self.apnsIsEnabled = granted
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                if !self.apnsIsEnabled {
                    NotificationUtil.requestAPNSAuthorization { granted in
                        self.apnsIsEnabled = granted
                        if granted {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                } else if !self.hasCreatedDefaultNotificationRules {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            default:
                break
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
