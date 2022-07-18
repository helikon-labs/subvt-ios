//
//  ValidatorListView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @StateObject private var viewModel = ValidatorListViewModel()
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @Binding var isRunning: Bool
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: UI.Dimension.Common.titleMarginTop)
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        Button(
                            action: {
                                self.viewModel.unsubscribe()
                                self.displayState = .dissolved
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 1.0) {
                                        self.isRunning = false
                                    }
                            },
                            label: {
                                BackButtonView()
                            }
                        )
                        .buttonStyle(BackButtonStyle())
                        Spacer()
                            .frame(width: UI.Dimension.ValidatorList.titleMarginLeft)
                        Text(localized("active_validator_list.title"))
                            .font(UI.Font.ValidatorList.title)
                            .foregroundColor(Color("Text"))
                    }
                    .opacity(1.0)
                    .modifier(PanelAppearance(0, self.displayState))
                    Spacer()
                    NetworkSelectorButtonView()
                        .modifier(PanelAppearance(1, self.displayState))
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding
            ))
            .zIndex(1)
            
        }
        .ignoresSafeArea()
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            self.displayState = .appeared
            self.viewModel.subscribeToValidatorList(network: self.network)
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(newPhase)
        }
    }
}

struct ValidatorListView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorListView(isRunning: .constant(true))
    }
}
