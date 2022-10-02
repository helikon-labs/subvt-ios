//
//  HomeView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 17.06.2022.
//

import SubVTData
import SwiftUI

struct HomeView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var currentTab: Tab = .myValidators
    @State private var showsTabBar = false
    
    private var tabBarYOffset: CGFloat {
        get {
            if self.showsTabBar {
                return 0
            } else {
                let offset = UI.Dimension.TabBar.height + UI.Dimension.TabBar.marginBottom
                return offset
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Bg")
                    .ignoresSafeArea()
                    .zIndex(1)
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
                    .zIndex(2)
                // tab content
                NetworkStatusView()
                    .zIndex((self.currentTab == .network) ? 3.0 : 0.0)
                MyValidatorsView()
                    .zIndex((self.currentTab == .myValidators) ? 3.0 : 0.0)
                NotificationsView()
                    .zIndex((self.currentTab == .notifications) ? 3.0 : 0.0)
                // tab bar
                VStack {
                    TabBarView(currentTab: self.$currentTab)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    Spacer()
                        .frame(height: UI.Dimension.TabBar.marginBottom)
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.padding
                ))
                .offset(
                    x: 0,
                    y: self.tabBarYOffset
                )
                .animation(.easeInOut(duration: 0.5), value: self.showsTabBar)
                .ignoresSafeArea()
                .zIndex(4)
            }
        }
        //.navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(.stack)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.displayState = .appeared
                self.showsTabBar = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
