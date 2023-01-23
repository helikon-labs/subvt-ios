//
//  RewardReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.01.2023.
//

import Charts
import SubVTData
import SwiftUI

struct RewardReportView: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = RewardReportViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    private let network: Network
    private let accountId: AccountId
    private let identityDisplay: String
    private let factor: ReportDataFactor
    private let title: String
    private let chartTitle: String
    private let annotate: Bool
    
    init(
        network: Network,
        accountId: AccountId,
        identityDisplay: String,
        factor: ReportDataFactor,
        title: String,
        chartTitle: String,
        annotate: Bool = true
    ) {
        self.accountId = accountId
        self.identityDisplay = identityDisplay
        self.factor = factor
        self.title = title
        self.chartTitle = chartTitle
        self.network = network
        self.annotate = annotate
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
                        Text(self.identityDisplay)
                            .font(UI.Font.Report.validatorDisplay)
                            .foregroundColor(Color("Text"))
                            .modifier(PanelAppearance(2, self.displayState))
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: 0
                    ))
                    Spacer()
                        .frame(height: 16)
                    switch self.viewModel.fetchState {
                    case .success:
                        if self.viewModel.data.count > 0 {
                            self.chart
                                .padding(UI.Dimension.Common.dataPanelPadding / 2)
                                .frame(height: geometry.size.width * 2 / 3)
                                .frame(maxWidth: .infinity)
                                .background(Color("DataPanelBg"))
                                .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius / 2)
                                .modifier(PanelAppearance(5, self.displayState))
                        } else {
                            Text(localized("reports.monthly_reward.no_reward_found"))
                                .font(UI.Font.Common.listNoItems)
                                .foregroundColor(Color("Text"))
                        }
                    case .idle, .loading:
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: Color("Text")
                                )
                            )
                            .animation(.spring(), value: self.viewModel.fetchState)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .zIndex(10)
                            .modifier(PanelAppearance(2, self.displayState))
                    default:
                        Group {}
                    }
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
            ZStack {
                SnackbarView(
                    message: localized("reports.error.fetch"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchRewards()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(
                    y: UI.Dimension.Common.snackbarYOffset(
                        fetchState: self.viewModel.fetchState
                    )
                )
                .opacity(UI.Dimension.Common.snackbarOpacity(
                    fetchState: self.viewModel.fetchState
                ))
                .animation(
                    .spring(),
                    value: self.viewModel.fetchState
                )
            }
            .zIndex(3)
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
                self.viewModel.initialize(
                    network: self.network,
                    accountId: self.accountId
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.displayState = .appeared
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.viewModel.fetchRewards()
                    }
                }
            }
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
    
    private func monthDisplay(index: Int) -> String {
        let year = index / 12;
        let monthIndex = index - (year * 12)
        var text = " '" + String(year).suffix(2)
        switch monthIndex {
        case 0:
            text = localized("common.date.month.january.short") + text
        case 1:
            text = localized("common.date.month.february.short") + text
        case 2:
            text = localized("common.date.month.march.short") + text
        case 3:
            text = localized("common.date.month.april.short") + text
        case 4:
            text = localized("common.date.month.may.short") + text
        case 5:
            text = localized("common.date.month.june.short") + text
        case 6:
            text = localized("common.date.month.july.short") + text
        case 7:
            text = localized("common.date.month.august.short") + text
        case 8:
            text = localized("common.date.month.september.short") + text
        case 9:
            text = localized("common.date.month.october.short") + text
        case 10:
            text = localized("common.date.month.november.short") + text
        case 11:
            text = localized("common.date.month.december.short") + text
        default:
            fatalError("Unexpected month index \(monthIndex).")
        }
        return text
    }
    
    private var chart: some View {
        ZStack {
            Chart {
                ForEach(self.viewModel.data.indices, id: \.self) { i in
                    let dataPoint = self.viewModel.data[i]
                    BarMark(
                        x: .value("Month", dataPoint.0),
                        y: .value("Reward", Double(dataPoint.1.value)),
                        width: .automatic // .fixed(16.0)
                    )
                    .foregroundStyle(reportGradient)
                    .annotation(position: .top) {
                        if self.annotate {
                            self.balanceValueLabel(value: dataPoint.1, decimals: 2)
                                .rotationEffect(Angle(degrees: -45))
                        } else {
                            EmptyView()
                                .frame(width: 0, height: 0)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(
                    values: .automatic(
                        desiredCount: self.viewModel.xAxisMarkCount
                    )
                ) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        anchor: UnitPoint(x: -0.5, y: 0.5),
                        collisionResolution: .disabled
                    ) {
                        Text(self.monthDisplay(index: value.as(Int.self)!))
                            .font(UI.Font.Report.axisValue)
                            .rotationEffect(Angle(degrees: -45))
                            .offset(x: -18, y : 5)
                            .foregroundColor(Color("Text"))
                    }
                  }
            }
            .chartXScale(domain: self.viewModel.xAxisScale)
            .chartXAxisLabel(alignment: Alignment.trailing) {
                Text(" ")
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
                        self.balanceValueLabel(
                            value: value.as(Balance.self)!,
                            decimals: 1
                        )
                    }
                }
            }
            .chartYScale(domain: (0.0...self.viewModel.max))
            .chartYAxisLabel(alignment: Alignment.leading) {
                Text(self.chartTitle)
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
        }
    }
}

struct RewardReportView_Previews: PreviewProvider {
    static var previews: some View {
        RewardReportView(
            network: PreviewData.kusama,
            accountId: PreviewData.validatorSummary.accountId,
            identityDisplay: PreviewData.validatorSummary.identityDisplay,
            factor: .none,
            title: "Kusama Report",
            chartTitle: "Report"
        )
    }
}
