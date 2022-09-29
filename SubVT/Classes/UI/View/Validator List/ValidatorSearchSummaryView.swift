//
//  ValidatorSearchSummaryView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.09.2022.
//

import SubVTData
import SwiftUI

struct ValidatorSearchSummaryView: View {
    private let validatorSearchSummary: ValidatorSearchSummary
    private var network: Network
    private let canAdd: Bool
    private let isLoading: Bool
    private let onAdd: () -> ()
    
    var amountDisplay: String {
        get {
            let inactive = formatBalance(
                balance: self.validatorSearchSummary.inactiveNominations.totalAmount,
                tokenDecimalCount: self.network.tokenDecimalCount
            )
            let inactiveCount = self.validatorSearchSummary.inactiveNominations.nominationCount
            if let stakeSummary = self.validatorSearchSummary.validatorStake {
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
    
    init(
        validatorSearchSummary: ValidatorSearchSummary,
        network: Network,
        canAdd: Bool,
        isLoading: Bool,
        onAdd: @escaping (() -> ())
    ) {
        self.validatorSearchSummary = validatorSearchSummary
        self.network = network
        self.canAdd = canAdd
        self.isLoading = isLoading
        self.onAdd = onAdd
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                HStack(alignment: .center) {
                    if self.validatorSearchSummary.parentDisplay != nil {
                        if self.validatorSearchSummary.confirmed {
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
                    } else if self.validatorSearchSummary.display != nil {
                        if self.validatorSearchSummary.confirmed {
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
                    Text(validatorSearchSummary.identityDisplay)
                        .font(UI.Font.ValidatorSummary.display)
                        .foregroundColor(Color("Text"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
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
            }
            Spacer()
            ZStack {
                Button {
                    self.onAdd()
                } label: {
                    Image("AddValidatorButton")
                        .saturation(self.canAdd ? 1.0 : 0.0)
                }
                .opacity(self.isLoading ? 0.0 : 1.0)
                .disabled(self.isLoading || !self.canAdd)
                if self.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Color("Text").opacity(0.5)
                            )
                        )
                }
            }
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

struct ValidatorSearchSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorSearchSummaryView(
            validatorSearchSummary: PreviewData.validatorSearchSummary,
            network: PreviewData.kusama,
            canAdd: true,
            isLoading: false
        ) {
            // no-op
        }
    }
}
