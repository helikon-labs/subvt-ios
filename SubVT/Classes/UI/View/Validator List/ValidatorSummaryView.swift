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
    
    var amountDisplay: String {
        get {
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
                return "(\(activeCount)) \(active) / (\(inactiveCount)) \(inactive) \(self.network.tokenTicker)"
            } else {
                return "(\(inactiveCount)) \(inactive) \(self.network.tokenTicker)"
            }
        }
    }
    
    var body: some View {
        VStack {
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
                Text(validatorSummary.identityDisplay)
                    .font(UI.Font.ValidatorSummary.display)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                HStack(spacing: UI.Dimension.ValidatorSummary.iconSpacing) {
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
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: UI.Dimension.ValidatorSummary.balanceTopMargin)
            HStack(alignment: .center, spacing: 0) {
                Text(self.amountDisplay)
                    .font(UI.Font.ValidatorSummary.balance)
                    .foregroundColor(Color("Text"))
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
        .padding(EdgeInsets(
            top: UI.Dimension.ValidatorSummary.padding,
            leading: UI.Dimension.ValidatorSummary.padding,
            bottom: UI.Dimension.ValidatorSummary.padding,
            trailing: UI.Dimension.ValidatorSummary.padding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(16)
    }
}

struct ValidatorSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorSummaryView(
            validatorSummary: PreviewData.validatorSummary,
            network: PreviewData.kusama
        )
    }
}
