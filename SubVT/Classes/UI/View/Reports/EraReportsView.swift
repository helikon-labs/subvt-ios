//
//  EraReportsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.11.2022.
//

import SwiftUI
import SubVTData

struct EraReportsView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = EraReportsViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartDisplayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    // disable inner chart animation
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let startEra: Era
    private let endEra: Era
    private let network: Network
    
    private let dateFormatter = DateFormatter()
    
    init(
        network: Network,
        startEra: Era,
        endEra: Era
    ) {
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
                Text(localized("era_reports.title"))
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
        .background(
            VisualEffectView(effect: UIBlurEffect(
                style: .systemUltraThinMaterial
            ))
            .cornerRadius(
                UI.Dimension.Common.headerBlurViewCornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
            .opacity(self.headerMaterialOpacity)
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
            switch self.viewModel.fetchState {
            case .success:
                self.chartsView
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
            ZStack {
                SnackbarView(
                    message: localized("era_report_range_selection.error.era_list"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchReports(
                        startEraIndex: self.startEra.index,
                        endEraIndex: self.endEra.index
                    )
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(
                    y: UI.Dimension.ReportRangeSelection.snackbarYOffset(
                        fetchState: self.viewModel.fetchState
                    )
                )
                .opacity(UI.Dimension.ReportRangeSelection.snackbarOpacity(
                    fetchState: self.viewModel.fetchState
                ))
                .animation(
                    .spring(),
                    value: self.viewModel.fetchState
                )
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            if self.displayState != .appeared {
                self.viewModel.network = self.network
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.displayState = .appeared
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.viewModel.fetchReports(
                            startEraIndex: self.startEra.index,
                            endEraIndex: self.endEra.index
                        )
                    }
                }
            }
        }
        .onChange(of: self.viewModel.fetchState) { newValue in
            switch newValue {
            case .success:
                self.chartRevealPercentage = 1.0
                self.chartDisplayState = .appeared
            default:
                break
            }
        }
    }
    
    private var chartsView: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: UI.Dimension.Common.dataPanelSpacing
            ) {
                Spacer()
                    .id(0)
                    .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                VStack {
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
                    .modifier(PanelAppearance(0, self.chartDisplayState))
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
                    .modifier(PanelAppearance(1, self.chartDisplayState))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: 0
                ))
                Spacer()
                    .frame(height: 16)
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    self.activeNominatorCountsView
                        .modifier(PanelAppearance(2, self.chartDisplayState))
                    self.totalStakesView
                        .modifier(PanelAppearance(3, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    self.rewardPointsView
                        .modifier(PanelAppearance(4, self.chartDisplayState))
                    self.totalRewardsView
                        .modifier(PanelAppearance(5, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    self.activeValidatorCountsView
                        .modifier(PanelAppearance(6, self.chartDisplayState))
                    self.validatorRewardsView
                        .modifier(PanelAppearance(7, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    self.offlineOffenceCountsView
                        .modifier(PanelAppearance(8, self.chartDisplayState))
                    self.slashesView
                        .modifier(PanelAppearance(9, self.chartDisplayState))
                }
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding
            ))
            .background(GeometryReader {
                Color.clear
                    .preference(
                        key: ViewOffsetKey.self,
                        value: -$0.frame(in: .named("scroll")).origin.y
                    )
            })
            .onPreferenceChange(ViewOffsetKey.self) {
                self.headerMaterialOpacity = min(max($0, 0) / 40.0, 1.0)
            }
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
    
    private var activeNominatorCountsView: some View {
        ReportLineChartView(
            title: localized("era_reports.active_nominators"),
            dataPoints: self.viewModel.activeNominatorCounts,
            minY: 0,
            maxY: self.viewModel.maxActiveNominatorCount * 2,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var activeValidatorCountsView: some View {
        ReportLineChartView(
            title: localized("era_reports.active_validators"),
            dataPoints: self.viewModel.activeValidatorCounts,
            minY: 0,
            maxY: self.viewModel.maxActiveValidatorCount * 2,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var rewardPointsView: some View {
        ReportBarChartView(
            title: localized("era_reports.reward_points"),
            dataPoints: self.viewModel.rewardPoints,
            minY: 0.0,
            maxY: self.viewModel.maxRewardPoint,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalRewardsView: some View {
        ReportBarChartView(
            title: String(
                format: localized("era_reports.total_rewards"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalRewards,
            minY: 0.0,
            maxY: self.viewModel.maxTotalReward,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalStakesView: some View {
        ReportBarChartView(
            title: String(
                format: localized("era_reports.total_stakes"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalStakes,
            minY: 0.0,
            maxY: self.viewModel.maxTotalStake,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var validatorRewardsView: some View {
        ReportBarChartView(
            title: String(
                format: localized("era_reports.validator_rewards"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.validatorRewards,
            minY: 0.0,
            maxY: self.viewModel.maxValidatorReward,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var offlineOffenceCountsView: some View {
        ReportBarChartView(
            title: localized("era_reports.offline_offences"),
            dataPoints: self.viewModel.offlineOffenceCounts,
            minY: 0.0,
            maxY: self.viewModel.maxOfflineOffenceCount,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var slashesView: some View {
        ReportBarChartView(
            title: String(
                format: localized("era_reports.slashed"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.slashes,
            minY: 0.0,
            maxY: self.viewModel.maxSlash,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
}

struct EraReportsView_Previews: PreviewProvider {
    static var previews: some View {
        EraReportsView(
            network: PreviewData.kusama,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
