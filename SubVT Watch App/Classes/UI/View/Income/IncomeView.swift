//
//  IncomeView.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import Foundation
import SwiftUI

struct IncomeView: View {
    @StateObject private var viewModel = IncomeViewModel()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    Text(localized("monthly_income.title"))
                        .font(UI.Font.Common.title)
                        .foregroundColor(Color("Text"))
                        .padding(EdgeInsets(
                            top: 0,
                            leading: UI.Dimension.Common.padding,
                            bottom: 0,
                            trailing: UI.Dimension.Common.padding
                        ))
                    switch self.viewModel.fetchState {
                    case .error(_):
                        Text(localized("monthly_income.error.fetch"))
                            .font(UI.Font.Common.info)
                            .foregroundColor(Color("Text"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(EdgeInsets(
                                top: UI.Dimension.Common.padding,
                                leading: UI.Dimension.Common.padding,
                                bottom: 0,
                                trailing: UI.Dimension.Common.padding
                            ))
                            .opacity(0.7)
                    case .success(_):
                        if self.viewModel.userValidators.isEmpty {
                            Text(localized("monthly_income.no_validators"))
                                .font(UI.Font.Common.info)
                                .foregroundColor(Color("Text"))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(EdgeInsets(
                                    top: UI.Dimension.Common.padding,
                                    leading: UI.Dimension.Common.padding,
                                    bottom: 0,
                                    trailing: UI.Dimension.Common.padding
                                ))
                                .opacity(0.7)
                        } else if self.viewModel.monthlyIncome.isEmpty {
                            Text(localized("monthly_income.no_income"))
                                .font(UI.Font.Common.info)
                                .foregroundColor(Color("Text"))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(EdgeInsets(
                                    top: UI.Dimension.Common.padding,
                                    leading: UI.Dimension.Common.padding,
                                    bottom: 0,
                                    trailing: UI.Dimension.Common.padding
                                ))
                                .opacity(0.7)
                        }
                    default:
                        EmptyView()
                    }
                    ScrollView {
                        LazyVStack(spacing: UI.Dimension.Common.listItemSpacing / 2) {
                            ForEach(self.viewModel.monthlyIncome, id: \.self.hashValue) {
                                monthlyIncome in
                                let monthYear = formatMonthYear(
                                    index: Int(monthlyIncome.year * 12 + monthlyIncome.month - 1)
                                ).replacingOccurrences(of: " ", with: "")
                                let incomeFormatted = formatDecimal(
                                    integer: UInt64(((monthlyIncome.income * 100) as NSDecimalNumber).intValue),
                                    decimalCount: 2,
                                    formatDecimalCount: 2
                                )
                                let incomeRatio = ((monthlyIncome.income / self.viewModel.maxMonthlyIncome) as NSDecimalNumber).floatValue
                                let width = (geometry.size.width - UI.Dimension.Common.padding * 2) * CGFloat(incomeRatio)
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .foregroundColor(Color("DataPanelBg"))
                                        .frame(
                                            width: geometry.size.width - UI.Dimension.Common.padding * 2,
                                            height: 32.0
                                        )
                                        .opacity(0.35)
                                        .cornerRadius(2)
                                    Rectangle()
                                        .foregroundColor(Color("SubVTBlue"))
                                        .frame(
                                            width: width,
                                            height: 32.0
                                        )
                                        .opacity(0.3)
                                        .cornerRadius(2)
                                    HStack(alignment: .center, spacing: 0) {
                                        Text(monthYear)
                                            .font(UI.Font.Income.income)
                                            .foregroundColor(Color("Text"))
                                        Spacer()
                                        Text("$\(incomeFormatted)")
                                            .font(UI.Font.Income.income)
                                            .foregroundColor(Color("Text"))
                                    }
                                }
                                .frame(height: 36)
                            }
                        }
                        .padding(EdgeInsets(
                            top: 0,
                            leading: UI.Dimension.Common.padding,
                            bottom: 0,
                            trailing: UI.Dimension.Common.padding
                        ))
                    }
                }
                switch self.viewModel.fetchState {
                case .loading:
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Color("Text")
                            )
                        )
                case .error(_):
                    VStack {
                        Spacer()
                        Button {
                            self.viewModel.fetchMyValidators()
                        } label: {
                            Text(localized("common.retry"))
                                .font(UI.Font.Common.actionButton)
                                .foregroundColor(Color("Text"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(UI.Dimension.Common.lineSpacing)
                                .frame(alignment: .bottom)
                        }
                        .frame(alignment: .bottom)
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                default:
                    EmptyView()
                }
            }
        }
        .onAppear() {
            if self.viewModel.fetchState == .idle {
                self.viewModel.fetchMyValidators()
            }
        }
    }
}
