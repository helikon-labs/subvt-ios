//
//  ParaVoteReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.01.2023.
//

import Charts
import SubVTData
import SwiftUI

struct ParaVoteReportView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ParaVoteReportViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    private let network: Network
    private let accountId: AccountId
    private let identityDisplay: String
    
    init(
        network: Network,
        accountId: AccountId,
        identityDisplay: String
    ) {
        self.network = network
        self.accountId = accountId
        self.identityDisplay = identityDisplay
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
                Text(localized("reports.paravalidation_votes.title"))
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
                                .padding(UI.Dimension.Common.dataPanelPadding)
                                .frame(height: geometry.size.width * 2 / 3)
                                .frame(maxWidth: .infinity)
                                .background(Color("DataPanelBg"))
                                .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
                                .modifier(PanelAppearance(2, self.displayState))
                        } else {
                            Text(String(
                                format: localized("reports.paravalidation_votes.no_report_found"),
                                ParaVoteReportViewModel.fetchReportCount
                            ))
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
                    self.viewModel.fetchReports()
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
                        self.viewModel.fetchReports()
                    }
                }
            }
        }
    }
    
    private var chart: some View {
        VStack {
            Chart {
                ForEach(self.viewModel.data.indices, id: \.self) { i in
                    let report = self.viewModel.data[i]
                    BarMark(
                        x: .value("Session", report.0),
                        y: .value("Vote Count", report.1.implicit),
                        width: .automatic
                    )
                    .foregroundStyle(Color.gray)
                    .annotation(position: .overlay) {
                        Text(String(report.1.implicit))
                            .foregroundColor(Color("Text"))
                            .font(UI.Font.Report.axisValue)
                            .lineLimit(1)
                            //.minimumScaleFactor(0.5)
                            //.rotationEffect(Angle(degrees: -45))
                            .opacity((report.1.implicit > 0) ? 1.0 : 0.0)
                    }
                    BarMark(
                        x: .value("Session", report.0),
                        y: .value("Vote Count", report.1.explicit),
                        width: .automatic
                    )
                    .foregroundStyle(Color.blue)
                    .annotation(position: .overlay) {
                        Text(String(report.1.explicit))
                            .foregroundColor(Color("Text"))
                            .font(UI.Font.Report.axisValue)
                            .lineLimit(1)
                            //.minimumScaleFactor(0.5)
                            //.rotationEffect(Angle(degrees: -45))
                            .opacity((report.1.explicit > 0) ? 1.0 : 0.0)
                            .padding(0)
                    }
                    BarMark(
                        x: .value("Session", report.0),
                        y: .value("Vote Count", report.1.missed),
                        width: .automatic
                    )
                    .foregroundStyle(Color.red)
                    .annotation(position: .overlay) {
                        Text(String(report.1.missed))
                            .foregroundColor(Color("Text"))
                            .font(UI.Font.Report.axisValue)
                            .lineLimit(1)
                            //.minimumScaleFactor(0.5)
                            //.rotationEffect(Angle(degrees: -45))
                            .opacity((report.1.missed > 0) ? 1.0 : 0.0)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(
                    values: .automatic(
                        desiredCount: self.viewModel.data.count
                    )
                ) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        anchor: UnitPoint(x: -0.5, y: 0.5),
                        collisionResolution: .disabled
                    ) {
                        Text(value.as(String.self)!)
                            .font(UI.Font.Report.axisValue)
                            .rotationEffect(Angle(degrees: -45))
                            .offset(x: 0, y : 4)
                            .foregroundColor(Color("Text"))
                    }
                  }
            }
            .chartXAxisLabel(alignment: Alignment.trailing) {
                Text(localized("common.session"))
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
            .chartYAxis {
                AxisMarks(
                    position: .leading,
                    values: .automatic(desiredCount: 7)
                ) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        Text(String(value.as(Int.self)!))
                            .font(UI.Font.Report.axisValue)
                            .foregroundColor(Color("Text"))
                    }
                }
            }
            .chartYScale(domain: (0...self.viewModel.maxTotal))
            .chartYAxisLabel(alignment: Alignment.leading) {
                Text(localized("reports.paravalidation_votes.votes"))
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
            HStack(alignment: .center, spacing: 12) {
                LegendItem(color: Color.gray, text: localized("reports.paravalidation_votes.implicit"))
                LegendItem(color: Color.blue, text: localized("reports.paravalidation_votes.explicit"))
                LegendItem(color: Color.red, text: localized("reports.paravalidation_votes.missed"))
                Spacer()
            }
            .frame(alignment: .leading)
        }
    }
    
    struct LegendItem: View {
        let color: Color
        let text: String
        
        var body: some View {
            HStack(alignment: .center) {
                Circle()
                    .foregroundColor(color)
                    .frame(width: 8)
                Text(text)
                    .font(UI.Font.Report.axisLabel)
                    .foregroundColor(Color("Text"))
            }
            .frame(alignment: .leading)
        }
    }
}

struct ParaVoteReportView_Previews: PreviewProvider {
    static var previews: some View {
        ParaVoteReportView(
            network: PreviewData.kusama,
            accountId: PreviewData.validatorSummary.accountId,
            identityDisplay: PreviewData.validatorSummary.identityDisplay
        )
    }
}
