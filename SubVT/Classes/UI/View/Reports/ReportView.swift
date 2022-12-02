//
//  ReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.11.2022.
//x

import Charts
import SwiftUI
import SubVTData

struct ReportView: View {
    enum `Type` {
        case line
        case bar
    }
    
    enum Factor {
        case none
        case thousand
        case million
        
        var description: String? {
            switch self {
            case .none:
                return nil
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
            case .thousand:
                return 3
            case .million:
                return 6
            }
        }
    }
    
    enum Data {
        case integer(dataPoints: [(Int, Int)])
        case double(dataPoints: [(Int, Double)])
        case balance(dataPoints: [(Int, Balance)])
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ReportViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let type: `Type`
    private let data: Data
    private let factor: Factor
    private let title: String
    private let chartTitle: String
    private let network: Network
    private let startEra: Era
    private let endEra: Era
    
    private let dateFormatter = DateFormatter()
    private let axisSpace: CGFloat = 30
    private let gradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color("Green"),
                Color("Blue")
            ]
        ),
        startPoint: .bottom,
        endPoint: .top
    )
    
    init(
        type: `Type`,
        data: Data,
        factor: Factor,
        title: String,
        chartTitle: String,
        network: Network,
        startEra: Era,
        endEra: Era
    ) {
        self.type = type
        self.data = data
        self.factor = factor
        self.title = title
        self.chartTitle = chartTitle
        self.network = network
        self.startEra = startEra
        self.endEra = endEra
        self.dateFormatter.dateFormat = "dd MMM ''YY HH:mm"
    }
    
    private func getDateDisplay(index: UInt, timestamp: UInt64) -> String {
        let date = Date(
            timeIntervalSince1970: TimeInterval(timestamp / 1000)
        )
        return "Era \(index) - \(dateFormatter.string(from: date))"
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            ZStack {
                HStack {
                    Button(
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            BackButtonView()
                        }
                    )
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(0, self.displayState))
                    .frame(alignment: .leading)
                    Spacer()
                }
                Text(self.title)
                    .font(UI.Font.Common.title)
                    .foregroundColor(Color("Text"))
                    .frame(alignment: .center)
                    .modifier(PanelAppearance(1, self.displayState))
            }
            .frame(
                height: UI.Dimension.ValidatorList.titleSectionHeight,
                alignment: .center
            )
            .frame(maxWidth: .infinity)
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
    }
    
    private var dateIntervalView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(localized("report_range_selection.start_date"))
                    .font(UI.Font.NetworkReports.dateTitle)
                    .foregroundColor(Color("Text"))
                    .frame(width: 72, alignment: .leading)
                Text(self.getDateDisplay(
                    index: self.startEra.index,
                    timestamp: self.startEra.startTimestamp
                ))
                .font(UI.Font.NetworkReports.date)
            }
            .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 6)
            HStack {
                Text(localized("report_range_selection.end_date"))
                    .font(UI.Font.NetworkReports.dateTitle)
                    .foregroundColor(Color("Text"))
                    .frame(width: 72, alignment: .leading)
                Text(self.getDateDisplay(
                    index: self.endEra.index,
                    timestamp: self.endEra.endTimestamp
                ))
                .font(UI.Font.NetworkReports.date)
            }
            .modifier(PanelAppearance(3, self.displayState))
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: 0,
            trailing: 0
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("Bg")
                .ignoresSafeArea()
                .zIndex(0)
            BgMorphView()
                .offset(
                    x: 0,
                    y: UI.Dimension.BgMorph.yOffset(
                        displayState: self.displayState
                    )
                )
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .animation(
                    .easeOut(duration: 0.65),
                    value: self.displayState
                )
                .zIndex(0)
            self.headerView
                .zIndex(2)
            GeometryReader { geometry in
                VStack(
                    alignment: .leading,
                    spacing: UI.Dimension.Common.dataPanelSpacing
                ) {
                    Spacer()
                        .id(0)
                        .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                    self.dateIntervalView
                    Spacer()
                        .frame(height: 16)
                    self.chart
                        .padding(UI.Dimension.Common.dataPanelPadding)
                        .frame(height: geometry.size.width * 2 / 3)
                        .frame(maxWidth: .infinity)
                        .background(Color("DataPanelBg"))
                        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
                        .modifier(PanelAppearance(4, self.displayState))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.padding
                ))
            }
            FooterGradientView()
                .zIndex(2)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            if self.displayState != .appeared {
                // self.viewModel.network = self.network
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.displayState = .appeared
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        /*
                        self.viewModel.fetchReports(
                            startEraIndex: self.startEra.index,
                            endEraIndex: self.endEra.index
                        )
                         */
                    }
                }
            }
        }
    }
    
    private var chart: some View {
        ZStack {
            Chart {
                switch self.data {
                case .integer(let dataPoints):
                    ForEach(dataPoints.indices, id: \.self) { i in
                        let dataPoint = dataPoints[i]
                        switch self.type {
                        case .bar:
                            BarMark(
                                x: .value(localized("common.era"), dataPoint.0),
                                y: .value("Value", dataPoint.1)
                            )
                            .foregroundStyle(self.gradient)
                        case .line:
                            LineMark(
                                x: .value(localized("common.era"), dataPoint.0),
                                y: .value("Value", dataPoint.1)
                            )
                            .foregroundStyle(self.gradient)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                case .balance(let dataPoints):
                    ForEach(dataPoints.indices, id: \.self) { i in
                        let dataPoint = dataPoints[i]
                        switch self.type {
                        case .bar:
                            BarMark(
                                x: .value(localized("common.era"), dataPoint.0),
                                y: .value("Value", Double(dataPoint.1.value))
                            )
                            .foregroundStyle(self.gradient)
                        case .line:
                            LineMark(
                                x: .value(localized("common.era"), dataPoint.0),
                                y: .value("Value", Double(dataPoint.1.value))
                            )
                            .foregroundStyle(self.gradient)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                default:
                    LineMark(
                        x: .value("Era", 0),
                        y: .value("Value", 1)
                    )
                    .foregroundStyle(self.gradient)
                }
            }
            .chartXAxis {
                AxisMarks(
                    values: .automatic(
                        desiredCount: Int(self.endEra.index - self.startEra.index + 1)
                    )
                ) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        anchor: UnitPoint(x: -0.5, y: 0.5),
                        collisionResolution: .disabled
                    ) {
                        Text(String(value.as(Int.self)!))
                            .font(UI.Font.Report.axisValue)
                            .rotationEffect(Angle(degrees: -45))
                            .offset(x: -14, y : 3)
                            .foregroundColor(Color("Text"))
                    }
                  }
            }
            .chartXScale(domain: (self.startEra.index...self.endEra.index))
            .chartXAxisLabel(alignment: Alignment.trailing) {
                Text(localized("common.era"))
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
            .chartYAxis {
                AxisMarks(
                    position: .leading,
                    values: .automatic(desiredCount: 10)
                ) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        switch self.data {
                        case .integer(_):
                            if let intValue = value.as(Int.self) {
                                switch self.factor {
                                case .none:
                                    Text(String(intValue))
                                        .font(UI.Font.Report.axisValue)
                                        .foregroundColor(Color("Text"))
                                default:
                                    Text(formatDecimal(
                                        integer: UInt64(intValue),
                                        decimalCount: self.factor.decimals,
                                        formatDecimalCount: 2,
                                        integerOnly: false
                                    ))
                                    .font(UI.Font.Report.axisValue)
                                    .foregroundColor(Color("Text"))
                                }
                            }
                        case .balance(_):
                            if let balance = value.as(Balance.self) {
                                Text(formatBalance(
                                    balance: balance,
                                    tokenDecimalCount: self.network.tokenDecimalCount + self.factor.decimals,
                                    formatDecimalCount: 2,
                                    integerOnly: false
                                ))
                                .font(UI.Font.Report.axisValue)
                                .foregroundColor(Color("Text"))
                            }
                        default:
                            if let intValue = value.as(Int.self) {
                                Text(String(intValue))
                                    .font(UI.Font.Report.axisValue)
                                    .foregroundColor(Color("Text"))
                            }
                        }
                    }
                  }
            }
            .chartYAxisLabel(alignment: Alignment.leading) {
                Text(self.chartTitle)
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        let dataPoints = [
            (1000, 10),
            (1001, 2),
            (1002, 0),
            (1003, 7.5),
            (1004, 3.4),
            (1005, 7.8),
            (1006, 2.4),
            (1007, 6),
            (1008, 0),
            (1009, 17),
            (1010, 6),
            (1011, 2),
            (1012, 0),
            (1013, 7.5),
            (1014, 3.4),
            (1015, 7.8),
            (1016, 2.4),
            (1017, 6),
            (1018, 0),
            (1019, 17),
            (1020, 6)
        ]
        ReportView(
            type: .line,
            data: .double(dataPoints: dataPoints),
            factor: .none,
            title: "Kusama Report",
            chartTitle: "Report",
            network: PreviewData.kusama,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
