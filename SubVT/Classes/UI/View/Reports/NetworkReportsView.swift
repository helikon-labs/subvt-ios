//
//  NetworkReportsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.11.2022.
//

import SwiftUI
import SubVTData

struct NetworkReportsView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = NetworkReportsViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartDisplayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    // disable inner chart animation
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let network: Network
    private let startEra: Era
    private let endEra: Era
    
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
    
    private func getDateDisplay(
        index: UInt32,
        timestamp: UInt64
    ) -> String {
        let date = Date(
            timeIntervalSince1970: TimeInterval(timestamp / 1000)
        )
        return String(
            format: "%@ %d - %@",
            localized("common.era"),
            index,
            dateFormatter.string(from: date)
        )
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
                Text(String(
                    format: "%@ %@",
                    self.network.display,
                    localized("reports.network.title")
                ))
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
            .disabled(true)
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
                if self.startEra.index == self.endEra.index {
                    self.singleReportView
                        .zIndex(1)
                } else {
                    self.chartsView
                        .zIndex(1)
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
            FooterGradientView()
                .zIndex(2)
            ZStack {
                SnackbarView(
                    message: localized("reports.error.fetch"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchReports(
                        startEraIndex: self.startEra.index,
                        endEraIndex: self.endEra.index
                    )
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
            .modifier(PanelAppearance(0, self.chartDisplayState))
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
            .modifier(PanelAppearance(1, self.chartDisplayState))
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: 0,
            trailing: 0
        ))
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
                self.dateIntervalView
                Spacer()
                    .frame(height: 16)
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink {
                        EraReportView(
                            type: .line,
                            data: .integer(dataPoints: self.viewModel.activeNominatorCounts),
                            factor: .none,
                            title: String(
                                format: localized("reports.network.active_nominators_title"),
                                self.network.display
                            ),
                            chartTitle: localized("reports.active_nominators"),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.activeNominatorCountsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(2, self.chartDisplayState))
                    NavigationLink {
                        let factor = ReportDataFactor.million
                        EraReportView(
                            type: .bar,
                            data: .balance(
                                dataPoints: self.viewModel.totalStakesBalance
                            ),
                            factor: factor,
                            title: String(
                                format: localized("reports.network.total_stake_title"),
                                self.network.display
                            ),
                            chartTitle: String(
                                format: localized("reports.total_stake_with_factor_ticker"),
                                factor.description!.capitalized,
                                self.network.tokenTicker
                            ),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.totalStakesView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(3, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink {
                        let factor = ReportDataFactor.million
                        EraReportView(
                            type: .bar,
                            data: .integer(
                                dataPoints: self.viewModel.rewardPoints.map{ ($0.0, Int($0.1)) }
                            ),
                            factor: factor,
                            title: String(
                                format: localized("reports.network.reward_points_title"),
                                self.network.display
                            ),
                            chartTitle: String(
                                format: localized("reports.reward_points_with_factor"),
                                factor.descriptionPlural!.capitalized,
                                self.network.tokenTicker
                            ),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.rewardPointsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(4, self.chartDisplayState))
                    NavigationLink {
                        let factor: ReportDataFactor = self.network.tokenTicker == "DOT" ? .thousand : .none
                        let chartTitle = self.network.tokenTicker == "DOT"
                            ? String(
                                format: localized("reports.total_paid_out_with_factor_ticker"),
                                factor.description!.capitalized,
                                self.network.tokenTicker
                            )
                            : String(
                                format: localized("reports.total_paid_out_with_ticker"),
                                self.network.tokenTicker
                            )
                        EraReportView(
                            type: .bar,
                            data: .balance(
                                dataPoints: self.viewModel.totalPaidOutBalance,
                                decimals: 0
                            ),
                            factor: factor,
                            title: String(
                                format: localized("reports.network.total_paid_out_title"),
                                self.network.display
                            ),
                            chartTitle: chartTitle,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.totalPaidOutView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(5, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink {
                        EraReportView(
                            type: .line,
                            data: .integer(
                                dataPoints: self.viewModel.activeValidatorCounts
                            ),
                            factor: .none,
                            title: String(
                                format: localized("reports.network.active_validators_title"),
                                self.network.display
                            ),
                            chartTitle: localized("reports.active_validators"),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.activeValidatorCountsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(6, self.chartDisplayState))
                    NavigationLink {
                        let factor: ReportDataFactor = self.network.tokenTicker == "DOT" ? .thousand : .none
                        let chartTitle = self.network.tokenTicker == "DOT"
                            ? String(
                                format: localized("reports.total_reward_with_factor_ticker"),
                                factor.description!.capitalized,
                                self.network.tokenTicker
                            )
                            : String(
                                format: localized("reports.total_reward_with_ticker"),
                                self.network.tokenTicker
                            )
                        EraReportView(
                            type: .bar,
                            data: .balance(
                                dataPoints: self.viewModel.totalRewardsBalance,
                                decimals: 0
                            ),
                            factor: factor,
                            title: String(
                                format: localized("reports.network.total_rewards_title"),
                                self.network.display
                            ),
                            chartTitle: chartTitle,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.totalRewardsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(7, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink {
                        EraReportView(
                            type: .bar,
                            data: .integer(
                                dataPoints: self.viewModel.offlineOffenceCounts.map { ($0.0, Int($0.1)) }
                            ),
                            factor: .none,
                            title: String(
                                format: localized("reports.network.offline_offences_title"),
                                self.network.display
                            ),
                            chartTitle: localized("reports.offences"),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.offlineOffenceCountsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(8, self.chartDisplayState))
                    NavigationLink {
                        EraReportView(
                            type: .bar,
                            data: .balance(dataPoints: self.viewModel.slashesBalance),
                            factor: .none,
                            title: String(
                                format: localized("reports.network.slashes_title"),
                                self.network.display
                            ),
                            chartTitle: String(
                                format: localized("reports.slashed_with_ticker"),
                                self.network.tokenTicker
                            ),
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra
                        )
                    } label: {
                        self.slashesView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(9, self.chartDisplayState))
                }
                Spacer()
                    .frame(height: UI.Dimension.Common.footerGradientViewHeight)
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
    
    private var activeNominatorCountsView: some View {
        ReportLineChartView(
            title: localized("reports.active_nominators"),
            dataPoints: self.viewModel.activeNominatorCounts,
            minY: 0,
            maxY: self.viewModel.maxActiveNominatorCount * 2,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var activeValidatorCountsView: some View {
        ReportLineChartView(
            title: localized("reports.active_validators"),
            dataPoints: self.viewModel.activeValidatorCounts,
            minY: 0,
            maxY: self.viewModel.maxActiveValidatorCount * 2,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var rewardPointsView: some View {
        ReportBarChartView(
            title: localized("reports.reward_points"),
            dataPoints: self.viewModel.rewardPoints,
            minY: 0.0,
            maxY: self.viewModel.maxRewardPoint,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalPaidOutView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.total_paid_out_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalPaidOut,
            minY: 0.0,
            maxY: self.viewModel.maxTotalPaidOut,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalStakesView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.total_stake_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalStakes,
            minY: 0.0,
            maxY: self.viewModel.maxTotalStake,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalRewardsView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.total_reward_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalRewards,
            minY: 0.0,
            maxY: self.viewModel.maxTotalReward,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var offlineOffenceCountsView: some View {
        ReportBarChartView(
            title: localized("reports.offline_offences"),
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
                format: localized("reports.slashed_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.slashes,
            minY: 0.0,
            maxY: self.viewModel.maxSlash,
            revealPercentage: self.chartRevealPercentage,
            colorScheme: self.colorScheme
        )
    }
    
    private var singleReportView: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: UI.Dimension.Common.dataPanelSpacing
            ) {
                Spacer()
                    .id(0)
                    .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                self.dateIntervalView
                Spacer()
                    .frame(height: UI.Dimension.Common.dataPanelSpacing)
                Group {
                    ReportDataPanelView(
                        title: localized("reports.network.title"),
                        content: String(self.viewModel.activeNominatorCounts[0].1)
                    )
                    .modifier(PanelAppearance(2, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.total_stake"),
                        content: String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.totalStakesBalance[0].1,
                                tokenDecimalCount: self.network.tokenDecimalCount,
                                formatDecimalCount: 0
                            ),
                            self.network.tokenTicker
                        )
                    )
                    .modifier(PanelAppearance(3, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.reward_points"),
                        content: formatDecimal(
                            integer: UInt64(self.viewModel.rewardPoints[0].1),
                            decimalCount: 0,
                            formatDecimalCount: 0
                        )
                    )
                    .modifier(PanelAppearance(4, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.total_paid_out"),
                        content: String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.totalPaidOutBalance[0].1,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                    )
                    .modifier(PanelAppearance(5, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.active_validators"),
                        content: String(self.viewModel.activeValidatorCounts[0].1)
                    )
                    .modifier(PanelAppearance(6, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.total_reward"),
                        content: String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.totalRewardsBalance[0].1,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                    )
                    .modifier(PanelAppearance(7, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.offline_offences"),
                        content: String(Int(self.viewModel.offlineOffenceCounts[0].1))
                    )
                    .modifier(PanelAppearance(8, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.slashed"),
                        content: String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.slashesBalance[0].1,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                    )
                    .modifier(PanelAppearance(9, self.chartDisplayState))
                }
                Spacer()
                    .frame(height: UI.Dimension.Common.bottomNotchHeight + UI.Dimension.Common.padding * 2)
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
}

struct NetworkReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkReportsView(
            network: PreviewData.kusama,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
