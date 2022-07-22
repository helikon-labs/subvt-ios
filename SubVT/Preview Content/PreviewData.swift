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
    
    static let validatorSummary = ValidatorSummary(
        accountId: AccountId(
            hex: "0xDC89C6865C029C1088FB27B41C1A715B0BB611B94E1D625FA0BB8A1294187454"
        ),
        address: "HZUyowqk6wH6o8B4Asf7P7hLuRXy8hPheNCKevN5QFFRRdd",
        controllerAccountId: AccountId(
            hex: "0xC4F34F45D16DA9B285984A37A9FE72C7DB4A96E267B9A5313BE5DEC1A0843352"
        ),
        display: "Display",
        parentDisplay: "Parent",
        childDisplay: "Child",
        confirmed: true,
        preferences: ValidatorPreferences(
            commissionPerBillion: 0,
            blocksNominations: true
        ),
        selfStake: StakeSummary(
            stashAccountId: AccountId(
                hex: "0xDC89C6865C029C1088FB27B41C1A715B0BB611B94E1D625FA0BB8A1294187454"
            ),
            activeAmount: Balance(integerLiteral: 0)
        ),
        isActive: true,
        activeNextSession: true,
        inactiveNominations: InactiveNominationsSummary(
            nominationCount: 130,
            totalAmount: Balance(integerLiteral: 47002001388000000)
        ),
        oversubscribed: true,
        slashCount: 1,
        isEnrolledIn1Kv: true,
        isParaValidator: true,
        paraId: 1000,
        returnRatePerBillion: 150000000,
        blocksAuthored: 3,
        rewardPoints: 1010,
        heartbeatReceived: true,
        validatorStake: ValidatorStakeSummary(
            selfStake: Balance(integerLiteral: 15937871000000),
            totalStake: Balance(integerLiteral: 5031267908000000),
            nominatorCount: 12
        )
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
