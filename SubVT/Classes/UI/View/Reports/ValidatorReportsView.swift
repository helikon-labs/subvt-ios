//
//  ValidatorReportsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.12.2022.
//

import SubVTData
import SwiftUI

struct ValidatorReportsView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = ValidatorReportsViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartDisplayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    // disable inner chart animation
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let network: Network
    private let accountId: AccountId
    private let identityDisplay: String
    private let startEra: Era
    private let endEra: Era
    
    private let dateFormatter = DateFormatter()
    
    init(
        network: Network,
        accountId: AccountId,
        identityDisplay: String,
        startEra: Era,
        endEra: Era
    ) {
        self.network = network
        self.accountId = accountId
        self.identityDisplay = identityDisplay
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
                Text(localized("reports.validator.title"))
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
                self.viewModel.initialize(
                    network: self.network,
                    accountId: self.accountId
                )
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
            .modifier(PanelAppearance(1, self.chartDisplayState))
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
            .modifier(PanelAppearance(2, self.chartDisplayState))
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
                Group {
                    Text(self.identityDisplay)
                        .font(UI.Font.Report.validatorDisplay)
                        .foregroundColor(Color("Text"))
                        .modifier(PanelAppearance(0, self.chartDisplayState))
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
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(dataPoints: self.viewModel.isActive),
                            factor: .none,
                            title: localized("reports.validator.active"),
                            chartTitle: localized("reports.validator.active"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.isActiveView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(3, self.chartDisplayState))
                    
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(
                                dataPoints: self.viewModel.commissionPerTenThousand,
                                max: 10000
                            ),
                            factor: .hundred,
                            title: localized("reports.validator.commission"),
                            chartTitle: localized("reports.validator.commission_with_percent"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: true
                        )
                    ) {
                        self.commissionView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(4, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .balance(dataPoints: self.viewModel.selfStake),
                            factor: .none,
                            title: localized("reports.validator.self_stake"),
                            chartTitle:  String(
                                format: localized("reports.validator.self_stake_with_ticker"),
                                self.network.tokenTicker
                            ),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.selfStakeView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(5, self.chartDisplayState))
                    
                    let totalStakeFactor: ReportDataFactor = self.network.tokenTicker == "DOT"
                        ? .million
                        : .thousand
                    let totalStakeChartTitle = String(
                        format: localized("reports.validator.total_stake_with_factor_ticker"),
                        totalStakeFactor.description!.capitalized,
                        self.network.tokenTicker
                    )
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .balance(
                                dataPoints: self.viewModel.totalStake,
                                decimals: 2
                            ),
                            factor: totalStakeFactor,
                            title: localized("reports.validator.total_stake"),
                            chartTitle: totalStakeChartTitle,
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.totalStakeView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(6, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(dataPoints: self.viewModel.blockCount),
                            factor: .none,
                            title: localized("reports.validator.block_count"),
                            chartTitle: localized("reports.validator.block_count"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.blockCountView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(7, self.chartDisplayState))
                    
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(dataPoints: self.viewModel.rewardPoints),
                            factor: .none,
                            title: localized("reports.validator.reward_points"),
                            chartTitle: localized("reports.validator.reward_points"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.rewardPointsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(8, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .balance(dataPoints: self.viewModel.selfReward),
                            factor: .none,
                            title: localized("reports.validator.self_reward"),
                            chartTitle: String(
                                format: localized("reports.validator.self_reward_with_ticker"),
                                self.network.tokenTicker
                            ),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.selfRewardView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(9, self.chartDisplayState))
                    
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .balance(dataPoints: self.viewModel.stakerReward),
                            factor: .none,
                            title: localized("reports.validator.staker_reward"),
                            chartTitle: String(
                                format: localized("reports.validator.staker_reward_with_ticker"),
                                self.network.tokenTicker
                            ),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.stakerRewardView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(10, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(dataPoints: self.viewModel.offlineOffences),
                            factor: .none,
                            title: localized("reports.offline_offences"),
                            chartTitle: localized("reports.offences"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.offlineOffencesView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(11, self.chartDisplayState))
                    
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .integer(dataPoints: self.viewModel.chillings),
                            factor: .none,
                            title: localized("reports.validator.chilling_count"),
                            chartTitle: localized("reports.validator.chillings"),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.chillingsView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(12, self.chartDisplayState))
                }
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    NavigationLink(
                        value: Screen.eraReport(
                            type: .bar,
                            data: .balance(dataPoints: self.viewModel.slashes),
                            factor: .none,
                            title: localized("reports.slashes"),
                            chartTitle: String(
                                format: localized("reports.slashed_with_ticker"),
                                self.network.tokenTicker
                            ),
                            validatorIdentityDisplay: self.identityDisplay,
                            network: self.network,
                            startEra: self.startEra,
                            endEra: self.endEra,
                            annotate: false
                        )
                    ) {
                        self.slashesView
                    }
                    .buttonStyle(PushButtonStyle())
                    .modifier(PanelAppearance(13, self.chartDisplayState))
                    
                    Spacer()
                        .frame(maxWidth: .infinity)
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
    
    private var isActiveView: some View {
        ReportBarChartView(
            title: localized("reports.validator.active"),
            dataPoints: self.viewModel.isActive.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: 1,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var commissionView: some View {
        ReportBarChartView(
            title: localized("reports.validator.commission_with_percent"),
            dataPoints: self.viewModel.commissionPerTenThousand.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: 10000,
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var selfStakeView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.validator.self_stake_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.selfStake.map {
                ($0.x, Double($0.y.value))
            },
            minY: 0,
            maxY: max(self.viewModel.maxSelfStake, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var totalStakeView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.validator.total_stake_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.totalStake.map {
                ($0.x, Double($0.y.value))
            },
            minY: 0,
            maxY: max(self.viewModel.maxTotalStake, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var blockCountView: some View {
        ReportBarChartView(
            title: localized("reports.validator.block_count"),
            dataPoints: self.viewModel.blockCount.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: Double(self.viewModel.maxBlockCount),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var rewardPointsView: some View {
        ReportBarChartView(
            title: localized("reports.validator.reward_points"),
            dataPoints: self.viewModel.rewardPoints.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: Double(self.viewModel.maxRewardPoints),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var selfRewardView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.validator.self_reward_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.selfReward.map {
                ($0.x, Double($0.y.value))
            },
            minY: 0,
            maxY: max(self.viewModel.maxSelfReward, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var stakerRewardView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.validator.staker_reward_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.stakerReward.map {
                ($0.x, Double($0.y.value))
            },
            minY: 0,
            maxY: max(self.viewModel.maxStakerReward, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var offlineOffencesView: some View {
        ReportBarChartView(
            title: localized("reports.offline_offences"),
            dataPoints: self.viewModel.offlineOffences.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: max(self.viewModel.maxOfflineOffence, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var chillingsView: some View {
        ReportBarChartView(
            title: localized("reports.validator.chilling_count"),
            dataPoints: self.viewModel.chillings.map {
                ($0.x, Double($0.y))
            },
            minY: 0,
            maxY: max(self.viewModel.maxChillingCount, 1),
            revealPercentage: 1.0,
            colorScheme: self.colorScheme
        )
    }
    
    private var slashesView: some View {
        ReportBarChartView(
            title: String(
                format: localized("reports.slashed_with_ticker"),
                self.network.tokenTicker
            ),
            dataPoints: self.viewModel.slashes.map {
                ($0.x, Double($0.y.value))
            },
            minY: 0,
            maxY: max(self.viewModel.maxSlash, 1),
            revealPercentage: 1.0,
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
                Text(self.identityDisplay)
                    .font(UI.Font.Report.validatorDisplay)
                    .foregroundColor(Color("Text"))
                    .modifier(PanelAppearance(0, self.chartDisplayState))
                self.dateIntervalView
                Spacer()
                    .frame(height: UI.Dimension.Common.dataPanelSpacing)
                Group {
                    ReportDataPanelView(
                        title: localized("reports.validator.active"),
                        content: self.viewModel.isActive[0].y == 1
                            ? localized("common.yes")
                            : localized("common.no")
                    )
                    .modifier(PanelAppearance(3, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.commission"),
                        content: self.viewModel.isActive[0].y == 1
                            ? String(
                                format: localized("common.percentage"),
                                formatDecimal(
                                    integer: UInt64(self.viewModel.commissionPerTenThousand[0].y),
                                    decimalCount: 2,
                                    formatDecimalCount: 2
                                )
                            )
                            : "-"
                    )
                    .modifier(PanelAppearance(4, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.self_stake"),
                        content: self.viewModel.isActive[0].y == 1
                        ? String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.selfStake[0].y,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                        : "-"
                    )
                    .modifier(PanelAppearance(5, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.total_stake"),
                        content: self.viewModel.isActive[0].y == 1
                        ? String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.totalStake[0].y,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                        : "-"
                    )
                    .modifier(PanelAppearance(6, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.block_count"),
                        content: String(self.viewModel.blockCount[0].y)
                    )
                    .modifier(PanelAppearance(7, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.reward_points"),
                        content: String(self.viewModel.rewardPoints[0].y)
                    )
                    .modifier(PanelAppearance(8, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.self_reward"),
                        content: self.viewModel.isActive[0].y == 1
                        ? String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.selfReward[0].y,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                        : "-"
                    )
                    .modifier(PanelAppearance(9, self.chartDisplayState))
                    ReportDataPanelView(
                        title: localized("reports.validator.staker_reward"),
                        content: self.viewModel.isActive[0].y == 1
                        ? String(
                            format: "%@ %@",
                            formatBalance(
                                balance: self.viewModel.stakerReward[0].y,
                                tokenDecimalCount: self.network.tokenDecimalCount
                            ),
                            self.network.tokenTicker
                        )
                        : "-"
                    )
                    .modifier(PanelAppearance(10, self.chartDisplayState))
                    Group {
                        ReportDataPanelView(
                            title: localized("reports.offline_offences"),
                            content: self.viewModel.isActive[0].y == 1
                            ? String(self.viewModel.offlineOffences[0].y)
                            : "-"
                        )
                        .modifier(PanelAppearance(11, self.chartDisplayState))
                        ReportDataPanelView(
                            title: localized("reports.validator.chillings"),
                            content: self.viewModel.isActive[0].y == 1
                            ? String(self.viewModel.chillings[0].y)
                            : "-"
                        )
                        .modifier(PanelAppearance(12, self.chartDisplayState))
                        ReportDataPanelView(
                            title: localized("reports.slashed"),
                            content: self.viewModel.isActive[0].y == 1
                            ? String(
                                format: "%@ %@",
                                formatBalance(
                                    balance: self.viewModel.slashes[0].y,
                                    tokenDecimalCount: self.network.tokenDecimalCount
                                ),
                                self.network.tokenTicker
                            )
                            : "-"
                        )
                        .modifier(PanelAppearance(13, self.chartDisplayState))
                    }
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
}

struct ValidatorReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorReportsView(
            network: PreviewData.kusama,
            accountId: PreviewData.validatorSummary.accountId,
            identityDisplay: PreviewData.validatorSummary.identityDisplay,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
