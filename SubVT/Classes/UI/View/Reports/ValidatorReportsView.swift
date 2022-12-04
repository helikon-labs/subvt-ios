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
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = ValidatorReportsViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var chartDisplayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    // disable inner chart animation
    @State private var chartRevealPercentage: CGFloat = 1.0
    
    private let network: Network
    private let validatorSummary: ValidatorSummary
    private let startEra: Era
    private let endEra: Era
    
    private let dateFormatter = DateFormatter()
    
    init(
        network: Network,
        validatorSummary: ValidatorSummary,
        startEra: Era,
        endEra: Era
    ) {
        self.network = network
        self.validatorSummary = validatorSummary
        self.startEra = startEra
        self.endEra = endEra
        
        self.dateFormatter.dateFormat = "dd MMM ''YY HH:mm"
    }
    
    private func getDateDisplay(
        index: UInt,
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
                    validatorSummary: self.validatorSummary,
                    network: self.network
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
            validatorSummary: PreviewData.validatorSummary,
            startEra: PreviewData.era,
            endEra: PreviewData.era
        )
    }
}
