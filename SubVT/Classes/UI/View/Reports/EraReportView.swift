//
//  EraReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.11.2022.
//

import Charts
import SwiftUI
import SubVTData

struct EraReportView: View {
    enum `Type`: Hashable {
        case line
        case bar
    }
    
    struct IntDataPoint: Hashable {
        let x: Int
        let y: Int
        
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    struct BalanceDataPoint: Hashable {
        let x: Int
        let y: Balance
        
        init(_ x: Int, _ y: Balance) {
            self.x = x
            self.y = y
        }
    }
    
    enum Data: Hashable {
        case integer(dataPoints: [IntDataPoint], max: Int? = nil)
        case balance(dataPoints: [BalanceDataPoint], decimals: UInt8 = 2)
    }
    
    @EnvironmentObject private var router: Router
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let type: `Type`
    private let data: Data
    private let factor: ReportDataFactor
    private let title: String
    private let chartTitle: String
    private let validatorIdentityDisplay: String?
    private let network: Network
    private let startEra: Era
    private let endEra: Era
    private let annotate: Bool
    
    private let dateFormatter = DateFormatter()
    private let axisSpace: CGFloat = 30
    private let max: Int
    
    init(
        type: `Type`,
        data: Data,
        factor: ReportDataFactor,
        title: String,
        chartTitle: String,
        validatorIdentityDisplay: String? = nil,
        network: Network,
        startEra: Era,
        endEra: Era,
        annotate: Bool = false
    ) {
        self.type = type
        self.data = data
        self.factor = factor
        self.title = title
        self.chartTitle = chartTitle
        self.validatorIdentityDisplay = validatorIdentityDisplay
        self.network = network
        self.startEra = startEra
        self.endEra = endEra
        self.annotate = annotate
        self.dateFormatter.dateFormat = "dd MMM ''YY HH:mm"
        switch data {
        case .integer(let dataPoints, let max):
            if let max = max {
                self.max = max
            } else {
                self.max = dataPoints.map { $0.y }.max { $0 < $1 } ?? 0
            }
        case .balance(let dataPoints, _):
            self.max = Int(
                ceil(
                    dataPoints
                        .map { Double($0.y.value) }
                        .max { $0 < $1 } ?? 0.0
                )
            )
        }
    }
    
