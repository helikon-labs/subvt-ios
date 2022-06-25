//
//  AppViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 17.06.2022.
//
import Combine

class AppState: ObservableObject {
    @Published var stage: Stage = .introduction
    
    init() {
        if let _ = Settings.getSelectedNetwork() {
            self.stage = .home
        } else if Settings.hasOnboarded {
            self.stage = .networkSelection
        } else {
            self.stage = .introduction
        }
    }
}
