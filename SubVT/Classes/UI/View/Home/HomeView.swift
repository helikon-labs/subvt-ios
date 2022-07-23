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
    @State private var currentTab: Tab = .network
    @State private var showsTabBar = false
    @State private var showsValidatorList = false
    
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
            // tab content
            ZStack(alignment: .topLeading) {
                NetworkStatusView(
                    showsTabBar: self.$showsTabBar,
                    showsValidatorList: self.$showsValidatorList
                )
                if self.showsValidatorList {
                    ValidatorListView(mode: .inactive, isRunning: $showsValidatorList)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            VStack {
                TabBarView(currentTab: $currentTab)
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
        }
        .onAppear() {
            self.displayState = .appeared
            self.showsTabBar = true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
