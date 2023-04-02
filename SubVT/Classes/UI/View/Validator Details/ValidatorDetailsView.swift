//
//  ValidatorDetailsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.07.2022.
//

import Combine
import SubVTData
import SwiftUI
import SwiftEventBus

fileprivate struct NominationListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.none, value: configuration.isPressed)
    }
}

struct ValidatorDetailsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject private var router: Router
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @AppStorage(AppStorageKey.onekvNominators) private var onekvNominators: [UInt64:[String]] = [:]
    @StateObject private var viewModel = ValidatorDetailsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var lastScroll: CGFloat = 0
    
    @State private var actionFeedbackViewState = ActionFeedbackView.State.success
    @State private var actionFeedbackViewText = localized("common.done")
    @State private var actionFeedbackViewIsVisible = false
    
    @State private var activeNominatorListIsVisible = false
    @State private var inactiveNominatorListIsVisible = false
    
    @State private var phase: Double = 0.0
    
    private let networkId: UInt64
    private let accountId: AccountId
    
    init(
        networkId: UInt64,
        accountId: AccountId
    ) {
        self.networkId = networkId
        self.accountId = accountId
    }
    
    var identityDisplay: String {
        return self.viewModel.validatorDetails?.identityDisplay
            ?? " "
    }
    
    private var identityIcon: Image? {
        if let account = self.viewModel.validatorDetails?.account {
            if let _ = account.parent?.boxed.identity?.display {
                if account.parent?.boxed.identity?.confirmed == true {
                    return Image("ParentIdentityConfirmedIcon")
                } else {
                    return Image("ParentIdentityNotConfirmedIcon")
                }
            } else if account.identity?.display != nil {
                if account.identity?.confirmed == true {
                    return Image("IdentityConfirmedIcon")
                } else {
                    return Image("IdentityNotConfirmedIcon")
                }
            }
        }
        return nil
    }
    
    private func getTimePeriodString(timestampMs: UInt64) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .weekOfMonth, .day, .hour, .minute],
            from: Date(timeIntervalSince1970: Double(timestampMs / 1000)),
            to: Date()
        )
        var stringComponents = [String]()
        if let year = components.year, year > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.year"),
                year
            ))
        }
        if let month = components.month, month > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.month"),
                month
            ))
        }
        if let week = components.weekOfMonth, week > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.week"),
                week
            ))
        }
        if let day = components.day, day > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.day"),
                day
            ))
        }
        if let hour = components.hour, hour > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.hour"),
                hour
            ))
        }
        if let minute = components.minute, minute > 0 {
            stringComponents.append(String(
                format: localized("common.date_components.minute"),
                minute
            ))
        }
        return stringComponents.joined(separator: " ")
    }
    
    private var isOneKV: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.onekvCandidateRecordId != nil
        }
        return false
    }
    
    private var isParaValidator: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.isParaValidator
        }
        return false
    }
    
    private var isActiveNextSession: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.isActiveNextSession
        }
        return false
    }
    
    private var heartbeatReceived: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.heartbeatReceived ?? false
        }
        return false
    }
    
    private var isOversubscribed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.oversubscribed
        }
        return false
    }
    
    private var blocksNominations: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.preferences.blocksNominations
        }
        return false
    }
    
    private var hasBeenSlashed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.slashCount > 0
        }
        return false
    }
    
    private var addRemoveValidatorButtonIsEnabled: Bool {
        switch self.viewModel.userValidatorsFetchState {
        case .success:
            return true
        default:
            return false
        }
    }
    
    private var addRemoveValidatorButtonView: some View {
        ZStack {
            switch self.viewModel.userValidatorsFetchState {
            case .success(_):
                if let _ = self.viewModel.userValidator {
                    UI.Image.Common.trashIcon(self.colorScheme)
                } else {
                    UI.Image.ValidatorDetails.addValidatorIcon(self.colorScheme)
                }
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(
                        tint: Color("Text")
                    ))
            case .error:
                UI.Image.ValidatorDetails.addValidatorIcon(self.colorScheme)
            }
        }
        .frame(
            width: UI.Dimension.Common.networkSelectorHeight,
            height: UI.Dimension.Common.networkSelectorHeight
        )
        .background(Color("NetworkSelectorClosedBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
        .animation(
            .easeInOut(duration: 0.5),
            value: self.viewModel.userValidatorsFetchState
        )
    }
    
    var body: some View {
        ZStack {
            Color("Bg")
                .ignoresSafeArea()
            BgMorphView(isActive: self.viewModel.validatorDetails?.isActive ?? false)
                .offset(
                    x: 0,
                    y: UI.Dimension.BgMorph.yOffset(
                        displayState: self.displayState
                    )
                )
                .animation(
                    .easeOut(duration: 0.75),
                    value: self.displayState
                )
                .animation(
                    .easeOut(duration: 1.0),
                    value: self.viewModel.validatorDetails
                )
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UI.Dimension.Common.titleMarginTop)
                    HStack(alignment: .center) {
                        Button(
                            action: {
                                self.viewModel.unsubscribe()
                                self.router.back()
                            },
                            label: {
                                BackButtonView()
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(1, self.displayState))
                        Spacer()
                        NetworkSelectorButtonView(
                            network: self.viewModel.network,
                            displayType: .display
                        )
                        .modifier(PanelAppearance(2, self.displayState))
                        Button(
                            action: {
                                self.viewModel.addOrRemoveValidator {
                                    self.actionFeedbackViewState = .success
                                    self.actionFeedbackViewText = localized("validator_details.validator_added")
                                    self.actionFeedbackViewIsVisible = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + UI.Duration.actionFeedbackViewVisibleDuration) {
                                        self.actionFeedbackViewIsVisible = false
                                    }
                                } onRemoved: {
                                    self.actionFeedbackViewState = .success
                                    self.actionFeedbackViewText = localized("validator_details.validator_removed")
                                    self.actionFeedbackViewIsVisible = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + UI.Duration.actionFeedbackViewVisibleDuration) {
                                        self.actionFeedbackViewIsVisible = false
                                    }
                                } onError: { _ in
                                    self.actionFeedbackViewState = .error
                                    self.actionFeedbackViewText = localized("common.error")
                                    self.actionFeedbackViewIsVisible = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + UI.Duration.actionFeedbackViewVisibleDuration) {
                                        self.actionFeedbackViewIsVisible = false
                                    }
                                }
                            },
                            label: {
                                self.addRemoveValidatorButtonView
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(3, self.displayState))
                        .disabled(!self.addRemoveValidatorButtonIsEnabled)
                        NavigationLink(
                            value: Screen.rewardReport(
                                network: self.viewModel.network,
                                accountId: self.accountId,
                                identityDisplay: self.identityDisplay,
                                factor: .none,
                                title: localized("reports.monthly_reward.title"),
                                chartTitle: String(
                                    format: localized("reports.monthly_reward.chart_title_with_ticker"),
                                    self.viewModel.network.tokenTicker
                                )
                            )
                        ) {
                            ZStack {
                                Text("$")
                                    .font(UI.Font.Common.navigationBarButton)
                                    .foregroundColor(Color("Text"))
                            }
                            .frame(
                                width: UI.Dimension.Common.networkSelectorHeight,
                                height: UI.Dimension.Common.networkSelectorHeight
                            )
                            .background(Color("NetworkSelectorClosedBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                        }
                        .transition(.move(edge: .leading))
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(4, self.displayState))
                        
                        NavigationLink(
                            value: Screen.paraVoteReport(
                                networkId: self.viewModel.network.id,
                                accountId: self.accountId,
                                identityDisplay: self.viewModel.validatorDetails?.identityDisplay ?? ""
                            )
                        ) {
                            ZStack {
                                Text("PV")
                                    .font(UI.Font.Common.navigationBarButtonSmall)
                                    .foregroundColor(Color("Text"))
                            }
                            .frame(
                                width: UI.Dimension.Common.networkSelectorHeight,
                                height: UI.Dimension.Common.networkSelectorHeight
                            )
                            .background(Color("NetworkSelectorClosedBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                        }
                        .transition(.move(edge: .leading))
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(5, self.displayState))
                        
                        NavigationLink(
                            value: Screen.reportRangeSelection(
                                mode: ReportRangeSelectionView.Mode.validator(
                                    network: self.viewModel.network,
                                    accountId: self.accountId,
                                    identityDisplay: self.identityDisplay
                                )
                            )
                        ) {
                            ZStack {
                                UI.Image.ValidatorDetails.validatorReportsIcon(self.colorScheme)
                            }
                            .frame(
                                width: UI.Dimension.Common.networkSelectorHeight,
                                height: UI.Dimension.Common.networkSelectorHeight
                            )
                            .background(Color("NetworkSelectorClosedBg"))
                            .cornerRadius(UI.Dimension.Common.cornerRadius)
                        }
                        .transition(.move(edge: .leading))
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(6, self.displayState))
                    }
                    .frame(height: UI.Dimension.ValidatorList.titleSectionHeight)
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
                .disabled(true)
                .opacity(self.headerMaterialOpacity)
                .zIndex(1)
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(3)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.ValidatorDetails.scrollContentMarginTop)
                        IdenticonSceneView(
                            accountId: self.accountId,
                            rotation: self.viewModel.deviceRotation
                        )
                        .frame(height: UI.Dimension.ValidatorDetails.identiconHeight)
                        .offset(y: sin(self.phase) * 8)
                        .modifier(PanelAppearance(7, self.displayState))
                        VStack(
                            alignment: .leading,
                            spacing: UI.Dimension.Common.dataPanelSpacing
                        ) {
                            self.identityDisplayView
                                .modifier(PanelAppearance(8, self.displayState))
                            Spacer()
                                .frame(height: 4)
                            Group {
                                self.nominationTotalView
                                    .modifier(PanelAppearance(9, self.displayState))
                                self.selfStakeView
                                    .modifier(PanelAppearance(10, self.displayState))
                                if let _ = self.viewModel.validatorDetails?.validatorStake {
                                    Button {
                                        self.activeNominatorListIsVisible.toggle()
                                    } label: {
                                        self.activeStakeView
                                    }
                                    .modifier(PanelAppearance(11, self.displayState))
                                    .buttonStyle(NominationListButtonStyle())
                                }
                                Button {
                                    self.inactiveNominatorListIsVisible.toggle()
                                } label: {
                                    self.inactiveNominationsView
                                }
                                .modifier(PanelAppearance(12, self.displayState))
                                .buttonStyle(NominationListButtonStyle())
                                if let _ = self.viewModel.validatorDetails?.account.discoveredAt {
                                    self.accountAgeView
                                        .modifier(PanelAppearance(13, self.displayState))
                                }
                                self.offlineFaultsView
                                    .modifier(PanelAppearance(14, self.displayState))
                                self.rewardDestinationView
                                    .modifier(PanelAppearance(15, self.displayState))
                            }
                            Group {
                                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                    self.commissionView
                                    self.aprView
                                }
                                .modifier(PanelAppearance(16, self.displayState))
                                if let _ = self.viewModel.validatorDetails?.validatorStake {
                                    HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                        self.eraBlocksView
                                        self.eraPointsView
                                    }
                                    .modifier(PanelAppearance(17, self.displayState))
                                }
                            }
                            if let _ = self.viewModel.validatorDetails?.onekvCandidateRecordId {
                                Group {
                                    Spacer()
                                        .frame(height: 8)
                                    Text(localized("validator_details.onekv_section_title"))
                                        .font(UI.Font.ValidatorDetails.subsectionTitle)
                                        .foregroundColor(Color("Text"))
                                        .modifier(PanelAppearance(18, self.displayState))
                                    Spacer()
                                        .frame(height: 8)
                                    self.onekvRankView
                                        .modifier(PanelAppearance(19, self.displayState))
                                    self.onekvLocationView
                                        .modifier(PanelAppearance(20, self.displayState))
                                    if self.viewModel.validatorDetails?.onekvOfflineSince ?? 0 > 0 {
                                        self.onekvDowntimeView
                                            .modifier(PanelAppearance(21, self.displayState))
                                    }
                                    self.onekvValidityView
                                        .modifier(PanelAppearance(22, self.displayState))
                                }
                            }
                            Spacer()
                                .frame(height: UI.Dimension.ValidatorDetails.scrollContentBottomSpacerHeight)
                            
                        }
                        .padding(EdgeInsets(
                            top: 0,
                            leading: UI.Dimension.Common.padding,
                            bottom: 0,
                            trailing: UI.Dimension.Common.padding
                        ))
                    }
                    .background(GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                    })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        self.headerMaterialOpacity = min(max($0, 0) / 50.0, 1.0)
                    }
                }
            }
            .zIndex(0)
            FooterGradientView()
                .zIndex(1)
            ActionFeedbackView(
                state: self.actionFeedbackViewState,
                text: self.actionFeedbackViewText,
                visibleYOffset: UI.Dimension.ValidatorDetails.actionFeedbackViewYOffset,
                isVisible: self.$actionFeedbackViewIsVisible
            )
            .zIndex(1)
            if let validatorDetails = self.viewModel.validatorDetails {
                ValidatorDetailsIconsView(
                    validatorDetails: validatorDetails
                )
                .offset(
                    x: 0,
                    y: -UI.Dimension.ValidatorDetails.iconContainerMarginBottom
                )
                .zIndex(2)
                .modifier(PanelAppearance(5, self.displayState))
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
        .animation(
            .easeInOut(duration: 0.25),
            value: self.viewModel.validatorDetails
        )
        .onAppear() {
            KeyboardUtil.dismissKeyboard()
            self.viewModel.network = (self.networks?.first(where: { $0.id == self.networkId }))!
            self.viewModel.accountId = self.accountId
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if self.viewModel.validatorDetails?.isActive ?? false {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            self.phase = 180.0
                        }
                    }
                    self.viewModel.startDeviceMotion()
                    self.viewModel.subscribeToValidatorDetails()
                    self.viewModel.fetchUserValidators {
                        // no-op
                    } onError: { _ in
                        self.actionFeedbackViewState = .error
                        self.actionFeedbackViewText = localized("common.error")
                        self.actionFeedbackViewIsVisible = true
                    }
                }
            }
        }
        .onDisappear() {
            self.viewModel.stopDeviceMotion()
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(newPhase)
        }
    }
}

