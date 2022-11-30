//
//  ReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.11.2022.
//

import SwiftUI
import SubVTData

struct ReportView: View {
    enum ChartType {
        case line
        case bar
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ReportViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let type: ChartType
    private let title: String
    private let network: Network
    private let startEra: Era
    private let endEra: Era
    private let dataPoints: [(Double, Double)]
    private let minY: Double
    private let maxY: Double
    
    private let dateFormatter = DateFormatter()
    private let axisSpace: CGFloat = 30
    
    init(
        type: ChartType,
        title: String,
        network: Network,
        startEra: Era,
        endEra: Era,
        dataPoints: [(Double, Double)],
        minY: Double,
        maxY: Double
    ) {
        self.type = type
        self.title = title
        self.network = network
        self.startEra = startEra
        self.endEra = endEra
        self.dataPoints = dataPoints
        self.dateFormatter.dateFormat = "dd MMM ''YY HH:mm"
        self.minY = minY
        self.maxY = maxY
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
                Text(localized("era_report_range_selection.start_date"))
                    .font(UI.Font.EraReports.dateTitle)
                    .foregroundColor(Color("Text"))
                    .frame(width: 72, alignment: .leading)
                Text(self.getDateDisplay(
                    index: self.startEra.index,
                    timestamp: self.startEra.startTimestamp
                ))
                .font(UI.Font.EraReports.date)
            }
            .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 6)
            HStack {
                Text(localized("era_report_range_selection.end_date"))
                    .font(UI.Font.EraReports.dateTitle)
                    .foregroundColor(Color("Text"))
                    .frame(width: 72, alignment: .leading)
                Text(self.getDateDisplay(
                    index: self.endEra.index,
                    timestamp: self.endEra.endTimestamp
                ))
                .font(UI.Font.EraReports.date)
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
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // y-axis
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Color.red
                                    .opacity(0)
                                Color("Text")
                                    .frame(width: 1)
                            }
                            Spacer()
                                .frame(height: self.axisSpace)
                        }
                        .frame(width: self.axisSpace)
                        VStack(spacing: 0) {
                            switch self.type {
                            case .line:
                                LineChartView(
                                    dataPoints: self.dataPoints,
                                    chartMinY: self.minY,
                                    chartMaxY: self.maxY,
                                    revealPercentage: 1.0
                                )
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: 1,
                                    bottom: 1,
                                    trailing: 1
                                ))
                            case .bar:
                                let padding = UI.Dimension.Common.dataPanelPadding / 2;
                                BarChartView(
                                    dataPoints: self.dataPoints,
                                    chartMinY: self.minY,
                                    chartMaxY: self.maxY,
                                    revealPercentage: 1.0
                                )
                                .padding(EdgeInsets(
                                    top: 0,
                                    leading: padding,
                                    bottom: padding,
                                    trailing: padding
                                ))
                            }
                            Color("Text")
                                .frame(height: 1)
                            Color.red
                                .frame(height: self.axisSpace)
                                .opacity(0)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(EdgeInsets(
                        top: UI.Dimension.Common.dataPanelPadding,
                        leading: 0,
                        bottom: 0,
                        trailing: UI.Dimension.Common.dataPanelPadding
                    ))
                    .frame(height: geometry.size.width / 2)
                    .frame(maxWidth: .infinity)
                    .background(Color("DataPanelBg"))
                    .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding
            ))
            .modifier(PanelAppearance(4, self.displayState))
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
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(
            type: .line,
            title: "Report",
            network: PreviewData.kusama,
            startEra: PreviewData.era,
            endEra: PreviewData.era,
            dataPoints: [
                (0, 10),
                (1, 2),
                (2, 0),
                (3, 7.5),
                (4, 3.4),
                (5, 7.8),
                (6, 2.4),
                (7, 6)
            ],
            minY: 0,
            maxY: 15
        )
    }
}
