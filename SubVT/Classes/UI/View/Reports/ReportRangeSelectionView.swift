//
//  ReportRangeSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.11.2022.
//

import SubVTData
import SwiftUI

struct ReportRangeSelectionView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.networks) private var networks: [Network]! = nil
    @StateObject private var viewModel = ReportRangeSelectionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var networkListIsVisible = false
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                Text(localized("era_report_range_selection.title"))
                    .font(UI.Font.Common.tabViewTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
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
            /*
            Color("Bg")
                .ignoresSafeArea()
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
             */
            headerView
                .zIndex(2)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                        Group {
                            Spacer()
                                .frame(height: 24)
                            self.networkTitleAndButtonView
                            if self.networkListIsVisible {
                                Spacer()
                                    .frame(height: 2)
                                self.networkListView
                            }
                        }
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
            FooterGradientView()
                .zIndex(1)
            ZStack {
                SnackbarView(
                    message: localized("common.error.validator_list"),
                    type: .error(canRetry: true)
                ) {
                    // self.viewModel.fetchMyValidators()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(
                    y: UI.Dimension.ReportRangeSelection.snackbarYOffset(
                        fetchState: self.viewModel.fetchState
                    )
                )
                .opacity(UI.Dimension.ReportRangeSelection.snackbarOpacity(
                    fetchState: self.viewModel.fetchState
                ))
                .animation(
                    .spring(),
                    value: self.viewModel.fetchState
                )
            }
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
            if self.viewModel.fetchState == .idle {
                self.viewModel.network = self.networks[0]
                self.viewModel.initReportServices(networks: self.networks)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
            }
        }
    }
    
    private var networkTitleAndButtonView: some View {
        Group {
            Text(localized("common.network"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.networkListIsVisible.toggle()
            } label: {
                HStack(alignment: .center) {
                    UI.Image.Common.networkIcon(
                        network: self.viewModel.network
                    )
                    .resizable()
                    .frame(
                        width: UI.Dimension.AddValidators.networkIconSize.get(),
                        height: UI.Dimension.AddValidators.networkIconSize.get()
                    )
                    Spacer()
                        .frame(width: 16)
                    Text(self.viewModel.network.display)
                        .font(UI.Font.Common.formFieldTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.networkListIsVisible {
                        UI.Image.Common.arrowUp(self.colorScheme)
                    } else {
                        UI.Image.Common.arrowDown(self.colorScheme)
                    }
                }
                .padding(EdgeInsets(
                    top: 12,
                    leading: 12,
                    bottom: 12,
                    trailing: 12
                ))
                .background(Color("DataPanelBg"))
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
        }
    }
    
    private var networkListView: some View {
        Group {
            if let networks = self.networks, self.networkListIsVisible {
                VStack(spacing: 0) {
                    ForEach(networks.indices, id: \.self) { i in
                        let network = networks[i]
                        Button(
                            action: {
                                self.viewModel.network = network
                                self.networkListIsVisible = false
                            },
                            label: {
                                HStack(alignment: .center) {
                                    UI.Image.Common.networkIcon(
                                        network: network
                                    )
                                    .resizable()
                                    .frame(
                                        width: UI.Dimension.AddValidators.networkIconSize.get(),
                                        height: UI.Dimension.AddValidators.networkIconSize.get()
                                    )
                                    Spacer()
                                        .frame(width: 16)
                                    Text(network.display)
                                        .font(UI.Font.Common.formFieldTitle)
                                        .foregroundColor(Color("Text"))
                                    if network.id == self.viewModel.network.id {
                                        Spacer()
                                            .frame(width: 16)
                                        Circle()
                                            .fill(Color("ItemListSelectionIndicator"))
                                            .frame(
                                                width: UI.Dimension.Common.itemSelectionIndicatorSize,
                                                height: UI.Dimension.Common.itemSelectionIndicatorSize
                                            )
                                            .shadow(
                                                color: Color("ItemListSelectionIndicator"),
                                                radius: 3,
                                                x: 0,
                                                y: UI.Dimension.Common.itemSelectionIndicatorSize / 2
                                            )
                                    }
                                    Spacer()
                                }
                                .padding(EdgeInsets(
                                    top: 12,
                                    leading: 12,
                                    bottom: 12,
                                    trailing: 12
                                ))
                                .background(Color("DataPanelBg"))
                            }
                        )
                        .buttonStyle(ItemListButtonStyle())
                        if i < networks.count - 1 {
                            Color("ItemSelectorListDivider")
                                .frame(height: 1)
                        }
                    }
                }
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
        }
    }
}

struct ReportRangeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ReportRangeSelectionView()
    }
}
