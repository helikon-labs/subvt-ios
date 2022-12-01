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
    @State private var headerMaterialOpacity = 0.0
    @State private var networkListIsVisible = false
    @State private var startEraListIsVisible = false
    @State private var endEraListIsVisible = false
    
    private let dateFormatter = DateFormatter()
    
    init() {
        self.dateFormatter.dateFormat = "dd MMM ''YY HH:mm"
    }
    
    private var controlsAreDisabled: Bool {
        switch self.viewModel.fetchState {
        case .idle, .loading, .error:
            return true
        case .success:
            return false
        }
    }
    
    private func getEraDisplay(index: UInt, timestamp: UInt64) -> String {
        let date = Date(
            timeIntervalSince1970: TimeInterval(timestamp / 1000)
        )
        return "Era \(index) - \(dateFormatter.string(from: date))"
    }
    
    private var startEraDisplay: String {
        if let startEra = self.viewModel.startEra {
            return getEraDisplay(
                index: startEra.index,
                timestamp: startEra.startTimestamp
            )
        } else {
            return ""
        }
    }
    
    private var endEraDisplay: String {
        if let endEra = self.viewModel.endEra {
            return getEraDisplay(
                index: endEra.index,
                timestamp: endEra.endTimestamp
            )
        } else {
            return ""
        }
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                Text(localized("network_report_range_selection.title"))
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
                                .disabled(self.controlsAreDisabled)
                                .opacity(
                                    self.controlsAreDisabled
                                        ? UI.Value.disabledControlOpacity
                                        : 1.0
                                )
                            if self.networkListIsVisible {
                                Spacer()
                                    .frame(height: 2)
                                self.networkListView
                            }
                        }
                        Group {
                            Spacer()
                                .frame(height: 24)
                            self.startEraTitleAndButtonView
                                .disabled(self.controlsAreDisabled)
                                .opacity(
                                    self.controlsAreDisabled
                                        ? UI.Value.disabledControlOpacity
                                        : 1.0
                                )
                            if self.startEraListIsVisible {
                                Spacer()
                                    .frame(height: 2)
                            }
                            self.startEraListView
                        }
                        Group {
                            Spacer()
                                .frame(height: 24)
                            self.endEraTitleAndButtonView
                                .disabled(self.controlsAreDisabled)
                                .opacity(
                                    self.controlsAreDisabled
                                        ? UI.Value.disabledControlOpacity
                                        : 1.0
                                )
                            if self.endEraListIsVisible {
                                Spacer()
                                    .frame(height: 2)
                            }
                            self.endEraListView
                        }
                        Spacer()
                            .frame(height: UI.Dimension.ReportRangeSelection.scrollViewBottomSpacerHeight)
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
            switch self.viewModel.fetchState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
                    .animation(.spring(), value: self.viewModel.fetchState)
                    .zIndex(2)
            default:
                Group {}
            }
            ZStack {
                SnackbarView(
                    message: localized("network_report_range_selection.error.era_list"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchEras()
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
            if let startEra = self.viewModel.startEra,
               let endEra = self.viewModel.endEra {
                VStack() {
                    Spacer()
                    NavigationLink {
                        NetworkReportsView(
                            network: self.viewModel.network,
                            startEra: startEra,
                            endEra: endEra
                        )
                    } label: {
                        ActionButtonView(
                            title: localized("common.view"),
                            state: .enabled,
                            font: UI.Font.ReportRangeSelection.actionButton,
                            width: UI.Dimension.ReportRangeSelection.viewButtonWidth,
                            height: UI.Dimension.ReportRangeSelection.viewButtonHeight
                        )
                    }
                    .buttonStyle(PushButtonStyle())
                    .disabled(self.controlsAreDisabled)
                    .opacity(self.controlsAreDisabled ? UI.Value.disabledControlOpacity : 1.0)
                    Spacer()
                        .frame(height: UI.Dimension.ReportRangeSelection.viewButtonMarginBottom)
                }
                .frame(maxHeight: .infinity)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.fetchEras()
                }
            }
        }
    }
    
    private var networkTitleAndButtonView: some View {
        Group {
            Text(localized("common.network"))
                .font(UI.Font.ReportRangeSelection.subtitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: 8)
            Button {
                self.networkListIsVisible.toggle()
                self.startEraListIsVisible = false
                self.endEraListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    UI.Image.Common.networkIcon(
                        network: self.viewModel.network
                    )
                    .resizable()
                    .frame(
                        width: UI.Dimension.ReportRangeSelection.networkIconSize.get(),
                        height: UI.Dimension.ReportRangeSelection.networkIconSize.get()
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
                    top: 0,
                    leading: 12,
                    bottom: 0,
                    trailing: 12
                ))
                .frame(height: 48)
                .background(Color("DataPanelBg"))
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
            .buttonStyle(ItemListButtonStyle())
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
                                self.viewModel.fetchEras()
                            },
                            label: {
                                HStack(alignment: .center) {
                                    UI.Image.Common.networkIcon(
                                        network: network
                                    )
                                    .resizable()
                                    .frame(
                                        width: UI.Dimension.ReportRangeSelection.networkIconSize.get(),
                                        height: UI.Dimension.ReportRangeSelection.networkIconSize.get()
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
                                    top: 0,
                                    leading: 12,
                                    bottom: 0,
                                    trailing: 12
                                ))
                                .frame(height: 48)
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
    
    private var startEraTitleAndButtonView: some View {
        Group {
            Text(localized("network_report_range_selection.start_date"))
                .font(UI.Font.ReportRangeSelection.subtitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: 8)
            Button {
                self.startEraListIsVisible.toggle()
                self.networkListIsVisible = false
                self.endEraListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    Image("CalendarIcon")
                    Spacer()
                        .frame(width: 16)
                    Text(self.startEraDisplay)
                        .font(UI.Font.ReportRangeSelection.eraDisplay)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.startEraListIsVisible {
                        UI.Image.Common.arrowUp(self.colorScheme)
                    } else {
                        UI.Image.Common.arrowDown(self.colorScheme)
                    }
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 12,
                    bottom: 0,
                    trailing: 12
                ))
                .frame(height: 48)
                .background(Color("DataPanelBg"))
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
            .buttonStyle(ItemListButtonStyle())
        }
    }
    
    private var startEraListView: some View {
        Group {
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack(spacing: 0) {
                        ForEach(self.viewModel.eras.indices, id: \.self) { i in
                            let era = self.viewModel.eras[i]
                            Button(
                                action: {
                                    self.viewModel.setStartEra(era)
                                    self.startEraListIsVisible = false
                                },
                                label: {
                                    HStack(alignment: .center) {
                                        Text(getEraDisplay(index: era.index, timestamp: era.startTimestamp))
                                            .font(UI.Font.Common.formFieldTitle)
                                            .foregroundColor(Color("Text"))
                                        if era.index == self.viewModel.startEra?.index ?? 0 {
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
                                        top: 0,
                                        leading: 12,
                                        bottom: 0,
                                        trailing: 12
                                    ))
                                    .frame(height: 48)
                                    .background(Color("DataPanelBg"))
                                }
                            )
                            .buttonStyle(ItemListButtonStyle())
                            .id(era.index)
                            if i < self.viewModel.eras.count - 1 {
                                Color("ItemSelectorListDivider")
                                    .frame(height: 1)
                            }
                        }
                    }
                    .onChange(of: self.startEraListIsVisible) { isVisible in
                        if isVisible, let startEra = self.viewModel.startEra {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    reader.scrollTo(startEra.index)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(
            height: self.startEraListIsVisible
                ? UI.Dimension.ReportRangeSelection.eraListHeight
                : 0
        )
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
    
    private var endEraTitleAndButtonView: some View {
        Group {
            Text(localized("network_report_range_selection.end_date"))
                .font(UI.Font.ReportRangeSelection.subtitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: 8)
            Button {
                self.endEraListIsVisible.toggle()
                self.networkListIsVisible = false
                self.startEraListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    Image("CalendarIcon")
                    Spacer()
                        .frame(width: 16)
                    Text(self.endEraDisplay)
                        .font(UI.Font.ReportRangeSelection.eraDisplay)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.endEraListIsVisible {
                        UI.Image.Common.arrowUp(self.colorScheme)
                    } else {
                        UI.Image.Common.arrowDown(self.colorScheme)
                    }
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 12,
                    bottom: 0,
                    trailing: 12
                ))
                .frame(height: 48)
                .background(Color("DataPanelBg"))
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
            .buttonStyle(ItemListButtonStyle())
        }
    }
    
    private var endEraListView: some View {
        Group {
            ScrollView {
                ScrollViewReader { reader in
                    LazyVStack(spacing: 0) {
                        ForEach(self.viewModel.eras.indices, id: \.self) { i in
                            let era = self.viewModel.eras[i]
                            Button(
                                action: {
                                    self.viewModel.setEndEra(era)
                                    self.endEraListIsVisible = false
                                },
                                label: {
                                    HStack(alignment: .center) {
                                        Text(getEraDisplay(index: era.index, timestamp: era.endTimestamp))
                                            .font(UI.Font.Common.formFieldTitle)
                                            .foregroundColor(Color("Text"))
                                        if era.index == self.viewModel.endEra?.index ?? 0 {
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
                                        top: 0,
                                        leading: 12,
                                        bottom: 0,
                                        trailing: 12
                                    ))
                                    .frame(height: 48)
                                    .background(Color("DataPanelBg"))
                                }
                            )
                            .buttonStyle(ItemListButtonStyle())
                            .id(era.index)
                            if i < self.viewModel.eras.count - 1 {
                                Color("ItemSelectorListDivider")
                                    .frame(height: 1)
                            }
                        }
                    }
                    .onChange(of: self.endEraListIsVisible) { isVisible in
                        if isVisible, let endEra = self.viewModel.endEra {
                            print("HM HM")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    reader.scrollTo(endEra.index)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(
            height: self.endEraListIsVisible
                ? UI.Dimension.ReportRangeSelection.eraListHeight
                : 0
        )
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
}

struct ReportRangeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ReportRangeSelectionView()
    }
}
