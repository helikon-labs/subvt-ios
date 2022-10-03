//
//  NotificationRulesView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import SwiftUI

struct NotificationRulesView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = NotificationRulesViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    
    @State private var actionFeedbackViewState = ActionFeedbackView.State.success
    @State private var actionFeedbackViewText = localized("common.done")
    @State private var actionFeedbackViewIsVisible = false
    
    private var snackbarIsVisible: Bool {
        switch self.viewModel.rulesFetchState {
        case .error:
            return true
        default:
            return false
        }
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
                Text(localized("notification_rules.title"))
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
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                        ForEach(self.viewModel.rules, id: \.self.id) {
                            rule in
                            NotificationRuleView(rule: rule)
                                .modifier(SwipeDeleteViewModifier {
                                    self.viewModel.deleteRule(rule) { isSuccessful in
                                        if isSuccessful {
                                            self.actionFeedbackViewState = .success
                                            self.actionFeedbackViewText = localized("notification_rules.rule_deleted")
                                        } else {
                                            self.actionFeedbackViewState = .error
                                            self.actionFeedbackViewText = localized("common.error")
                                        }
                                        self.actionFeedbackViewIsVisible = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + UI.Duration.actionFeedbackViewVisibleDuration) {
                                            self.actionFeedbackViewIsVisible = false
                                        }
                                    }
                                })
                        }
                        Spacer()
                            .frame(
                                height: UI.Dimension.Common.footerGradientViewHeight
                            )
                    }
                    .animation(.interactiveSpring(), value: self.viewModel.rules)
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
            switch self.viewModel.rulesFetchState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
                    .animation(.spring(), value: self.viewModel.rulesFetchState)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .zIndex(10)
            default:
                Group {}
            }
            FooterGradientView()
                .zIndex(2)
            SnackbarView(
                message: localized("notification_rules.error.rule_list"),
                type: .error(canRetry: true)
            ) {
                self.viewModel.fetchRules()
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
            .zIndex(3)
            ActionFeedbackView(
                state: self.actionFeedbackViewState,
                text: self.actionFeedbackViewText,
                visibleYOffset: UI.Dimension.NotificationRules.actionFeedbackViewYOffset,
                isVisible: self.$actionFeedbackViewIsVisible
            )
            .zIndex(1)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.fetchRules()
                }
            }
        }
    }
}

struct NotificationRulesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRulesView()
    }
}
