//
//  OnboardingPageView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI

struct OnboardingPageView: View {
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    let step: OnboardingStep
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text(step.title)
                    .font(UI.Font.Onboarding.title)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("Text"))
                Spacer()
                    .frame(height: UI.Dimension.Onboarding.descriptionMarginTop)
                Text(step.description)
                    .font(UI.Font.Onboarding.description)
                    .foregroundColor(Color("Text"))
                    .lineSpacing(UI.Dimension.Common.lineSpacing)
                    .multilineTextAlignment(.leading)
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Onboarding.textHorizontalPadding,
                bottom: 0,
                trailing: UI.Dimension.Onboarding.textHorizontalPadding
            ))
            Spacer()
            HStack(alignment: .center) {
                if step == .step3 {
                    UI.Image.Onboarding.step(step: step, colorScheme)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    UI.Image.Onboarding.step(step: step, colorScheme)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(0)
            Spacer()
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView(step: .step1)
    }
}
