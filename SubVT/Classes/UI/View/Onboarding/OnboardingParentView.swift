//
//  Onboarding.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingParentView: View {
    
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State private var step = OnboardingStep.step1
    private let pageCount: Int = OnboardingStep.allCases.count
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
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
                    Spacer()
                    HStack(spacing: UI.Dimension.Onboarding.pageCircleSpacing) {
                        ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                            Circle()
                                .fill((step == self.step)
                                      ? Color("ActionButton")
                                      : Color("OnboardingPageCircleBg")
                                )
                                .frame(
                                    width: UI.Dimension.Onboarding.pageCircleSize,
                                    height: UI.Dimension.Onboarding.pageCircleSize
                                )
                                .shadow(
                                    color: (step == self.step) ? Color("ActionButton") : Color.clear,
                                    radius: 3,
                                    x: 0,
                                    y: UI.Dimension.Onboarding.pageCircleSize / 2
                                )
                        }
                        /*
                        ForEach(0 ..< self.pageCount, id:\.self) { i in
                            Circle()
                                .fill((i == self.step.index)
                                      ? Color("ActionButton")
                                      : Color("OnboardingPageCircleBg")
                                )
                                .frame(
                                    width: UI.Dimension.Onboarding.pageCircleSize,
                                    height: UI.Dimension.Onboarding.pageCircleSize
                                )
                                .shadow(
                                    color: (i == self.step.index) ? Color("ActionButton") : Color.clear,
                                    radius: 3,
                                    x: 0,
                                    y: UI.Dimension.Onboarding.pageCircleSize / 2
                                )
                        } */
                    }
                    .animation(Animation.easeOut(duration: 0.25))
                    Spacer()
                    Text(LocalizedStringKey("onboarding.next"))
                        .font(UI.Font.Onboarding.nextButton)
                        .foregroundColor(Color("Text"))
                        .onTapGesture {
                            withAnimation {
                                self.step = self.step.nextStep
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
            // .onAppear(perform: { UIScrollView.appearance().bounces = false })
        }
    }
}

struct OnboardingParentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingParentView()
    }
}
