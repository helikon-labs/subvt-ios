//
//  AppState.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 23.01.2023.
//

import Foundation

final class AppState : ObservableObject {
    @Published var currentTab: Tab = .network
}
