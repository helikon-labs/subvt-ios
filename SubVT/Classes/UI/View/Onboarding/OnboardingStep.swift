//
//  OnboardingStep.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2022.
//

import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case step1
    case step2
    case step3
    case step4
    
    var index: Int {
        get {
            switch self {
            case .step1:
                return 0
            case .step2:
                return 1
            case .step3:
                return 2
            case .step4:
                return 3
            }
        }
    }
    
    var nextStep: OnboardingStep {
        get {
            switch self {
            case .step1:
                return .step2
            case .step2:
                return .step3
            case .step3:
                return .step4
            case .step4:
                return .step4
            }
        }
    }
    
    var title: LocalizedStringKey {
        get {
            switch self {
            case .step1:
                return LocalizedStringKey("onboarding.step_1.title")
            case .step2:
                return LocalizedStringKey("onboarding.step_2.title")
            case .step3:
                return LocalizedStringKey("onboarding.step_3.title")
            case .step4:
                return LocalizedStringKey("onboarding.step_4.title")
            }
        }
    }
    
    var description: LocalizedStringKey {
        get {
            switch self {
            case .step1:
                return LocalizedStringKey("onboarding.step_1.description")
            case .step2:
                return LocalizedStringKey("onboarding.step_2.description")
            case .step3:
                return LocalizedStringKey("onboarding.step_3.description")
            case .step4:
                return LocalizedStringKey("onboarding.step_4.description")
            }
        }
    }
}
