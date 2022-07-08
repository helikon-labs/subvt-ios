//
//  PreviewData.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.06.2022.
//

import Foundation
import SubVTData

enum PreviewData {
    static let era = Era(
        index: 3926,
        startTimestamp: 1657214874008,
        endTimestamp: 1657236474008
    )
    
    static let kusama = Network(
        id: 1,
        hash: "0xABC",
        chain: "kusama",
        display: "Kusama",
        ss58Prefix: 1,
        tokenTicker: "KSM",
        tokenDecimalCount: 12,
        networkStatusServiceHost: nil,
        networkStatusServicePort: nil,
        reportServiceHost: nil,
        reportServicePort: nil,
        validatorDetailsServiceHost: nil,
        validatorDetailsServicePort: nil,
        activeValidatorListServiceHost: nil,
        activeValidatorListServicePort: nil,
        inactiveValidatorListServiceHost: nil,
        inactiveValidatorListServicePort: nil
    )
    
    static let userDefaults: UserDefaults = {
        let defaults = UserDefaults.init(
            suiteName: "io.helikon.subvt.user_defaults.preview"
        )!
        defaults.set(
            try! JSONEncoder().encode(PreviewData.kusama),
            forKey: AppStorageKey.selectedNetwork
        )
        defaults.synchronize()
        return defaults
    }()
}
