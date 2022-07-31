//
//  DataPanelView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 31.07.2022.
//

import Foundation
import SwiftUI

struct DataPanelView<Content: View>: View {
    private let isVertical: Bool
    private let title: String
    private let content: () -> Content
    
    init(
        _ title: String,
        isVertical: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isVertical = isVertical
        self.content = content
    }

    var body: some View {
        if self.isVertical {
            VStack(
                alignment: .leading,
                spacing: UI.Dimension.Common.dataPanelContentMarginTop
            ) {
                Text(title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                self.content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: UI.Dimension.Common.dataPanelPadding
            ))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
        } else {
            HStack(
                alignment: .center,
                spacing: UI.Dimension.Common.dataPanelContentMarginTop
            ) {
                Text(title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                self.content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(
                top: UI.Dimension.Common.dataPanelPadding,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: UI.Dimension.Common.dataPanelPadding,
                trailing: UI.Dimension.Common.dataPanelPadding
            ))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
        }
    }
}
