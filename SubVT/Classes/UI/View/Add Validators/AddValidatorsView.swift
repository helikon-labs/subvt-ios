//
//  AddValidatorView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.08.2022.
//

import SubVTData
import SwiftUI

struct AddValidatorsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @StateObject private var viewModel = AddValidatorsViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var networkListIsVisible = false
    @State private var actionFeedbackViewState = ActionFeedbackView.State.success
    @State private var actionFeedbackViewText = localized("common.done")
    @State private var actionFeedbackViewIsVisible = false
    @State private var snackbarIsVisible = false
    
    private var networkButtonIsEnabled: Bool {
        switch self.viewModel.networkValidatorsFetchState {
        case .success(_):
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        ZStack {
            Color("Bg")
                .ignoresSafeArea()
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
            switch self.viewModel.userValidatorsFetchState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
                    .animation(.spring(), value: self.viewModel.userValidatorsFetchState)
                    .zIndex(3)
            default:
                Group {}
            }
            VStack(alignment: .leading, spacing: 0) {
                self.titleView
                switch self.viewModel.userValidatorsFetchState {
                case .success(_):
                    self.networkTitleAndButtonView
                    self.networkListView
                    Spacer()
                        .frame(height: 24)
                    self.searchView
                    Spacer()
                        .frame(height: 8)
                    switch self.viewModel.networkValidatorsFetchState {
                    case .loading:
                        HStack {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: Color("Text")
                                    )
                                )
                                .animation(.spring(), value: self.viewModel.networkValidatorsFetchState)
                                .scaleEffect(0.75)
                                .animation(nil, value: self.viewModel.networkValidatorsFetchState)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(alignment: .center)
                    case .success(_):
                        self.validatorListView
                    default:
                        Group {}
                    }
                default:
                    Group {}
                }
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
                trailing: UI.Dimension.Common.padding
            ))
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            FooterGradientView()
                .zIndex(2)
            ActionFeedbackView(
                state: self.actionFeedbackViewState,
                text: self.actionFeedbackViewText,
                visibleYOffset: UI.Dimension.ValidatorDetails.actionFeedbackViewYOffset,
                isVisible: self.$actionFeedbackViewIsVisible
            )
            .zIndex(3)
            SnackbarView(
                message: localized("common.error.validator_list"),
                type: .error(canRetry: true)
            ) {
                self.snackbarIsVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchData()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .zIndex(3)
            .offset(
                y: self.snackbarIsVisible
                    ? UI.Dimension.AddValidators.snackbarVisibleYOffset
                    : UI.Dimension.AddValidators.snackbarHiddenYOffset
            )
            .opacity(self.snackbarIsVisible ? 1.0 : 0.0)
            .animation(
                .spring(),
                value: self.snackbarIsVisible
            )
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
            UITextField.appearance().clearButtonMode = .whileEditing
            guard let networks = self.networks else {
                return
            }
            self.viewModel.network = networks[0]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.fetchData()
                }
            }
        }
        .onDisappear() {
            
        }
        .onChange(of: scenePhase) { newPhase in
            
        }
    }
    
    private var titleView: some View {
        Group {
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
                Text(localized("add_validators.title"))
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
    }
    
    private var networkTitleAndButtonView: some View {
        Group {
            Spacer()
                .frame(height: 30)
            Text(localized("common.network"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                KeyboardUtil.dismissKeyboard()
                self.networkListIsVisible.toggle()
            } label: {
                HStack(alignment: .center) {
                    UI.Image.Common.networkIcon(
                        network: self.viewModel.network
                    )
                    .resizable()
                    .frame(
                        width: UI.Dimension.AddValidators.networkIconSize.get(),
                        height: UI.Dimension.AddValidators.networkIconSize.get()
                    )
                    Spacer()
                        .frame(width: 16)
                    Text(self.viewModel.network.display)
                        .font(UI.Font.Common.formFieldTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.networkListIsVisible {
                        UI.Image.Common.arrowUp(self.colorScheme)
                    } else {
                        UI.Image.Common.arrowDown(self.colorScheme)
                    }
                }
                .padding(EdgeInsets(
                    top: 12,
                    leading: 12,
                    bottom: 12,
                    trailing: 12
                ))
                .background(Color("DataPanelBg"))
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
            .disabled(!self.networkButtonIsEnabled)
            .opacity(self.networkButtonIsEnabled ? 1.0 : 0.75)
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
        }
    }
    
    private var networkListView: some View {
        Group {
            if let networks = self.networks, self.networkListIsVisible {
                Spacer()
                    .frame(height: 2)
                VStack(spacing: 0) {
                    ForEach(networks.indices, id: \.self) { i in
                        let network = networks[i]
                        Button(
                            action: {
                                KeyboardUtil.dismissKeyboard()
                                self.networkListIsVisible = false
                                guard self.viewModel.network.id != network.id else {
                                    return
                                }
                                self.viewModel.searchText = ""
                                self.viewModel.network = network
                                self.fetchData()
                            },
                            label: {
                                HStack(alignment: .center) {
                                    UI.Image.Common.networkIcon(
                                        network: network
                                    )
                                    .resizable()
                                    .frame(
                                        width: UI.Dimension.AddValidators.networkIconSize.get(),
                                        height: UI.Dimension.AddValidators.networkIconSize.get()
                                    )
                                    Spacer()
                                        .frame(width: 16)
                                    Text(network.display)
                                        .font(UI.Font.Common.formFieldTitle)
                                        .foregroundColor(Color("Text"))
                                    if self.viewModel.network.id == network.id {
                                        Spacer()
                                            .frame(width: 16)
                                        Circle()
                                            .fill(Color("ItemListSelectionIndicator"))
                                            .frame(
                                                width: UI.Dimension.Common.itemSelectionIndicatorSize,
                                                height: UI.Dimension.Common.itemSelectionIndicatorSize
                                            )
                                            .shadow(
                                                color: Color("ItemListSelectionIndicator"),
                                                radius: 3,
                                                x: 0,
                                                y: UI.Dimension.Common.itemSelectionIndicatorSize / 2
                                            )
                                        Spacer()
                                            .frame(width: 24)
                                    }
                                    Spacer()
                                }
                                .padding(EdgeInsets(
                                    top: 12,
                                    leading: 12,
                                    bottom: 12,
                                    trailing: 12
                                ))
                                .background(Color("DataPanelBg"))
                            }
                        )
                        .buttonStyle(ItemListButtonStyle())
                        .disabled(!self.networkButtonIsEnabled)
                        .opacity(self.networkButtonIsEnabled ? 1.0 : 0.65)
                        if i < networks.count - 1 {
                            Color("ItemSelectorListDivider")
                                .frame(height: 1)
                        }
                    }
                }
                .cornerRadius(UI.Dimension.Common.cornerRadius)
            }
        }
    }
    
    private var searchView: some View {
        Group {
            Text(localized("add_validators.validator"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(3, self.displayState))
            Spacer()
                .frame(height: 8)
            HStack {
                UI.Image.Common.searchIcon(self.colorScheme)
                TextField(
                    localized("common.search"),
                    text: self.$viewModel.searchText
                )
                .font(UI.Font.ValidatorList.search)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .submitLabel(.done)
            }
            .frame(height: 48)
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.padding,
                bottom: 0,
                trailing: UI.Dimension.Common.padding / 2
            ))
            .background(Color("DataPanelBg"))
            .cornerRadius(UI.Dimension.Common.cornerRadius)
            .modifier(PanelAppearance(3, self.displayState))
        }
    }
    
    private var validatorListView: some View {
        ScrollView {
            LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                ForEach(self.viewModel.validators, id: \.self.address) {
                    validator in
                    ValidatorSearchSummaryView(
                        validatorSearchSummary: validator,
                        network: self.viewModel.network,
                        canAdd: !self.viewModel.isUserValidator(address: validator.address),
                        isLoading: self.viewModel.addValidatorStatuses[validator.accountId] != nil
                    ) {
                        KeyboardUtil.dismissKeyboard()
                        self.viewModel.addValidator(accountId: validator.accountId)
                    }
                }
                Spacer()
                    .frame(
                        height: UI.Dimension.Common.footerGradientViewHeight
                    )
            }
            .onTapGesture {
                KeyboardUtil.dismissKeyboard()
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private func fetchData() {
        self.viewModel.fetchUserValidators {
            // no-op
        } onError: { _ in
            snackbarIsVisible = true
        }
    }
}

struct AddValidatorsView_Previews: PreviewProvider {
    static var previews: some View {
        AddValidatorsView()
    }
}
