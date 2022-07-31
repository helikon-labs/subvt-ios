//
//  EraPointsBlocksProducedView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 8.07.2022.
//

import SwiftUI

struct EraPointsBlocksProducedView: View {
    let title: String
    let value: UInt64
    let myValidatorsValue: UInt64?
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: 12)
                Text(String(self.value))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: UI.Dimension.Common.dataPanelPadding)
                Text(localized("network_status.my_validators"))
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: 12)
                Text(myValidatorsValue == nil ? "-" : String(myValidatorsValue!))
                    .font(UI.Font.Common.dataMedium)
                    .foregroundColor(Color("Text"))
            }
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: UI.Dimension.Common.dataPanelPadding))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
        } else {
            HStack {
                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: 12)
                    Text(String(self.value))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(localized("network_status.my_validators"))
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: 12)
                    Text(myValidatorsValue == nil ? "-" : String(myValidatorsValue!))
                        .font(UI.Font.Common.dataMedium)
                        .foregroundColor(Color("Text"))
                }
                Spacer()
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
}

struct EraPointsBlocksProducedView_Previews: PreviewProvider {
    static var previews: some View {
        EraPointsBlocksProducedView(
            title: localized("network_status.number_of_blocks"),
            value: 415,
            myValidatorsValue: 13
        )
    }
}
