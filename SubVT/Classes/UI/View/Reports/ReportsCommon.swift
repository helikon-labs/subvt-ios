//
//  ReportsCommon.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.12.2022.
//

import SwiftUI

struct ReportDataPanelView: View {
    let title: String
    let content: String
    
    private let height: CGFloat = 66
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.title)
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
            Spacer()
            Text(self.content)
                .font(UI.Font.NetworkStatus.dataLarge)
                .foregroundColor(Color("Text"))
        }
        .frame(height: self.height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(UI.Dimension.Common.dataPanelPadding)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct ReportLineChartView: View {
    private let title: String
    private let dataPoints: [(Int, Int)]
    private let minY: Int
    private let maxY: Int
    private let revealPercentage: CGFloat
    private let colorScheme: ColorScheme
    
    init(
        title: String,
        dataPoints: [(Int, Int)],
        minY: Int,
        maxY: Int,
        revealPercentage: CGFloat,
        colorScheme: ColorScheme
    ) {
        self.title = title
        self.dataPoints = dataPoints
        self.minY = minY
        self.maxY = maxY
        self.revealPercentage = revealPercentage
        self.colorScheme = colorScheme
    }

    var body: some View {
        ZStack {
            LineChartView(
                dataPoints: self.dataPoints,
                chartMinY: self.minY,
                chartMaxY: self.maxY,
                revealPercentage: self.revealPercentage
            )
            .frame(height: 128)
            .padding(EdgeInsets(
                top: 0,
                leading: 4,
                bottom: 0,
                trailing: 4
            ))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.cornerRadius)
            VStack {
                HStack(alignment: .center) {
                    Text(title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .truncationMode(.middle)
                        .font(UI.Font.Common.dataPanelTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    UI.Image.NetworkStatus.arrowRight(self.colorScheme)
                }
                .padding(EdgeInsets(
                    top: UI.Dimension.Common.dataPanelPadding,
                    leading: UI.Dimension.Common.dataPanelPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.dataPanelPadding
                ))
                Spacer()
            }
        }
    }
}

struct ReportBarChartView: View {
    private let title: String
    private let dataPoints: [(Int, Double)]
    private let minY: Double
    private let maxY: Double
    private let revealPercentage: CGFloat
    private let colorScheme: ColorScheme
    
    init(
        title: String,
        dataPoints: [(Int, Double)],
        minY: Double,
        maxY: Double,
        revealPercentage: CGFloat,
        colorScheme: ColorScheme
    ) {
        self.title = title
        self.dataPoints = dataPoints
        self.minY = minY
        self.maxY = maxY
        self.revealPercentage = revealPercentage
        self.colorScheme = colorScheme
    }

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(self.title)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .truncationMode(.middle)
                .font(UI.Font.Common.dataPanelTitle)
                .foregroundColor(Color("Text"))
                Spacer()
                UI.Image.NetworkStatus.arrowRight(self.colorScheme)
            }
            BarChartView(
                dataPoints: self.dataPoints,
                chartMinY: self.minY,
                chartMaxY: self.maxY,
                revealPercentage: self.revealPercentage
            )
        }
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: UI.Dimension.Common.dataPanelPadding,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: UI.Dimension.Common.dataPanelPadding
        ))
        .frame(height: 128)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
}

enum ReportDataFactor {
    case none
    case hundred
    case thousand
    case million
    
    var description: String? {
        switch self {
        case .none:
            return nil
        case .hundred:
            return localized("common.factor.hundred")
        case .thousand:
            return localized("common.factor.thousand")
        case .million:
            return localized("common.factor.million")
        }
    }
    
    var descriptionPlural: String? {
        switch self {
        case .none:
            return nil
        case .hundred:
            return localized("common.factor.hundreds")
        case .thousand:
            return localized("common.factor.thousands")
        case .million:
            return localized("common.factor.millions")
        }
    }
    
    var symbol: String? {
        switch self {
        case .none:
            return nil
        case .hundred:
            return "H"
        case .thousand:
            return "K"
        case .million:
            return "M"
        }
    }
    
    var decimals: UInt8 {
        switch self {
        case .none:
            return 0
        case .hundred:
            return 2
        case .thousand:
            return 3
        case .million:
            return 6
        }
    }
}

let reportGradient = LinearGradient(
    gradient: Gradient(
        colors: [
            Color("Green"),
            Color("Blue")
        ]
    ),
    startPoint: .bottom,
    endPoint: .top
)