extension ValidatorDetailsView {
    private var identityDisplayView: some View {
        HStack(
            alignment: .center,
            spacing: UI.Dimension.ValidatorDetails.identityIconMarginRight
        ) {
            if let identityIcon = self.identityIcon {
                identityIcon
                    .resizable()
                    .frame(
                        width: UI.Dimension.ValidatorDetails.identityIconSize,
                        height: UI.Dimension.ValidatorDetails.identityIconSize
                    )
            }
            Text(self.identityDisplay)
                .font(UI.Font.ValidatorDetails.identityDisplay)
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .truncationMode(.middle)
            Spacer()
                .frame(width: UI.Dimension.ValidatorDetails.identityIconSize / 2)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var nominationTotalView: some View {
        DataPanelView(localized("validator_details.nomination_total")) {
            HStack(alignment: .center, spacing: 8) {
                if let validatorDetails = self.viewModel.validatorDetails {
                    Text(formatBalance(
                        balance: validatorDetails.nominationTotal,
                        tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.viewModel.network.tokenTicker)
                        .font(UI.Font.Common.tickerLarge)
                        .foregroundColor(Color("Text"))
                        .opacity(0.6)
                } else {
                    Text("-")
                        .font(UI.Font.Common.tickerLarge)
                        .foregroundColor(Color("Text"))
                }
            }
        }
    }
    
    private var selfStakeView: some View {
        DataPanelView(localized("validator_details.self_stake")) {
            HStack(alignment: .center, spacing: 8) {
                if let selfStake = self.viewModel.validatorDetails?.selfStake {
                    Text(formatBalance(
                        balance: selfStake.activeAmount,
                        tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.viewModel.network.tokenTicker)
                        .font(UI.Font.Common.tickerLarge)
                        .foregroundColor(Color("Text"))
                        .opacity(0.6)
                } else {
                    Text("-")
                        .font(UI.Font.Common.tickerLarge)
                        .foregroundColor(Color("Text"))
                }
            }
        }
    }
    
    private var activeStakeView: some View {
        let activeStakeCount = self.viewModel.validatorDetails?.validatorStake?.nominators.count
        let title = (activeStakeCount == nil)
            ? localized("validator_details.active_stake")
            : String(
                format: localized("validator_details.active_stake_with_count"),
                activeStakeCount!
            )
        return VStack(
            alignment: .leading,
            spacing: UI.Dimension.Common.dataPanelContentMarginTop
        ) {
            Group {
                HStack {
                    Text(title)
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.activeNominatorListIsVisible {
                        UI.Image.Common.arrowUp(self.colorScheme)
                    } else {
                        UI.Image.Common.arrowDown(self.colorScheme)
                    }

                }
                HStack(alignment: .center, spacing: 8) {
                    if let activeStake = self.viewModel.validatorDetails?.validatorStake {
                        Text(formatBalance(
                            balance: activeStake.totalStake,
                            tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                        ))
                        .font(UI.Font.Common.balanceLarge)
                        .foregroundColor(Color("Text"))
                        Text(self.viewModel.network.tokenTicker)
                            .font(UI.Font.Common.tickerLarge)
                            .foregroundColor(Color("Text"))
                            .opacity(0.6)
                    } else {
                        Text("-")
                            .font(UI.Font.Common.tickerLarge)
                            .foregroundColor(Color("Text"))
                    }
                }
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: 0,
                trailing: UI.Dimension.Common.dataPanelPadding
            ))
            if self.activeNominatorListIsVisible {
                let onekvNominators = self.onekvNominators[self.networkId] ?? []
                if let nominators = self.viewModel.activeNominations {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(nominators, id: \.self.account.id) { nominator in
                                HStack(alignment: .center) {
                                    Text(truncateAddress(nominator.account.address))
                                        .font(UI.Font.ValidatorDetails.nominator)
                                        .foregroundColor(Color("Text"))
                                        .lineLimit(1)
                                    if onekvNominators.contains(nominator.account.address) {
                                        Spacer()
                                            .frame(width: 4)
                                        Text("(1KV)")
                                            .font(UI.Font.ValidatorDetails.nominator)
                                            .foregroundColor(Color("Text"))
                                    }
                                    Spacer()
                                    Text(formatBalance(
                                        balance: nominator.stake,
                                        tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                                    ))
                                    .font(UI.Font.ValidatorDetails.nominator)
                                    .foregroundColor(Color("Text"))
                                    .lineLimit(1)
                                }
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: UI.Dimension.Common.dataPanelPadding,
                                    bottom: 0,
                                    trailing: UI.Dimension.Common.dataPanelPadding
                                ))
                            }
                        }
                    }
                    .frame(minHeight: .zero, maxHeight: 250)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: 0,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: 0
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    
    private var inactiveNominationsView: some View {
        let title = (self.viewModel.inactiveNominationCount == nil)
            ? localized("validator_details.inactive_nominations")
            : String(
                format: localized("validator_details.inactive_nominations_with_count"),
                self.viewModel.inactiveNominationCount ?? 0
            )
        return VStack(
            alignment: .leading,
            spacing: UI.Dimension.Common.dataPanelContentMarginTop
        ) {
            Group {
                HStack {
                    Text(title)
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if (self.viewModel.inactiveNominationCount ?? 0) > 0 {
                        if self.inactiveNominatorListIsVisible {
                            UI.Image.Common.arrowUp(self.colorScheme)
                        } else {
                            UI.Image.Common.arrowDown(self.colorScheme)
                        }
                    }
                }
                HStack(alignment: .center, spacing: 8) {
                    if let inactiveNominationTotal = self.viewModel.inactiveNominationTotal {
                        Text(formatBalance(
                            balance: inactiveNominationTotal,
                            tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                        ))
                        .font(UI.Font.Common.balanceLarge)
                        .foregroundColor(Color("Text"))
                        Text(self.viewModel.network.tokenTicker)
                            .font(UI.Font.Common.tickerLarge)
                            .foregroundColor(Color("Text"))
                            .opacity(0.6)
                    } else {
                        Text("-")
                            .font(UI.Font.Common.tickerLarge)
                            .foregroundColor(Color("Text"))
                    }
                }
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: 0,
                trailing: UI.Dimension.Common.dataPanelPadding
            ))
            if self.inactiveNominatorListIsVisible {
                let onekvNominators = self.onekvNominators[self.networkId] ?? []
                if let nominators = self.viewModel.inactiveNominations {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(nominators, id: \.self.stashAccount.id) { nominator in
                                HStack(alignment: .center) {
                                    Text(truncateAddress(nominator.stashAccount.address))
                                        .font(UI.Font.ValidatorDetails.nominator)
                                        .foregroundColor(Color("Text"))
                                        .lineLimit(1)
                                    if onekvNominators.contains(nominator.stashAccount.address) {
                                        Spacer()
                                            .frame(width: 4)
                                        Text("(1KV)")
                                            .font(UI.Font.ValidatorDetails.nominator)
                                            .foregroundColor(Color("Text"))
                                    }
                                    Spacer()
                                    Text(formatBalance(
                                        balance: nominator.stake.activeAmount,
                                        tokenDecimalCount: self.viewModel.network.tokenDecimalCount
                                    ))
                                    .font(UI.Font.ValidatorDetails.nominator)
                                    .foregroundColor(Color("Text"))
                                    .lineLimit(1)
                                }
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: UI.Dimension.Common.dataPanelPadding,
                                    bottom: 0,
                                    trailing: UI.Dimension.Common.dataPanelPadding
                                ))
                            }
                        }
                    }
                    .frame(minHeight: .zero, maxHeight: 250)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: 0,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: 0
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var rewardDestinationView: some View {
        DataPanelView(localized("validator_details.reward_destination")) {
            if let destination = self.viewModel.validatorDetails?.rewardDestination {
                Text(destination.getDisplay(
                    ss58Prefix: UInt16(self.viewModel.network.ss58Prefix))
                )
                .font(UI.Font.Common.dataMedium)
                .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var commissionView: some View {
        DataPanelView(localized("validator_details.commission")) {
            if let commissionPerBillion = self.viewModel.validatorDetails?.preferences.commissionPerBillion {
                Text(String(
                    format: localized("common.percentage"),
                    formatDecimal(
                        integer: commissionPerBillion,
                        decimalCount: 7,
                        formatDecimalCount: 2
                    )
                ))
                .font(UI.Font.Common.dataMedium)
                .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var aprView: some View {
        DataPanelView(localized("validator_details.apr")) {
            if let aprPerBillion = self.viewModel.validatorDetails?.returnRatePerBillion {
                Text(String(
                    format: localized("common.percentage"),
                    formatDecimal(
                        integer: aprPerBillion,
                        decimalCount: 7,
                        formatDecimalCount: 2
                    )
                ))
                .font(UI.Font.Common.dataMedium)
                .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var unclaimedErasView: some View {
        DataPanelView(localized("validator_details.unclaimed_eras")) {
            if let unclaimedEraIndices = self.viewModel.validatorDetails?.unclaimedEraIndices,
               unclaimedEraIndices.count > 0 {
                let text = unclaimedEraIndices.map { "\($0)" }.joined(separator: ", ")
                Text(text)
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var accountAgeView: some View {
        DataPanelView(localized("validator_details.account_age")) {
            if let discoveredAt = self.viewModel.validatorDetails?.account.discoveredAt {
                Text(self.getTimePeriodString(timestampMs: discoveredAt))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                    .minimumScaleFactor(0.1)
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var eraPointsView: some View {
        DataPanelView(localized("validator_details.era_points")) {
            if let points = self.viewModel.validatorDetails?.rewardPoints {
                Text(String(points))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var eraBlocksView: some View {
        DataPanelView(localized("validator_details.era_blocks")) {
            if let blocks = self.viewModel.validatorDetails?.blocksAuthored {
                Text(String(blocks))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var offlineFaultsView: some View {
        DataPanelView(
            localized("validator_details.offline_faults"),
            isVertical: false
        ) {
            if let offenceCount = self.viewModel.validatorDetails?.offlineOffenceCount {
                HStack(
                    alignment: .center,
                    spacing: 12
                ) {
                    Text(String(offenceCount))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                    if offenceCount > 0 {
                        Image("OfflineFaultExclamationIcon")
                    }
                }
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var onekvRankView: some View {
        DataPanelView(
            localized("validator_details.onekv.rank"),
            isVertical: false
        ) {
            if let rank = self.viewModel.validatorDetails?.onekvRank {
                Text(String(rank))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var onekvLocationView: some View {
        DataPanelView(
            localized("validator_details.onekv.location"),
            isVertical: false
        ) {
            if let location = self.viewModel.validatorDetails?.onekvLocation {
                Text(location)
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var onekvUptimeView: some View {
        DataPanelView(localized("validator_details.onekv.uptime")) {
            HStack(alignment: .center, spacing: 8) {
                Image("UptimeIcon")
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    private var onekvDowntimeView: some View {
        DataPanelView(localized("validator_details.onekv.downtime")) {
            HStack(alignment: .center, spacing: 8) {
                Image("DowntimeIcon")
                if let offlineSince = self.viewModel.validatorDetails?.onekvOfflineSince,
                   offlineSince > 0 {
                    Text(self.getTimePeriodString(timestampMs: offlineSince))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("StatusError"))
                } else {
                    Text("-")
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("StatusError"))
                }
            }
        }
    }
    
    private var onekvValidityView: some View {
        DataPanelView(
            localized("validator_details.onekv.validity"),
            isVertical: false
        ) {
            if let isValid = self.viewModel.validatorDetails?.onekvIsValid {
                if isValid {
                    Text(localized("validator_details.onekv.valid"))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                } else {
                    Text(localized("validator_details.onekv.invalid"))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("StatusError"))
                }
            } else {
                Text("-")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
        }
    }
}

struct ValidatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorDetailsView(
            networkId: PreviewData.validatorSummary.networkId,
            accountId: PreviewData.stashAccountId
        )
    }
}
