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
    @State private var searchText = ""
    
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
    
    var body: some View {
        ZStack {
            ZStack {
                VisualEffectView(effect: blurEffect)
                .frame(maxWidth: .infinity)
                .frame(height: UI.Dimension.Common.contentAfterTitleMarginTop)
                .cornerRadius(16)
                .opacity(1)
                
                //
                //.blur(radius: 8)
                //.background(.thinMaterial)
                
                /*
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: UI.Dimension.Common.contentAfterTitleMarginTop)
                    //.opacity(0.8)
                    //.blur(radius: 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                 */
                
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
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.padding
                ))
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.Common.contentAfterTitleMarginTop)
                        HStack {
                            HStack(alignment: .center) {
                                UI.Image.Common.searchIcon(self.colorScheme)
                                TextField(
                                    localized("common.search"),
                                    text: $searchText
                                )
                                    .font(UI.Font.ValidatorList.search)
                            }
                            .frame(height: UI.Dimension.Common.searchBarHeight)
                            .padding(EdgeInsets(
                                top: 0,
                                leading: UI.Dimension.Common.padding,
                                bottom: 0,
                                trailing: UI.Dimension.Common.padding / 2
                            ))
                            .background(Color("DataPanelBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                            Button(
                                action: {
                                    // display sort / filter options
                                },
                                label: {
                                    ZStack {
                                        UI.Image.Common.filterIcon(self.colorScheme)
                                    }
                                }
                            )
                            .frame(
                                width: UI.Dimension.Common.searchBarHeight,
                                height: UI.Dimension.Common.searchBarHeight
                            )
                            .background(Color("DataPanelBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                        }
                        ForEach(self.viewModel.validators, id: \.self.accountId) { validator in
                            ValidatorSummaryView(validatorSummary: validator)
                        }
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                    .frame(maxHeight: .infinity)
                }
            }
            .zIndex(0)
            .modifier(PanelAppearance(2, self.displayState))
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
