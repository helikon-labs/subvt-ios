//
//  LastEraTotalRewardView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import SubVTData
import SwiftUI

struct LastEraTotalRewardView: View {
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    
    let reward: Balance
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(localized("network_status.last_era_total_rewards"))
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
            HStack(alignment: .center, spacing: 8) {
                Text(formatBalance(
                    balance: self.reward,
                    tokenDecimalCount: Int(self.network.tokenDecimalCount)
                ))
                .font(UI.Font.NetworkStatus.lastEraTotalReward)
                .foregroundColor(Color("Text"))
                Text(self.network.tokenTicker)
                    .font(UI.Font.NetworkStatus.lastEraTotalRewardTicker)
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
        .frame(height: UI.Dimension.NetworkStatus.lastEraTotalRewardViewHeight.get())
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct LastEraTotalRewardView_Previews: PreviewProvider {
    static var previews: some View {
        LastEraTotalRewardView(reward: Balance(
            integerLiteral: 123456765678543
        )).defaultAppStorage(PreviewData.userDefaults)
    }
}
