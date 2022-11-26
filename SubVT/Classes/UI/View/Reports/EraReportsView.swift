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
    @State private var headerMaterialOpacity = 0.0
    
    private let startEra: Era
    private let endEra: Era
    private let network: Network
    
    init(
        network: Network,
        startEra: Era,
        endEra: Era
    ) {
        self.network = network
        self.startEra = startEra
        self.endEra = endEra
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
                self.chartCollectionView
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
    }
    
    private var chartCollectionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .id(0)
                    .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                    ZStack {
                        LineChartView(
                            dataPoints: self.viewModel.activeValidatorCounts,
                            chartMinY: 0,
                            chartMaxY: 2000,
                            revealPercentage: self.viewModel.activeValidatorCounts.count > 0 ? 1.0 : 0.0
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
                                Text("Title X")
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
                    ZStack {
                        LineChartView(
                            dataPoints: self.viewModel.inactiveValidatorCounts,
                            chartMinY: 0,
                            chartMaxY: 2000,
                            revealPercentage: self.viewModel.activeValidatorCounts.count > 0 ? 1.0 : 0.0
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
                    }
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
