//
//  HomeViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import Combine
import Foundation
import SubVTData

class HomeViewModel: ObservableObject {
    
    func initWatch() {
        if !UserDefaultsUtil.shared.bool(forKey: AppStorageKey.watchInitialized) {
            var data: [String: Any] = [:]
            data[WatchAppStorageKey.hasBeenOnboarded] = true
            data[WatchAppStorageKey.privateKey] = KeychainStorage.shared.getPrivateKeyData()
            DispatchQueue.main.async {
                WatchConnectivityUtil.send(
                    data: data,
                    priority: .applicationContext
                )
            }
        }
    }
}
