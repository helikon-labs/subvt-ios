//
//  MyValidatorsView.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import SwiftUI
import SubVTData

struct MyValidatorsView: View {
    @StateObject private var viewModel = MyValidatorsViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(localized("my_validators.title"))
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
                    Text(localized("my_validators.error.fetch"))
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
                    if self.viewModel.userValidatorSummaries.isEmpty {
                        Text(localized("my_validators.no_validators.watch"))
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
                    LazyVStack(spacing: UI.Dimension.Common.listItemSpacing) {
                        ForEach(self.viewModel.userValidatorSummaries, id: \.self.validatorSummary.address) {
                            userValidatorSummary in
                            let validator = userValidatorSummary.validatorSummary
                            let network = viewModel.networks!.first(where: { network in
                                network.id == validator.networkId
                            })!
                            ValidatorSummaryView(
                                validatorSummary: validator,
                                network: network,
                                displaysNetworkIcon: true,
                                displaysActiveStatus: true
                            )
                            .transition(.move(edge: .leading))
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
        .onAppear() {
            if self.viewModel.fetchState == .idle {
                self.viewModel.initReportServices()
                self.viewModel.fetchMyValidators()
            }
        }
    }
}
