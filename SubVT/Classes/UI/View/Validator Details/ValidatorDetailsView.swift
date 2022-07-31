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
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.ValidatorDetails.scrollContentMarginTop)
                        IdenticonSceneView(accountId: self.validatorSummary.accountId)
                            .frame(height: UI.Dimension.ValidatorDetails.identiconHeight)
                            .modifier(PanelAppearance(5, self.displayState))
                        VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                            self.identityDisplayView
                                .modifier(PanelAppearance(6, self.displayState))
                            Spacer()
                                .frame(height: 4)
                            self.nominationTotalView
                                .modifier(PanelAppearance(7, self.displayState))
                            self.selfStakeView
                                .modifier(PanelAppearance(8, self.displayState))
                            self.activeStakeView
                                .modifier(PanelAppearance(9, self.displayState))
                            self.inactiveNominationsView
                                .modifier(PanelAppearance(10, self.displayState))
                            self.rewardDestinationView
                                .modifier(PanelAppearance(11, self.displayState))
                            HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                self.commissionView
                                self.aprView
                            }
                            .modifier(PanelAppearance(12, self.displayState))
                            self.unclaimedErasView
                                .modifier(PanelAppearance(13, self.displayState))
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
                        self.headerMaterialOpacity = max($0, 0) / 20.0
                    }
                }
            }
            FooterGradientView()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
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
    }
    
    private var nominationTotalView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(localized("validator_details.nomination_total"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: UI.Dimension.ValidatorDetails.balancePanelHeight)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var selfStakeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(localized("validator_details.self_stake"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: UI.Dimension.ValidatorDetails.balancePanelHeight)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var activeStakeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let activeStakeCount = self.viewModel.validatorDetails?.validatorStake?.nominators.count {
                Text(String(
                    format: localized("validator_details.active_stake_with_count"),
                    activeStakeCount
                ))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            } else {
                Text(localized("validator_details.active_stake"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            }
            Spacer()
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: UI.Dimension.ValidatorDetails.balancePanelHeight)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var inactiveNominationsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let inactiveNominationCount = self.viewModel.validatorDetails?.inactiveNominations.count {
                Text(String(
                    format: localized("validator_details.inactive_nominations_with_count"),
                    inactiveNominationCount
                ))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            } else {
                Text(localized("validator_details.inactive_nominations"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            }
            Spacer()
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
        .frame(height: UI.Dimension.ValidatorDetails.balancePanelHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var rewardDestinationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("validator_details.reward_destination"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            if let destination = self.viewModel.validatorDetails?.rewardDestination {
                Text(destination.getDisplay(
                    ss58Prefix: UInt16(self.network.ss58Prefix))
                )
                .font(UI.Font.Common.dataMedium)
                .foregroundColor(Color("Text"))
            } else {
                Text("-")
                    .font(UI.Font.Common.tickerLarge)
                    .foregroundColor(Color("Text"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var commissionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("validator_details.commission"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
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
                    .font(UI.Font.Common.tickerLarge)
                    .foregroundColor(Color("Text"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var aprView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("validator_details.apr"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
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
                    .font(UI.Font.Common.tickerLarge)
                    .foregroundColor(Color("Text"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
    
    private var unclaimedErasView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("validator_details.unclaimed_eras"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
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
                    .font(UI.Font.Common.tickerLarge)
                    .foregroundColor(Color("Text"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct ValidatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorDetailsView(validatorSummary: PreviewData.validatorSummary)
    }
}
