//
//  NetworkSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.06.2022.
//

import SwiftUI
import SubVTData

struct NetworkSelectionView: View {
    @EnvironmentObject var appData: AppData
    @StateObject private var viewModel = NetworkSelectionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var selectedNetwork: Network? = nil
    
    private let gridItemLayout = [
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize)),
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize))
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color("Bg").ignoresSafeArea()
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: UI.Dimension.NetworkSelection.titleMarginTop)
                Group {
                    Text(LocalizedStringKey("network_selection.selected_network"))
                        .font(UI.Font.NetworkSelection.title)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: UI.Dimension.NetworkSelection.subtitleMarginTop)
                    Text(LocalizedStringKey("network_selection.select_network"))
                        .font(UI.Font.NetworkSelection.subtitle)
                        .foregroundColor(Color("Text"))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Onboarding.textHorizontalPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Onboarding.textHorizontalPadding
                ))
                Spacer()
                    .frame(height: UI.Dimension.NetworkSelection.networkGridMarginTop)
                ZStack(alignment: .center) {
                    Color("Bg")
                    switch viewModel.fetchState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: Color("Text")
                                )
                            )
                            .scaleEffect(1.25)
                    case .success(let networks):
                        LazyVGrid(
                            columns: self.gridItemLayout,
                            spacing: UI.Dimension.NetworkSelection.networkButtonSpacing
                        ) {
                            ForEach(networks.indices, id: \.self) { i in
                                Button(
                                    action: {
                                        self.selectedNetwork = networks[i]
                                    },
                                    label: {
                                        NetworkButtonView(
                                            isSelected: self.selectedNetwork?.id == networks[i].id,
                                            network: networks[i]
                                        )
                                    }
                                )
                                .buttonStyle(NetworkButtonStyle())
                                .zIndex(100 - Double(i))
                            }
                        }
                    default:
                        Spacer()
                    }
                }
                .frame(height: UI.Dimension.NetworkSelection.networkButtonSize)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginTop)
                } else {
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Button(LocalizedStringKey("common.go")) {
                        // action
                    }
                    .disabled(selectedNetwork == nil)
                    .buttonStyle(ActionButtonStyle(
                        isEnabled: selectedNetwork != nil)
                    )
                }
                .frame(maxWidth: .infinity)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginBottom)
                }
            }
        }
        .onAppear {
            self.viewModel.getNetworks()
        }
    }
}

struct NetworkSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectionView()
            .environmentObject(AppData())
    }
}
