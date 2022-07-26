//
//  ValidatorListView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorListView: View {
    enum Mode {
        case active
        case inactive
    }
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @StateObject private var viewModel = ValidatorListViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @Binding var isVisible: Bool
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var filterSectionIsVisible = true
    @State private var lastScroll: CGFloat = 0
    @State private var popupIsVisible = false
    
    let mode: Mode
    static let filterSectionHeight = UI.Dimension.ValidatorList.searchBarMarginTop
        + UI.Dimension.Common.searchBarHeight
    private let filterSectionToggleThreshold: CGFloat = 30
    private let filterSectionToggleDuration: Double = 0.1
    
    private var filterSectionOpacity: Double {
        if self.filterSectionIsVisible {
            if self.viewModel.isLoading {
                return 0.5
            }
            return 1.0
        } else {
            return 0
        }
    }
    
    private func onScroll(_ scroll: CGFloat) {
        self.headerMaterialOpacity = scroll / 20.0
        if self.filterSectionIsVisible {
            if scroll < self.lastScroll {
                self.lastScroll = scroll
            } else if (scroll - self.lastScroll) >= self.filterSectionToggleThreshold {
                self.lastScroll = scroll
                withAnimation(.linear(duration: self.filterSectionToggleDuration)) {
                    self.filterSectionIsVisible = false
                }
            }
        } else {
            if scroll > self.lastScroll {
                self.lastScroll = scroll
            } else if (self.lastScroll - scroll) >= self.filterSectionToggleThreshold {
                self.lastScroll = scroll
                withAnimation(.linear(duration: self.filterSectionToggleDuration)) {
                    self.filterSectionIsVisible = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
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
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UI.Dimension.Common.titleMarginTop)
                    HStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 0) {
                            Button(
                                action: {
                                    self.viewModel.unsubscribe()
                                    self.isVisible = false
                                },
                                label: {
                                    BackButtonView()
                                }
                            )
                            .buttonStyle(PushButtonStyle())
                            Spacer()
                                .frame(width: UI.Dimension.ValidatorList.titleMarginLeft)
                            HStack(alignment: .top, spacing: 0) {
                                Text(self.mode == .active
                                     ? localized("active_validator_list.title")
                                     : localized("inactive_validator_list.title")
                                )
                                .font(UI.Font.ValidatorList.title)
                                .foregroundColor(Color("Text"))
                                Spacer()
                                    .frame(width: 6)
                                WSRPCStatusIndicatorView(
                                    status: self.viewModel.serviceStatus,
                                    isConnected: self.networkMonitor.isConnected,
                                    size: UI.Dimension.Common.connectionStatusSizeSmall.get()
                                )
                                .modifier(PanelAppearance(5, self.displayState))
                            }
                        }
                        .opacity(1.0)
                        Spacer()
                        NetworkSelectorButtonView()
                    }
                    .frame(height: UI.Dimension.ValidatorList.titleSectionHeight)
                    .modifier(PanelAppearance(1, self.displayState))
                    HStack {
                        HStack(alignment: .center) {
                            UI.Image.Common.searchIcon(self.colorScheme)
                            TextField(
                                localized("common.search"),
                                text: self.$viewModel.searchText
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
                                self.popupIsVisible = true
                            },
                            label: {
                                ZStack {
                                    UI.Image.Common.filterIcon(self.colorScheme)
                                }
                                .frame(
                                    width: UI.Dimension.Common.searchBarHeight,
                                    height: UI.Dimension.Common.searchBarHeight
                                )
                                .background(Color("DataPanelBg"))
                                .cornerRadius(UI.Dimension.Common.cornerRadius)
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .opacity(self.popupIsVisible ? 0 : 1)
                    }
                    .frame(
                        height: self.filterSectionIsVisible
                            ? Self.filterSectionHeight
                            : 0,
                        alignment: .bottom
                    )
                    .disabled(self.viewModel.isLoading)
                    .opacity(self.filterSectionOpacity)
                    .modifier(PanelAppearance(2, self.displayState))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
                    trailing: UI.Dimension.Common.padding
                ))
                
            }
            .background(
                VisualEffectView(effect: UIBlurEffect(
                    style: .systemUltraThinMaterial
                ))
                .cornerRadius(
                    UI.Dimension.Common.headerBlurViewCornerRadius,
                    corners: [.bottomLeft, .bottomRight]
                )
                .opacity(self.headerMaterialOpacity)
                .modifier(PanelAppearance(
                    0,
                    self.displayState,
                    animateOffset: false
                ))
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            if self.popupIsVisible {
                ValidatorListFilterSortView(
                    isVisible: self.$popupIsVisible,
                    sortOption: self.$viewModel.sortOption,
                    filterOptions: self.$viewModel.filterOptions
                ).zIndex(2)
            }
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.ValidatorList.scrollContentMarginTop)
                        ForEach(self.viewModel.validators, id: \.self.address) {
                            validator in
                            ValidatorSummaryView(validatorSummary: validator)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        Spacer()
                            .frame(
                                height: UI.Dimension.Common.bottomNotchHeight
                                    + UI.Dimension.Common.padding / 2
                            )
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
                        self.onScroll(max($0, 0))
                    }
                    .onChange(of: self.viewModel.sortOption) { _ in
                        withAnimation(.easeInOut) {
                            scrollViewProxy.scrollTo(0)
                        }
                    }
                }
            }
            .disabled(self.viewModel.isLoading)
            .zIndex(0)
            FooterGradientView()
                .zIndex(1)
            if self.viewModel.isLoading && self.viewModel.validators.count == 0 {
                ZStack {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Color("Text")
                            )
                        )
                        .scaleEffect(1.25)
                }
                .transition(.opacity)
                .animation(
                    .linear(duration: 0.1),
                    value: self.viewModel.isLoading
                )
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            UITextField.appearance().clearButtonMode = .whileEditing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.displayState = .appeared
                self.viewModel.subscribeToValidatorList(
                    network: self.network,
                    mode: self.mode
                )
            }
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(newPhase)
        }
    }
}

struct ValidatorListView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorListView(isVisible: .constant(true), mode: .active)
    }
}