    private func getDateDisplay(index: UInt32, timestamp: UInt64) -> String {
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
                            self.router.back()
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
            .modifier(PanelAppearance(3, self.displayState))
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
            .modifier(PanelAppearance(4, self.displayState))
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
                    Group {
                        if let validatorIdentityDisplay = self.validatorIdentityDisplay {
                            Text(validatorIdentityDisplay)
                                .font(UI.Font.Report.validatorDisplay)
                                .foregroundColor(Color("Text"))
                                .modifier(PanelAppearance(2, self.displayState))
                        }
                        self.dateIntervalView
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: 0
                    ))
                    Spacer()
                        .frame(height: 16)
                    self.chart
                        .padding(UI.Dimension.Common.dataPanelPadding)
                        .frame(height: geometry.size.width * 2 / 3)
                        .frame(maxWidth: .infinity)
                        .background(Color("DataPanelBg"))
                        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
                        .modifier(PanelAppearance(5, self.displayState))
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.displayState = .appeared
                }
            }
        }
    }
    
    private func integerValueLabel(value: Int) -> some View {
        switch self.factor {
        case .none:
            return Text(String(value))
                .font(UI.Font.Report.axisValue)
                .foregroundColor(Color("Text"))
        default:
            return Text(formatDecimal(
                integer: UInt64(value),
                decimalCount: self.factor.decimals,
                formatDecimalCount: 2
            ))
            .font(UI.Font.Report.axisValue)
            .foregroundColor(Color("Text"))
        }
    }
    
    private func balanceValueLabel(
        value: Balance,
        decimals: UInt8
    ) -> some View {
        Text(formatBalance(
            balance: value,
            tokenDecimalCount: self.network.tokenDecimalCount + self.factor.decimals,
            formatDecimalCount: decimals
        ))
        .font(UI.Font.Report.axisValue)
        .foregroundColor(Color("Text"))
    }
    
    private var chart: some View {
        ZStack {
            Chart {
                switch self.data {
                case .integer(let dataPoints, _):
                    ForEach(dataPoints.indices, id: \.self) { i in
                        let dataPoint = dataPoints[i]
                        switch self.type {
                        case .bar:
                            BarMark(
                                x: .value(localized("common.era"), dataPoint.x),
                                y: .value("Value", dataPoint.y)
                            )
                            .foregroundStyle(reportGradient)
                            .annotation(position: .top) {
                                if self.annotate {
                                    self.integerValueLabel(value: dataPoint.y)
                                        .rotationEffect(Angle(degrees: -45))
                                        .opacity(0.75)
                                } else {
                                    EmptyView()
                                        .frame(width: 0, height: 0)
                                }
                            }
                        case .line:
                            LineMark(
                                x: .value(localized("common.era"), dataPoint.x),
                                y: .value("Value", dataPoint.y)
                            )
                            .foregroundStyle(reportGradient)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                case .balance(let dataPoints, let decimals):
                    ForEach(dataPoints.indices, id: \.self) { i in
                        let dataPoint = dataPoints[i]
                        switch self.type {
                        case .bar:
                            BarMark(
                                x: .value(localized("common.era"), dataPoint.x),
                                y: .value("Value", Double(dataPoint.y.value))
                            )
                            .foregroundStyle(reportGradient)
                            .annotation(position: .top) {
                                if self.annotate {
                                    self.balanceValueLabel(value: dataPoint.y, decimals: decimals)
                                        .rotationEffect(Angle(degrees: -45))
                                        .opacity(0.75)
                                } else {
                                    EmptyView()
                                        .frame(width: 0, height: 0)
                                }
                            }
                        case .line:
                            LineMark(
                                x: .value(localized("common.era"), dataPoint.x),
                                y: .value("Value", Double(dataPoint.y.value))
                            )
                            .foregroundStyle(reportGradient)
                            .interpolationMethod(.catmullRom)
                        }
                    }
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
            .chartXScale(domain: (self.startEra.index...(self.endEra.index + 1)))
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
                        case .integer(_, _):
                            if let intValue = value.as(Int.self) {
                                self.integerValueLabel(value: intValue)
                            }
                        case .balance(_, let decimals):
                            if let balance = value.as(Balance.self) {
                                self.balanceValueLabel(
                                    value: balance,
                                    decimals: decimals
                                )
                            }
                        }
                    }
                  }
            }
            .chartYScale(domain: (0...self.max))
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
            EraReportView.IntDataPoint(1000, 10),
            EraReportView.IntDataPoint(1001, 2),
            EraReportView.IntDataPoint(1002, 0),
            EraReportView.IntDataPoint(1003, 7),
            EraReportView.IntDataPoint(1004, 3),
            EraReportView.IntDataPoint(1005, 7),
            EraReportView.IntDataPoint(1006, 2),
            EraReportView.IntDataPoint(1007, 6),
            EraReportView.IntDataPoint(1008, 0),
            EraReportView.IntDataPoint(1009, 17),
            EraReportView.IntDataPoint(1010, 6),
            EraReportView.IntDataPoint(1011, 2),
            EraReportView.IntDataPoint(1012, 0),
            EraReportView.IntDataPoint(1013, 7),
            EraReportView.IntDataPoint(1014, 3),
            EraReportView.IntDataPoint(1015, 7),
            EraReportView.IntDataPoint(1016, 2),
            EraReportView.IntDataPoint(1017, 6),
            EraReportView.IntDataPoint(1018, 0),
            EraReportView.IntDataPoint(1019, 17),
            EraReportView.IntDataPoint(1020, 6)
        ]
        EraReportView(
            type: .line,
            data: .integer(dataPoints: dataPoints),
            factor: .none,
            title: "Kusama Report",
            chartTitle: "Report",
            network: PreviewData.kusama,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
