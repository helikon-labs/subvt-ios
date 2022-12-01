//
//  ReportView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.11.2022.
//

import Charts
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
        type: ChartType,
        title: String,
        network: Network,
        startEra: Era,
        endEra: Era,
        dataPoints: [(Double, Double)]
    ) {
        self.type = type
        self.title = title
        self.network = network
        self.startEra = startEra
        self.endEra = endEra
        self.dataPoints = dataPoints
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
                Text(localized("network_report_range_selection.start_date"))
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
                Text(localized("network_report_range_selection.end_date"))
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
                    ZStack {
                        let firstEraIndex = self.dataPoints.first?.0 ?? 0
                        let lastEraIndex = self.dataPoints.last?.0 ?? 0
                        Chart {
                            ForEach(self.dataPoints.indices, id: \.self) { i in
                                let dataPoint = self.dataPoints[i]
                                BarMark(
                                    x: .value("Era", Int(dataPoint.0)),
                                    y: .value("Value", Int(dataPoint.1))
                                )
                                .foregroundStyle(self.gradient)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(
                                values: .automatic(desiredCount: self.dataPoints.count)
                            ) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(
                                    anchor: UnitPoint(x: -0.5, y: 0.5),
                                    collisionResolution: .disabled
                                ) {
                                    if let intValue = value.as(Int.self) {
                                        Text(String(intValue))
                                            .font(UI.Font.Report.axisValue)
                                            .rotationEffect(Angle(degrees: -45))
                                            .offset(x: -14, y : 3)
                                            .foregroundColor(Color("Text"))
                                    }
                                }
                              }
                        }
                        .chartXScale(domain: (firstEraIndex...lastEraIndex))
                        .chartXAxisLabel(alignment: Alignment.trailing) {
                            Text("Era")
                                .font(UI.Font.Report.axisLabel)
                                .foregroundColor(Color("Text"))
                        }
                        .chartYAxis {
                            AxisMarks(
                                position: .leading,
                                values: .automatic(desiredCount: 10)
                            ) { value in
                                AxisGridLine()
                                AxisTick(
                                    length: 5
                                )
                                AxisValueLabel {
                                    if let intValue = value.as(Int.self) {
                                        Text(String(intValue))
                                            .font(UI.Font.Report.axisValue)
                                            .foregroundColor(Color("Text"))
                                    }
                                }
                              }
                        }
                        .chartYAxisLabel(alignment: Alignment.leading) {
                            Text("Offences")
                                .font(UI.Font.Report.axisLabel)
                                .foregroundColor(Color("Text"))
                        }
                        
                    }
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
        )
    }
}
