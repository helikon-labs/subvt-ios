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
                NetworkStatusView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color("Bg"),
                            Color("BgClear")
                        ]
                    ),
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .frame(height: UI.Dimension.TabBar.marginBottom
                       + UI.Dimension.TabBar.height * 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
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
            .ignoresSafeArea()
        }
        .onAppear() {
            self.displayState = .appeared
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
