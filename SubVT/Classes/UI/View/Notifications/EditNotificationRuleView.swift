//
//  EditNotificationRuleView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.10.2022.
//

import SubVTData
import SwiftUI

struct EditNotificationRuleView: View {
    enum Mode {
        case create
        case edit(rule: UserNotificationRule)
    }
    
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @AppStorage(AppStorageKey.notificationChannelId) private var notificationChannelId = 0
    @StateObject private var viewModel = EditNotificationRuleViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var networkListIsVisible = false
    @State private var notificationTypeListIsVisible = false
    @State private var validatorListIsVisible = false
    @State private var periodTypeListIsVisible = false
    @State private var periodListIsVisible = false
    @State private var overwriteRuleConfirmationDialogIsVisible: Bool = false
    
    private var controlsAreLocked: Bool {
        switch self.viewModel.dataPersistState {
        case .loading, .success:
            return true
        default:
            return false
        }
    }
    
    private var actionButtonState: ActionButtonView.State {
        switch self.viewModel.dataFetchState {
        case .idle, .loading, .error:
            return .disabled
        case .success:
            switch self.viewModel.dataPersistState {
            case .idle:
                return .enabled
            case .loading, .success:
                return .loading
            case .error:
                return .disabled
            }
        }
    }
    
    private var snackbarIsVisible: Bool {
        switch self.viewModel.dataFetchState {
        case .error:
            return true
        default:
            switch self.viewModel.dataPersistState {
            case .error:
                return true
            default:
                break
            }
            break
        }
        return false
    }
    
    private var title: String {
        switch self.mode {
        case .create:
            return localized("edit_notification_rule.title.create")
        case .edit:
            return localized("edit_notification_rule.title.edit")
        }
    }
    
    private var snackbarMessage: String {
        switch self.viewModel.dataFetchState {
        case .error:
            return localized("edit_notification_rule.error.data_fetch")
        default:
            switch self.viewModel.dataPersistState {
            case .error:
                return localized("edit_notification_rule.error.data_persist")
            default:
                break
            }
        }
        return ""
    }
    
    private var snackbarCanRetry: Bool {
        switch self.viewModel.dataFetchState {
        case .error:
            return true
        default:
            return false
        }
    }
    
    private var confirmationDialogTitle: String {
        if let notificationType = self.viewModel.notificationType {
            return localized("notification_type.\(notificationType.code)")
        } else {
            return ""
        }
    }
    
