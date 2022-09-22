//
//  MyValidatorsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 5.08.2022.
//

import SubVTData
import SwiftUI

struct MyValidatorsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @StateObject private var viewModel = MyValidatorsViewModel()
    @State private var headerMaterialOpacity = 0.0
    @State private var swipedValidator: ValidatorSummary? = nil
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 0) {
                    Text(localized("my_validators.title"))
                        .font(UI.Font.Common.tabViewTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(width: UI.Dimension.Common.padding)
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: Color("Text")
                            )
                        )
                        .opacity(self.viewModel.fetchState == .loading ? 1.0 : 0.0)
                        .animation(.spring(), value: self.viewModel.fetchState)
                        .scaleEffect(0.8)
                        .animation(nil, value: self.viewModel.fetchState)
                }
                Spacer()
            }
            .frame(height: UI.Dimension.Common.networkSelectorHeight)
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
    
    private var addValidatorsButtonView: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(localized("my_validators.add_validators"))
                .font(UI.Font.MyValidators.addValidatorsButton)
                .foregroundColor(Color("AddValidatorsButtonText"))
            UI.Image.MyValidators.unionIcon(self.colorScheme)
        }
        .frame(
            width: UI.Dimension.MyValidators.addValidatorsButtonWidth,
            height: UI.Dimension.MyValidators.addValidatorsButtonHeight,
            alignment: .center
        )
        .background(Color("TabBarBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
    
    private var addValidatorButtonOpacity: Double {
        get {
            switch self.viewModel.fetchState {
            case .success, .loading, .idle:
                return 1.0
            default:
                return 0.0
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            headerView
                .zIndex(2)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                        ForEach(self.viewModel.userValidatorSummaries, id: \.self.validatorSummary.address) {
                            userValidatorSummary in
                            let validator = userValidatorSummary.validatorSummary
                            let network = networks!.first(where: { network in
                                network.id == validator.networkId
                            })!
                            NavigationLink {
                                ValidatorDetailsView(
                                    network: network,
                                    validatorSummary: validator
                                )
                            } label: {
                                ValidatorSummaryView(
                                    validatorSummary: validator,
                                    network: network,
                                    displaysNetworkIcon: true,
                                    displaysActiveStatus: true
                                )
                                .modifier(SwipeDeleteViewModifier(
                                    validator: validator,
                                    action: {
                                        self.viewModel.deleteUserValidator(userValidatorSummary)
                                    }
                                ))

                            }
                            .transition(.move(edge: .leading))
                            .buttonStyle(PushButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded{
                                self.swipedValidator = nil
                            })
                        }
                        Spacer()
                            .frame(
                                height: UI.Dimension.MyValidators.scrollContentBottomSpacerHeight
                            )
                    }
                    .animation(.interactiveSpring(), value: self.viewModel.userValidatorSummaries)
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
            .zIndex(0)
            FooterGradientView()
                .zIndex(1)
            NavigationLink {
                AddValidatorsView()
            } label: {
                self.addValidatorsButtonView
            }
            .opacity(self.addValidatorButtonOpacity)
            .animation(.spring(), value: self.viewModel.fetchState)
            .buttonStyle(PushButtonStyle())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .offset(y: UI.Dimension.MyValidators.addValidatorsButtonYOffset)
            .animation(nil, value: self.viewModel.fetchState)
            
            ZStack {
                SnackbarView(
                    message: localized("common.error.validator_list"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchMyValidators()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(
                    y: UI.Dimension.MyValidators.snackbarYOffset(
                        fetchState: self.viewModel.fetchState
                    )
                )
                .opacity(UI.Dimension.MyValidators.snackbarOpacity(
                    fetchState: self.viewModel.fetchState
                ))
                .animation(
                    .spring(),
                    value: self.viewModel.fetchState
                )
            }
        }
        .navigationBarHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            if self.viewModel.fetchState == .idle {
                self.viewModel.initReportServices(networks: self.networks ?? [])
                self.viewModel.fetchMyValidators()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                break
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                fatalError("Unknown scene phase: \(scenePhase)")
            }
        }
    }
}

struct MyValidatorsView_Previews: PreviewProvider {
    static var previews: some View {
        MyValidatorsView()
    }
}
