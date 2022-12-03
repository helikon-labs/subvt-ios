//
//  ValidatorBackingsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorBackingsView: View {
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    
    let minimum: Balance
    let maximum: Balance
    let average: Balance
    
    private let separatorOpacity = 0.4
    
    private var tokenTicker: String {
        if self.network.tokenTicker == "DOT" {
            return "MDOT"
        }
        return self.network.tokenTicker
    }
    
    private var tokenDecimalCount: UInt8 {
        if self.network.tokenTicker == "DOT" {
            return self.network.tokenDecimalCount + 6
        }
        return self.network.tokenDecimalCount
    }
    
    private var showsDecimals: Bool {
        return self.network.tokenTicker == "DOT"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(localized("network_status.validator_backings"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.minimum"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.minimum,
                        tokenDecimalCount: self.tokenDecimalCount,
                        formatDecimalCount: self.showsDecimals ? 4 : 0
                    ))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text("/")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                    .opacity(separatorOpacity)
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.average"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.average,
                        tokenDecimalCount: self.tokenDecimalCount,
                        formatDecimalCount: self.showsDecimals ? 4 : 0
                    ))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text("/")
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                    .opacity(separatorOpacity)
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.maximum"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.maximum,
                        tokenDecimalCount: self.tokenDecimalCount,
                        formatDecimalCount: self.showsDecimals ? 4 : 0
                    ))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text(self.tokenTicker)
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                    .opacity(0.6)
            }
        }
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: UI.Dimension.NetworkStatus.validatorBackingsViewHeight.get())
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct ValidatorBackingsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorBackingsView(
            minimum: Balance(
                integerLiteral: 123456765678543
            ),
            maximum: Balance(
                integerLiteral: 123456765678543
            ),
            average: Balance(
                integerLiteral: 123456765678543
            )
        ).defaultAppStorage(PreviewData.userDefaults)
    }
}