    private let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
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
            switch self.viewModel.dataFetchState {
            case .success:
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                                .frame(height: UI.Dimension.EditNotificationRule.scrollContentMarginTop)
                            Group {
                                Spacer()
                                    .frame(height: 24)
                                self.networkTitleAndButtonView
                                if self.networkListIsVisible {
                                    Spacer()
                                        .frame(height: 2)
                                    self.networkListView
                                }
                            }
                            Group {
                                Spacer()
                                    .frame(height: 24)
                                self.notificationTypeTitleAndButtonView
                                if self.notificationTypeListIsVisible {
                                    Spacer()
                                        .frame(height: 2)
                                    self.notificationTypeListView
                                }
                            }
                            Group {
                                Spacer()
                                    .frame(height: 24)
                                self.validatorTitleAndButtonView
                                if self.validatorListIsVisible {
                                    Spacer()
                                        .frame(height: 2)
                                    self.validatorListView
                                }
                            }
                            Group {
                                Spacer()
                                    .frame(height: 24)
                                self.periodTypeTitleAndButtonView
                                if self.periodTypeListIsVisible {
                                    Spacer()
                                        .frame(height: 2)
                                    self.periodTypeListView
                                }
                            }
                            Group {
                                switch self.viewModel.periodType {
                                case .hour, .day, .epoch, .era:
                                    Spacer()
                                        .frame(height: 24)
                                    self.periodTitleAndButtonView
                                    if self.periodListIsVisible {
                                        Spacer()
                                            .frame(height: 2)
                                        self.periodListView
                                    }
                                default:
                                    Group {}
                                }
                            }
                            Color.clear
                                .frame(height: UI.Dimension.EditNotificationRule.scrollContentMarginBottom)
                                .frame(maxWidth: .infinity)
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
                .zIndex(1)
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
                    .animation(.spring(), value: self.viewModel.dataFetchState)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .zIndex(10)
            default:
                Group {}
            }
            FooterGradientView()
                .zIndex(2)
            ZStack {
                Button(
                    action: {
                        guard self.viewModel.getUserNotificationRuleByType(
                            typeCode: self.viewModel.notificationType.code
                        ) == nil else {
                            self.overwriteRuleConfirmationDialogIsVisible = true
                            return
                        }
                        self.networkListIsVisible = false
                        self.notificationTypeListIsVisible = false
                        self.validatorListIsVisible = false
                        self.periodTypeListIsVisible = false
                        self.periodListIsVisible = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.viewModel.createRule(
                                channelId: UInt64(self.notificationChannelId)
                            ) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    },
                    label: {
                        ActionButtonView(
                            title: localized("edit_notification_rule.create_rule"),
                            state: self.actionButtonState,
                            font: UI.Font.EditNotificationRule.actionButton,
                            width: UI.Dimension.EditNotificationRule.actionButtonWidth,
                            height: UI.Dimension.EditNotificationRule.actionButtonHeight
                        )
                    }
                )
                .buttonStyle(ActionButtonStyle(state: self.actionButtonState))
                .offset(
                    x: 0,
                    y: UI.Dimension.EditNotificationRule.actionButtonYOffset(
                        dataFetchState: self.viewModel.dataFetchState,
                        dataPersistState: self.viewModel.dataPersistState
                    )
                )
                .animation(.spring(), value: self.viewModel.dataFetchState)
                .animation(.spring(), value: self.viewModel.dataPersistState)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .zIndex(3)
            SnackbarView(
                message: self.snackbarMessage,
                type: .error(canRetry: self.snackbarCanRetry)
            ) {
                if self.snackbarCanRetry {
                    self.viewModel.fetchData()
                } else {
                    self.viewModel.resetDataPersistState()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(
                y: self.snackbarIsVisible
                    ? UI.Dimension.NotificationRules.snackbarVisibleYOffset
                    : UI.Dimension.NotificationRules.snackbarHiddenYOffset
            )
            .opacity(self.snackbarIsVisible ? 1.0 : 0.0)
            .animation(
                .spring(),
                value: self.snackbarIsVisible
            )
            .zIndex(4)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.initReportServices(networks: self.networks ?? [])
                    self.viewModel.fetchData()
                }
            }
        }
        .onTapGesture {
            self.networkListIsVisible = false
            self.notificationTypeListIsVisible = false
            self.validatorListIsVisible = false
        }
        .confirmationDialog(
            String(
                format: localized("edit_notification_rule.update_confirmation"),
                self.confirmationDialogTitle
            ),
            isPresented: self.$overwriteRuleConfirmationDialogIsVisible,
            titleVisibility: .visible
        ) {
            Button(
                localized("common.overwrite"),
                role: .destructive
            ) {
                self.viewModel.deleteAndCreateRule(
                    channelId: UInt64(self.notificationChannelId)
                ) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            Button(localized("common.cancel"), role: .cancel) {}
        }
    }
    
