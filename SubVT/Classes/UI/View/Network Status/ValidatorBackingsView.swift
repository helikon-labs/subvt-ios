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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(localized("network_status.validator_backings"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(height: UI.Dimension.Common.dataPanelPadding)
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.minimum"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.minimum,
                        tokenDecimalCount: Int(self.network.tokenDecimalCount),
                        integerOnly: true
                    ))
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text("/")
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                    .opacity(separatorOpacity)
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.average"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.average,
                        tokenDecimalCount: Int(self.network.tokenDecimalCount),
                        integerOnly: true
                    ))
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text("/")
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                    .opacity(separatorOpacity)
                VStack(alignment: .leading, spacing: 6) {
                    Text(localized("network_status.maximum"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Text(formatBalance(
                        balance: self.maximum,
                        tokenDecimalCount: Int(self.network.tokenDecimalCount),
                        integerOnly: true
                    ))
                    .font(UI.Font.NetworkStatus.dataMedium)
                    .foregroundColor(Color("Text"))
                }
                Text(self.network.tokenTicker)
                    .font(UI.Font.NetworkStatus.dataMedium)
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
