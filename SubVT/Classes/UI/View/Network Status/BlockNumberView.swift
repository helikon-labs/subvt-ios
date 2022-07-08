//
//  BlockNumberView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

struct BlockNumberView: View {
    let title: LocalizedStringKey
    var blockNumber: UInt64
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: UI.Dimension.Common.dataPanelPadding)
                Text(String(self.blockNumber))
                    .font(UI.Font.NetworkStatus.dataXLarge)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: UI.Dimension.Common.dataPanelPadding)
            }
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: 0,
                trailing: 0))
            Spacer()
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.red)
            Spacer()
                .frame(width: 42)
            
        }
        .frame(maxWidth: .infinity)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct BlockNumberView_Previews: PreviewProvider {
    static var previews: some View {
        BlockNumberView(
            title: LocalizedStringKey("network_status.finalized_block_number"),
            blockNumber: 11423657
        )
    }
}