    private var networkTitleAndButtonView: some View {
        Group {
            Text(localized("common.network"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.networkListIsVisible.toggle()
                self.notificationTypeListIsVisible = false
                self.validatorListIsVisible = false
                self.periodTypeListIsVisible = false
                self.periodListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    if let network = self.viewModel.network {
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
                    } else {
                        Text(localized("edit_notification_rule.all_networks"))
                            .font(UI.Font.Common.formFieldTitle)
                            .foregroundColor(Color("Text"))
                    }
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
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
            .disabled(self.controlsAreLocked)
            .opacity(self.controlsAreLocked ? UI.Value.disabledControlOpacity : 1.0)
        }
    }
    
    private var networkListView: some View {
        Group {
            if let networks = self.networks, self.networkListIsVisible {
                VStack(spacing: 0) {
                    Button(
                        action: {
                            self.viewModel.network = nil
                            self.viewModel.validator = nil
                            self.networkListIsVisible = false
                        },
                        label: {
                            HStack(alignment: .center) {
                                Text(localized("edit_notification_rule.all_networks"))
                                    .font(UI.Font.Common.formFieldTitle)
                                    .foregroundColor(Color("Text"))
                                if self.viewModel.network == nil {
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
                    Color("ItemSelectorListDivider")
                        .frame(height: 1)
                    ForEach(networks.indices, id: \.self) { i in
                        let network = networks[i]
                        Button(
                            action: {
                                self.viewModel.network = network
                                self.viewModel.validator = nil
                                self.networkListIsVisible = false
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
                                    if network.id == (self.viewModel.network?.id ?? 0) {
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
    
    private var notificationTypeTitleAndButtonView: some View {
        Group {
            Text(localized("common.notification_type"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.notificationTypeListIsVisible.toggle()
                self.networkListIsVisible = false
                self.validatorListIsVisible = false
                self.periodTypeListIsVisible = false
                self.periodListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    Text(localized("notification_type.\(self.viewModel.notificationType.code)"))
                        .font(UI.Font.Common.formFieldTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.notificationTypeListIsVisible {
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
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
            .disabled(self.controlsAreLocked)
            .opacity(self.controlsAreLocked ? UI.Value.disabledControlOpacity : 1.0)
        }
    }
    
    private var notificationTypeListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(self.viewModel.notificationTypes.indices, id: \.self) { i in
                    let notificationType = self.viewModel.notificationTypes[i]
                    Button(
                        action: {
                            self.viewModel.notificationType = notificationType
                            self.notificationTypeListIsVisible = false
                        },
                        label: {
                            HStack(alignment: .center) {
                                Text(localized("notification_type.\(notificationType.code)"))
                                    .font(UI.Font.Common.formFieldTitle)
                                    .foregroundColor(Color("Text"))
                                if notificationType.code == (self.viewModel.notificationType.code) {
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
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(
                                top: 12,
                                leading: 12,
                                bottom: 12,
                                trailing: 12
                            ))
                            .frame(maxWidth: .infinity)
                            .background(Color("DataPanelBg"))
                        }
                    )
                    .buttonStyle(ItemListButtonStyle())
                    if i < self.viewModel.notificationTypes.count - 1 {
                        Color("ItemSelectorListDivider")
                            .frame(height: 1)
                    }
                }
            }
        }
        .frame(maxHeight: UI.Dimension.EditNotificationRule.subSelectionScrollViewMaxHeight.get())
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
    
    private var validatorTitleAndButtonView: some View {
        Group {
            Text(localized("common.validator"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.validatorListIsVisible.toggle()
                self.networkListIsVisible = false
                self.notificationTypeListIsVisible = false
                self.periodTypeListIsVisible = false
                self.periodListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    if let userValidatorSummary = self.viewModel.validator {
                        Text(userValidatorSummary.validatorSummary.identityDisplay)
                            .font(UI.Font.Common.formFieldTitle)
                            .foregroundColor(Color("Text"))
                    } else {
                        if let network = self.viewModel.network {
                            Text(String(
                                format: localized("edit_notification_rule.all_network_validators"),
                                network.display
                            ))
                            .font(UI.Font.Common.formFieldTitle)
                            .foregroundColor(Color("Text"))
                        } else {
                            Text(localized("edit_notification_rule.all_validators"))
                                .font(UI.Font.Common.formFieldTitle)
                                .foregroundColor(Color("Text"))
                        }
                    }
                    Spacer()
                    if self.validatorListIsVisible {
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
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
            .disabled(self.controlsAreLocked)
            .opacity(self.controlsAreLocked ? UI.Value.disabledControlOpacity : 1.0)
        }
    }
    
    private var validatorListView: some View {
        Group {
            VStack(spacing: 0) {
                Button(
                    action: {
                        self.viewModel.validator = nil
                        self.validatorListIsVisible = false
                    },
                    label: {
                        HStack(alignment: .center) {
                            if let network = self.viewModel.network {
                                Text(String(
                                    format: localized("edit_notification_rule.all_network_validators"),
                                    network.display
                                ))
                                .font(UI.Font.Common.formFieldTitle)
                                .foregroundColor(Color("Text"))
                            } else {
                                Text(localized("edit_notification_rule.all_validators"))
                                    .font(UI.Font.Common.formFieldTitle)
                                    .foregroundColor(Color("Text"))
                            }
                            if self.viewModel.validator == nil {
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
                if self.viewModel.filteredUserValidatorSummaries.count > 0 {
                    Color("ItemSelectorListDivider")
                        .frame(height: 1)
                }
                ForEach(self.viewModel.filteredUserValidatorSummaries.indices, id: \.self) { i in
                    let validator = self.viewModel.filteredUserValidatorSummaries[i]
                    Button(
                        action: {
                            self.viewModel.validator = validator
                            self.validatorListIsVisible = false
                        },
                        label: {
                            HStack(alignment: .center) {
                                Text(validator.validatorSummary.identityDisplay)
                                    .font(UI.Font.Common.formFieldTitle)
                                    .foregroundColor(Color("Text"))
                                    .truncationMode(.middle)
                                if let selectedValidator = self.viewModel.validator,
                                   selectedValidator.validatorSummary.accountId == validator.validatorSummary.accountId {
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
                    if i < self.viewModel.filteredUserValidatorSummaries.count - 1 {
                        Color("ItemSelectorListDivider")
                            .frame(height: 1)
                    }
                }
            }
            .cornerRadius(UI.Dimension.Common.cornerRadius)
        }
    }
    
    private var periodTypeTitleAndButtonView: some View {
        Group {
            Text(localized("common.period_type"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.periodTypeListIsVisible.toggle()
                self.networkListIsVisible = false
                self.notificationTypeListIsVisible = false
                self.validatorListIsVisible = false
                self.periodListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    Text(self.viewModel.periodType.display)
                        .font(UI.Font.Common.formFieldTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.periodTypeListIsVisible {
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
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
            .disabled(self.controlsAreLocked)
            .opacity(self.controlsAreLocked ? UI.Value.disabledControlOpacity : 1.0)
        }
    }
    
    private var periodTypeListView: some View {
        VStack(spacing: 0) {
            let allPeriodTypes = NotificationPeriodType.allCases
            ForEach(allPeriodTypes.indices, id: \.self) { i in
                let periodType = allPeriodTypes[i]
                Button(
                    action: {
                        self.viewModel.periodType = periodType
                        self.periodTypeListIsVisible = false
                    },
                    label: {
                        HStack(alignment: .center) {
                            Text(periodType.display)
                                .font(UI.Font.Common.formFieldTitle)
                                .foregroundColor(Color("Text"))
                                .truncationMode(.middle)
                            if periodType == self.viewModel.periodType {
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
                if i < allPeriodTypes.count - 1 {
                    Color("ItemSelectorListDivider")
                        .frame(height: 1)
                }
            }
        }
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
    
    private var periodTitleAndButtonView: some View {
        Group {
            Text(localized("common.period"))
                .font(UI.Font.AddValidators.subtitle)
                .foregroundColor(Color("Text"))
                .modifier(PanelAppearance(2, self.displayState))
            Spacer()
                .frame(height: 8)
            Button {
                self.periodListIsVisible.toggle()
                self.networkListIsVisible = false
                self.notificationTypeListIsVisible = false
                self.validatorListIsVisible = false
                self.periodTypeListIsVisible = false
            } label: {
                HStack(alignment: .center) {
                    Text("\(self.viewModel.period)")
                        .font(UI.Font.Common.formFieldTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    if self.periodListIsVisible {
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
            .buttonStyle(ItemListButtonStyle())
            .modifier(PanelAppearance(2, self.displayState))
            .disabled(self.controlsAreLocked)
            .opacity(self.controlsAreLocked ? UI.Value.disabledControlOpacity : 1.0)
        }
    }
    
    private var periodListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(self.viewModel.availablePeriods.indices, id: \.self) { i in
                    let period = self.viewModel.availablePeriods[i]
                    Button(
                        action: {
                            self.viewModel.period = period
                            self.periodListIsVisible = false
                        },
                        label: {
                            HStack(alignment: .center) {
                                Text("\(period)")
                                    .font(UI.Font.Common.formFieldTitle)
                                    .foregroundColor(Color("Text"))
                                    .truncationMode(.middle)
                                if period == self.viewModel.period {
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
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(
                                top: 12,
                                leading: 12,
                                bottom: 12,
                                trailing: 12
                            ))
                            .frame(maxWidth: .infinity)
                            .background(Color("DataPanelBg"))
                        }
                    )
                    .buttonStyle(ItemListButtonStyle())
                    if i < self.viewModel.availablePeriods.count - 1 {
                        Color("ItemSelectorListDivider")
                            .frame(height: 1)
                    }
                }
            }
        }
        .frame(maxHeight: UI.Dimension.EditNotificationRule.subSelectionScrollViewMaxHeight.get())
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
}

struct EditNotificationRuleView_Previews: PreviewProvider {
    static var previews: some View {
        EditNotificationRuleView(
            mode: EditNotificationRuleView.Mode.edit(
                rule: PreviewData.notificationRule
            )
        )
    }
}
