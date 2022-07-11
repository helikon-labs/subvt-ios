//
//  Onboarding.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingParentView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.hasBeenOnboarded) private var hasBeenOnboarded = false
    @State private var step: OnboardingStep = .step1
    @State private var displayState: BasicViewDisplayState = .notAppeared
    private let pageCount: Int = OnboardingStep.allCases.count
    
    var body: some View {
        ZStack {
            Color("Bg").ignoresSafeArea()
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.pageNumberMarginTop)
                HStack(spacing: 0) {
                    Text("\(self.step.index + 1)")
                        .font(UI.Font.Onboarding.currentPage)
                        .foregroundColor(Color("Text"))
                        .frame(width: 12)
                    Text("/")
                        .font(UI.Font.Onboarding.pageCount)
                        .foregroundColor(Color("Text"))
                        .frame(width: 8)
                    Text("\(pageCount)")
                        .font(UI.Font.Onboarding.pageCount)
                        .foregroundColor(Color("Text"))
                        .frame(width: 12)
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Onboarding.textHorizontalPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Onboarding.textHorizontalPadding
                ))
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.titleMarginTop)
                TabView(selection: $step) {
                    OnboardingPageView(step: .step1).tag(OnboardingStep.step1)
                    OnboardingPageView(step: .step2).tag(OnboardingStep.step2)
                    OnboardingPageView(step: .step3).tag(OnboardingStep.step3)
                    OnboardingPageView(step: .step4).tag(OnboardingStep.step4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.navigationSectionMarginTop)
                HStack {
                    Text(LocalizedStringKey("onboarding.skip"))
                        .font(UI.Font.Onboarding.skipButton)
                        .foregroundColor(Color("Text"))
                        .onTapGesture {
                            self.displayState = .dissolved
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.hasBeenOnboarded = true
                            }
                        }
                    Spacer()
                    HStack(spacing: UI.Dimension.Onboarding.pageCircleSpacing) {
                        ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                            Circle()
                                .fill((step == self.step)
                                      ? Color("ActionButtonBg")
                                      : Color("OnboardingPageCircleBg")
                                )
                                .frame(
                                    width: UI.Dimension.Onboarding.pageCircleSize,
                                    height: UI.Dimension.Onboarding.pageCircleSize
                                )
                                .shadow(
                                    color: (step == self.step) ? Color("ActionButtonBg") : Color.clear,
                                    radius: 3,
                                    x: 0,
                                    y: UI.Dimension.Onboarding.pageCircleSize / 2
                                )
                        }
                    }
                    .animation(
                        .easeOut(duration: 0.25),
                        value: self.step
                    )
                    Spacer()
                    Text(LocalizedStringKey("onboarding.next"))
                        .font(UI.Font.Onboarding.nextButton)
                        .foregroundColor(Color("Text"))
                        .onTapGesture {
                            if self.step == .step4 {
                                self.displayState = .dissolved
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    self.hasBeenOnboarded = true
                                }
                            } else {
                                withAnimation {
                                    self.step = self.step.nextStep
                                }
                            }
                        }
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Onboarding.textHorizontalPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Onboarding.textHorizontalPadding
                ))
                Spacer()
                    .frame(height: 40)
            }
        }
        .opacity(self.displayState == .appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5))
        .onAppear {
            self.displayState = .appeared
        }
    }
}

struct OnboardingParentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingParentView()
            .preferredColorScheme(.dark)
    }
}
