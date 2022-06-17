//
//  AppViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 17.06.2022.
//

import Foundation
import SubVTData

class AppState: ObservableObject {
    @Published var stage: Stage = .introduction
    @Published var network: Network!
    
    init() {
        if let network = Settings.getSelectedNetwork() {
            self.network = network
            self.stage = .home
        } else if Settings.hasOnboarded {
            self.stage = .networkSelection
        } else {
            self.stage = .introduction
        }
    }
}
