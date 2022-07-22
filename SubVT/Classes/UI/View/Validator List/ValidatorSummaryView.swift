//
//  ValidatorSummaryView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 19.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorSummaryView: View {
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    private var validatorSummary: ValidatorSummary
    
    init(validatorSummary: ValidatorSummary) {
        self.validatorSummary = validatorSummary
    }
    
    var display: String {
        get {
            if let parentDisplay = self.validatorSummary.parentDisplay,
               let childDisplay = self.validatorSummary.childDisplay {
                return "\(parentDisplay) / \(childDisplay)"
            } else if let display = self.validatorSummary.display {
                return display
            } else {
                if let address = try? self.validatorSummary.accountId.toSS58Check(
                    prefix: UInt16(self.network.ss58Prefix)
                ) {
                    return "\(address.prefix(5))...\(address.suffix(5))"
                } else {
                    return ""
                }
            }
        }
    }
    
    var amountDisplay: String {
        get {
            let inactive = formatBalance(
                balance: self.validatorSummary.inactiveNominations.totalAmount,
                tokenDecimalCount: Int(self.network.tokenDecimalCount)
            )
            let inactiveCount = self.validatorSummary.inactiveNominations.nominationCount
            if self.validatorSummary.isActive,
               let stakeSummary = self.validatorSummary.validatorStake {
                let active = formatBalance(
                    balance: stakeSummary.totalStake,
                    tokenDecimalCount: Int(self.network.tokenDecimalCount)
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
                Text(self.display)
                    .font(UI.Font.ValidatorSummary.display)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                HStack(spacing: UI.Dimension.ValidatorSummary.iconSpacing) {
                    // identity
                    if self.validatorSummary.parentDisplay != nil {
                        if self.validatorSummary.confirmed {
                            Image("ParentIdentityConfirmedIcon")
                                
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        } else {
                            Image("ParentIdentityNotConfirmedIcon")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        }
                    } else if self.validatorSummary.display != nil {
                        if self.validatorSummary.confirmed {
                            Image("IdentityConfirmedIcon")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        } else {
                            Image("IdentityNotConfirmedIcon")
                                .resizable()
                                .frame(
                                    width: UI.Dimension.ValidatorSummary.iconSize,
                                    height: UI.Dimension.ValidatorSummary.iconSize
                                )
                        }
                    }
                    if self.validatorSummary.isEnrolledIn1Kv {
                        Image("1KVIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.isParaValidator {
                        Image("ParaValidatorIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.activeNextSession {
                        Image("ActiveNextSessionIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.heartbeatReceived ?? false {
                        Image("HeartbeatReceivedIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.oversubscribed {
                        Image("OversubscribedIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.preferences.blocksNominations {
                        Image("BlocksNominationsIcon")
                            .resizable()
                            .frame(
                                width: UI.Dimension.ValidatorSummary.iconSize,
                                height: UI.Dimension.ValidatorSummary.iconSize
                            )
                    }
                    if self.validatorSummary.slashCount > 0 {
                        Image("SlashedIcon")
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
            HStack {
                Text(self.amountDisplay)
                    .font(UI.Font.ValidatorSummary.balance)
                    .foregroundColor(Color("Text"))
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(
            top: UI.Dimension.ValidatorSummary.padding,
            leading: UI.Dimension.ValidatorSummary.padding,
            bottom: UI.Dimension.ValidatorSummary.padding,
            trailing: UI.Dimension.ValidatorSummary.padding
        )).background(Color("DataPanelBg"))
        .cornerRadius(16)
    }
}

struct ValidatorSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorSummaryView(validatorSummary: PreviewData.validatorSummary)
    }
}
