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
    @State private var filterSectionIsVisible = true
    @State private var lastScroll: CGFloat = 0
    private let filterSectionHeight = UI.Dimension.ValidatorList.searchBarMarginTop
        + UI.Dimension.Common.searchBarHeight
    private let filterSectionToggleThreshold: CGFloat = 30
    private let filterSectionToggleDuration: Double = 0.1
    
    
    private var showProgressView: Bool {
        if self.viewModel.validators.count == 0 {
            switch self.viewModel.serviceStatus {
            case .idle, .connected, .subscribed:
                return true
            default:
                break
            }
        }
        return false
    }
    
    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing: 0) {
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
                        Spacer()
                        NetworkSelectorButtonView()
                    }
                    .modifier(PanelAppearance(1, self.displayState))
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
                    .frame(
                        height: self.filterSectionIsVisible
                            ? self.filterSectionHeight
                            : 0,
                        alignment: .bottom
                    )
                    .opacity(self.filterSectionIsVisible ? 1 : 0)
                    .clipped()
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
                .modifier(PanelAppearance(
                    0,
                    self.displayState,
                    animateOffset: false
                ))
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.ValidatorList.scrollContentMarginTop)
                        ForEach(self.viewModel.validators, id: \.self.accountId) {
                            validator in
                            if validator.filter(
                                ss58Prefix: UInt16(self.network.ss58Prefix),
                                self.searchText
                            ) {
                                ValidatorSummaryView(validatorSummary: validator)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scroll")).origin.y
                        )
                    })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        let scroll = max($0, 0)
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
                }
            }
            .zIndex(0)
            if self.showProgressView {
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
                    value: self.showProgressView
                )
            }
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
