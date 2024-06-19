//
//  PreviewData.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import SubVTData

enum PreviewData {
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
}
