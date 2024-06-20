//
//  ValidatorSummaryView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 19.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorSummaryView: View {
    private var validatorSummary: ValidatorSummary
    private var network: Network
    private var displaysNetworkIcon: Bool
    private var displaysActiveStatus: Bool
    
    init(
        validatorSummary: ValidatorSummary,
        network: Network,
        displaysNetworkIcon: Bool = false,
        displaysActiveStatus: Bool = false
    ) {
        self.validatorSummary = validatorSummary
        self.network = network
        self.displaysNetworkIcon = displaysNetworkIcon
        self.displaysActiveStatus = displaysActiveStatus
    }
    
    var nominationView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let inactive = formatBalance(
                balance: self.validatorSummary.inactiveNominations.totalAmount,
                tokenDecimalCount: self.network.tokenDecimalCount
            )
            let inactiveCount = self.validatorSummary.inactiveNominations.nominationCount
            if self.validatorSummary.isActive,
               let stakeSummary = self.validatorSummary.validatorStake {
                let active = formatBalance(
                    balance: stakeSummary.totalStake,
                    tokenDecimalCount: self.network.tokenDecimalCount
                )
                let activeCount = stakeSummary.nominatorCount
                HStack(alignment: .center, spacing: 6) {
                    Circle().fill(Color("StatusActive")).frame(width: 6, height: 6)
                    Text("(\(activeCount)) \(active) \(self.network.tokenTicker)")
                        .font(UI.Font.ValidatorSummary.balance)
                        .foregroundColor(Color("Text"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .center, spacing: 6) {
                Circle().fill(Color("StatusWaiting")).frame(width: 6, height: 6)
                Text("(\(inactiveCount)) \(inactive) \(self.network.tokenTicker)")
                    .font(UI.Font.ValidatorSummary.balance)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(alignment: .topLeading)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .center) {
                if displaysNetworkIcon {
                    UI.Image.Common.networkIcon(network: self.network)
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.parentDisplay != nil {
                    if self.validatorSummary.confirmed {
                        Image("ParentIdentityConfirmedIconSmall")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    } else {
                        Image("ParentIdentityNotConfirmedIconSmall")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                } else if self.validatorSummary.display != nil {
                    if self.validatorSummary.confirmed {
                        Image("IdentityConfirmedIconSmall")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    } else {
                        Image("IdentityNotConfirmedIconSmall")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                }
                Text(validatorSummary.identityDisplayNoParent)
                    .font(UI.Font.ValidatorSummary.display)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            self.nominationView
                .frame(maxWidth: .infinity)
            HStack(spacing: 4) {
                if self.validatorSummary.isEnrolledIn1Kv {
                    Image("1KVIcon")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.isParaValidator {
                    Image("ParaValidatorIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.isActiveNextSession {
                    Image("ActiveNextSessionIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.heartbeatReceived ?? false {
                    Image("HeartbeatReceivedIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.oversubscribed {
                    Image("OversubscribedIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.preferences.blocksNominations {
                    Image("BlocksNominationsIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                if self.validatorSummary.slashCount > 0 {
                    Image("SlashedIconSmall")
                        .resizable()
                        .frame(
                            width: UI.Dimension.ValidatorSummary.iconSize,
                            height: UI.Dimension.ValidatorSummary.iconSize
                        )
                }
                Spacer()
                if self.displaysActiveStatus {
                    Text(
                        self.validatorSummary.isActive
                            ? localized("common.validator.active")
                            : localized("common.validator.inactive")
                    )
                    .font(UI.Font.ValidatorSummary.balance)
                    .foregroundColor(
                        self.validatorSummary.isActive
                            ? Color("ValidatorActive")
                            : Color("ValidatorInactive")
                    )
                }
                
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color("DataPanelBg"))
        .cornerRadius(8)
    }
}
