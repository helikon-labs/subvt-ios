//
//  Router.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.01.2023.
//

import Combine
import SubVTData
import SwiftUI

enum Screen: Hashable {
    case income
    case myValidators
    case networkStatus
    
    @ViewBuilder
    func build() -> some View {
        switch self {
        case .income:
            IncomeView()
        case .myValidators:
            MyValidatorsView()
        case .networkStatus:
            NetworkStatusView()
        }
    }
}

final class Router : ObservableObject {
    @Published var path: [Screen] = []
    
    func popToRoot() {
        self.path = []
    }
    
    func push(screen: Screen) {
        self.path.append(screen)
    }
    
    func back() {
        self.path.removeLast()
    }
}
