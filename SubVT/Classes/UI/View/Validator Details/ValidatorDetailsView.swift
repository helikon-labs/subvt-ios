//
//  ValidatorDetailsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorDetailsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @StateObject private var viewModel = ValidatorDetailsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var lastScroll: CGFloat = 0
    let validatorSummary: ValidatorSummary
    
    var identityDisplay: String {
        return self.viewModel.validatorDetails?.identityDisplay
            ?? validatorSummary.identityDisplay
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
        } else if self.validatorSummary.parentDisplay != nil {
            if self.validatorSummary.confirmed {
                return Image("ParentIdentityConfirmedIcon")
            } else {
                return Image("ParentIdentityNotConfirmedIcon")
            }
        } else if self.validatorSummary.display != nil {
            if self.validatorSummary.confirmed {
                return Image("IdentityConfirmedIcon")
            } else {
                return Image("IdentityNotConfirmedIcon")
            }
        }
        return nil
    }
    
    private func getIcon(_ name: String) -> some View {
        return Button {
            // no-op
        } label: {
            Image(name)
                .resizable()
                .frame(
                    width: UI.Dimension.ValidatorDetails.iconSize,
                    height: UI.Dimension.ValidatorDetails.iconSize
                )
        }
        .buttonStyle(PushButtonStyle())
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
        } else {
            return self.validatorSummary.isEnrolledIn1Kv
        }
    }
    
    private var isParaValidator: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.isParaValidator
        } else {
            return self.validatorSummary.isParaValidator
        }
    }
    
    private var isActiveNextSession: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.activeNextSession
        } else {
            return self.validatorSummary.activeNextSession
        }
    }
    
    private var heartbeatReceived: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.heartbeatReceived ?? false
        } else {
            return self.validatorSummary.heartbeatReceived ?? false
        }
    }
    
    private var isOversubscribed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.oversubscribed
        } else {
            return self.validatorSummary.oversubscribed
        }
    }
    
    private var blocksNominations: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.preferences.blocksNominations
        } else {
            return self.validatorSummary.preferences.blocksNominations
        }
    }
    
    private var hasBeenSlashed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.slashCount > 0
        } else {
            return self.validatorSummary.slashCount > 0
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
                        Button(
                            action: {
                                self.viewModel.unsubscribe()
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            label: {
                                BackButtonView()
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(1, self.displayState))
                        Spacer()
                        NetworkSelectorButtonView()
                            .modifier(PanelAppearance(2, self.displayState))
                        Button(
                            action: {
                                // add validator
                            },
                            label: {
                                ZStack {
                                    UI.Image.ValidatorDetails.addValidatorIcon(self.colorScheme)
                                }
                                .frame(
                                    width: UI.Dimension.Common.networkSelectorHeight,
                                    height: UI.Dimension.Common.networkSelectorHeight
                                )
                                .background(Color("NetworkSelectorBg"))
                                .cornerRadius(UI.Dimension.Common.cornerRadius)
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(3, self.displayState))
                        Button(
                            action: {
                                // validator reports
                            },
                            label: {
                                ZStack {
                                    UI.Image.ValidatorDetails.validatorReportsIcon(self.colorScheme)
                                }
                                .frame(
                                    width: UI.Dimension.Common.networkSelectorHeight,
                                    height: UI.Dimension.Common.networkSelectorHeight
                                )
                                .background(Color("NetworkSelectorBg"))
                                .cornerRadius(UI.Dimension.Common.cornerRadius)
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(4, self.displayState))
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
                        IdenticonSceneView(accountId: self.validatorSummary.accountId)
                            .frame(height: UI.Dimension.ValidatorDetails.identiconHeight)
                            .modifier(PanelAppearance(5, self.displayState))
                        VStack(
                            alignment: .leading,
                            spacing: UI.Dimension.Common.dataPanelSpacing
                        ) {
                            self.identityDisplayView
                                .modifier(PanelAppearance(6, self.displayState))
                            Spacer()
                                .frame(height: 4)
                            Group {
                                self.nominationTotalView
                                    .modifier(PanelAppearance(7, self.displayState))
                                self.selfStakeView
                                    .modifier(PanelAppearance(8, self.displayState))
                                if let _ = self.viewModel.validatorDetails?.validatorStake {
                                    self.activeStakeView
                                        .modifier(PanelAppearance(9, self.displayState))
                                }
                                self.inactiveNominationsView
                                    .modifier(PanelAppearance(10, self.displayState))
                                if let _ = self.viewModel.validatorDetails?.account.discoveredAt {
                                    self.accountAgeView
                                        .modifier(PanelAppearance(11, self.displayState))
                                }
                                self.offlineFaultsView
                                    .modifier(PanelAppearance(12, self.displayState))
                                self.rewardDestinationView
                                    .modifier(PanelAppearance(13, self.displayState))
                            }
                            Group {
                                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                    self.commissionView
                                    self.aprView
                                }
                                .modifier(PanelAppearance(14, self.displayState))
                                if let _ = self.viewModel.validatorDetails?.validatorStake {
                                    HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                        self.eraBlocksView
                                        self.eraPointsView
                                    }
                                    .modifier(PanelAppearance(15, self.displayState))
                                }
                            }
                            if self.validatorSummary.isEnrolledIn1Kv {
                                Group {
                                    Spacer()
                                        .frame(height: 8)
                                    Text(localized("validator_details.onekv_section_title"))
                                        .font(UI.Font.ValidatorDetails.subsectionTitle)
                                        .foregroundColor(Color("Text"))
                                        .modifier(PanelAppearance(16, self.displayState))
                                    Spacer()
                                        .frame(height: 8)
                                    self.onekvRankView
                                        .modifier(PanelAppearance(17, self.displayState))
                                    self.onekvLocationView
                                        .modifier(PanelAppearance(18, self.displayState))
                                    self.onekvBinaryVersionView
                                        .modifier(PanelAppearance(19, self.displayState))
                                    if self.viewModel.validatorDetails?.onekvOnlineSince ?? 0 > 0 {
                                        self.onekvUptimeView
                                            .modifier(PanelAppearance(20, self.displayState))
                                    } else if self.viewModel.validatorDetails?.onekvOfflineSince ?? 0 > 0 {
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
            HStack(alignment: .center) {
                if self.isOneKV {
                    self.getIcon("1KVIcon")
                }
                if self.isParaValidator {
                    self.getIcon("ParaValidatorIcon")
                }
                if self.isActiveNextSession {
                    self.getIcon("ActiveNextSessionIcon")
                }
                if self.heartbeatReceived {
                    self.getIcon("HeartbeatReceivedIcon")
                }
                if self.isOversubscribed {
                    self.getIcon("OversubscribedIcon")
                }
                if self.blocksNominations {
                    self.getIcon("BlocksNominationsIcon")
                }
                if self.blocksNominations {
                    self.getIcon("BlocksNominationsIcon")
                }
                if self.hasBeenSlashed {
                    self.getIcon("SlashedIcon")
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(EdgeInsets(
                top: 0,
                leading: 0,
                bottom: UI.Dimension.ValidatorDetails.iconContainerMarginBottom,
                trailing: 0
            ))
            .zIndex(2)
            .modifier(PanelAppearance(5, self.displayState))
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
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.subscribeToValidatorDetails(
                        network: self.network,
                        accountId: self.validatorSummary.accountId
                    )
                }
            }
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
                        tokenDecimalCount: self.network.tokenDecimalCount,
                        integerOnly: false
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.network.tokenTicker)
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
                        tokenDecimalCount: self.network.tokenDecimalCount,
                        integerOnly: false
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.network.tokenTicker)
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
        return DataPanelView(title) {
            HStack(alignment: .center, spacing: 8) {
                if let activeStake = self.viewModel.validatorDetails?.validatorStake {
                    Text(formatBalance(
                        balance: activeStake.totalStake,
                        tokenDecimalCount: self.network.tokenDecimalCount,
                        integerOnly: false
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.network.tokenTicker)
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
    
    private var inactiveNominationsView: some View {
        let inactiveNominationCount = self.viewModel.validatorDetails?.inactiveNominations.count
        let title = (inactiveNominationCount == nil)
            ? localized("validator_details.inactive_nominations")
            : String(
                format: localized("validator_details.inactive_nominations_with_count"),
                inactiveNominationCount!
            )
        return DataPanelView(title) {
            HStack(alignment: .center, spacing: 8) {
                if let inactiveNominationTotal = self.viewModel.validatorDetails?.inactiveNominationTotal {
                    Text(formatBalance(
                        balance: inactiveNominationTotal,
                        tokenDecimalCount: self.network.tokenDecimalCount,
                        integerOnly: false
                    ))
                    .font(UI.Font.Common.balanceLarge)
                    .foregroundColor(Color("Text"))
                    Text(self.network.tokenTicker)
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
    
    private var rewardDestinationView: some View {
        DataPanelView(localized("validator_details.reward_destination")) {
            if let destination = self.viewModel.validatorDetails?.rewardDestination {
                Text(destination.getDisplay(
                    ss58Prefix: UInt16(self.network.ss58Prefix))
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
    
    private var onekvBinaryVersionView: some View {
        DataPanelView(
            localized("validator_details.onekv.binary_version"),
            isVertical: false
        ) {
            if let version = self.viewModel.validatorDetails?.onekvBinaryVersion {
                Text(version)
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
                if let onlineSince = self.viewModel.validatorDetails?.onekvOnlineSince,
                   onlineSince > 0 {
                    Text(self.getTimePeriodString(timestampMs: onlineSince))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                } else {
                    Text("-")
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                }
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
        ValidatorDetailsView(validatorSummary: PreviewData.validatorSummary)
    }
}
