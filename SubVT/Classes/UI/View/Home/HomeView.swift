//
//  HomeView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 17.06.2022.
//

import SwiftUI

struct HomeView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = NetworkStatusViewModel()
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
            Color("NetworkSelectionOverlayBg")
                .ignoresSafeArea()
            ZStack(alignment: .topLeading) {
                HStack(alignment: .center) {
                    Text(LocalizedStringKey("network_status.title"))
                        .font(UI.Font.NetworkStatus.title)
                        .foregroundColor(Color("Text"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.horizontalPadding,
                bottom: 0,
                trailing: UI.Dimension.Common.horizontalPadding
            ))
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Text("asd")
                }
                .frame(height:66)
                .frame(maxWidth: .infinity)
                .background(Color("TabBarBg"))
                .cornerRadius(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.horizontalPadding,
                bottom: 0,
                trailing: UI.Dimension.Common.horizontalPadding
            ))
        }
        .onAppear() {
            self.displayState = .appeared
            self.viewModel.subscribeToNetworkStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(newPhase)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(PreviewData.appState)
    }
}
