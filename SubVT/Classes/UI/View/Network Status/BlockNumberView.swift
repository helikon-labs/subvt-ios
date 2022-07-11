//
//  BlockNumberView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

struct BlockNumberView: View {
    let title: LocalizedStringKey
    let blockNumber: UInt64
    let blockWaveParameters: BlockWaveParameters?
    
    init(
        title: LocalizedStringKey,
        blockNumber: UInt64,
        blockWaveParameters: BlockWaveParameters? = nil
    ) {
        self.title = title
        self.blockNumber = blockNumber
        self.blockWaveParameters = blockWaveParameters
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                Text(String(self.blockNumber))
                    .font(UI.Font.NetworkStatus.dataXLarge)
                    .foregroundColor(Color("Text"))
            }
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: 0))
            Spacer()
            if let blockWaveParameters = self.blockWaveParameters {
                BlockWaveView(parameters: blockWaveParameters)
                .frame(
                    width: UI.Dimension.NetworkStatus.blockWaveViewSize.get(),
                    height: UI.Dimension.NetworkStatus.blockWaveViewSize.get()
                )
                Spacer()
                    .frame(width: 42)
            }
            
        }
        .frame(height: UI.Dimension.NetworkStatus.blockNumberViewHeight)
        .frame(maxWidth: .infinity)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct BlockNumberView_Previews: PreviewProvider {
    static var previews: some View {
        BlockNumberView(
            title: LocalizedStringKey("network_status.finalized_block_number"),
            blockNumber: 11423657,
            blockWaveParameters: BlockWaveParameters(
                offset: Angle(degrees: 0),
                progress: 0.5,
                amplitude: 0.15
            )
        )
    }
}
