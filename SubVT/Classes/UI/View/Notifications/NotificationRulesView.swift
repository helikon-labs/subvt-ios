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
    @State private var snackbarIsVisible = false
    @State private var headerMaterialOpacity = 0.0
    
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
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(spacing: UI.Dimension.ValidatorList.itemSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.MyValidators.scrollContentMarginTop)
                        ForEach(self.viewModel.rules, id: \.self.id) {
                            rule in
                            NotificationRuleView(rule: rule)
                        }
                        Spacer()
                            .frame(
                                height: UI.Dimension.Common.footerGradientViewHeight
                            )
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
            switch self.viewModel.rulesFetchState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: Color("Text")
                        )
                    )
                    .animation(.spring(), value: self.viewModel.rulesFetchState)
                    .zIndex(3)
            default:
                Group {}
            }
            self.titleView
                .zIndex(1)
            FooterGradientView()
                .zIndex(2)
            SnackbarView(
                message: localized("common.error.validator_list"),
                type: .error(canRetry: true)
            ) {
                self.snackbarIsVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // self.fetchData()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.viewModel.fetchRules()
                }
            }
        }
    }
    
    private var titleView: some View {
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
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
    }
}

struct NotificationRulesView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRulesView()
    }
}
