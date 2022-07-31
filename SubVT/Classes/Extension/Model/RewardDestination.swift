//
//  RewardDestination.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 31.07.2022.
//

import Foundation
import SubVTData

extension RewardDestination {
    public func getDisplay(ss58Prefix: UInt16) -> String {
        switch self.destinationType {
        case .account:
            if let accountId = self.destination,
               let address = try? accountId.toSS58Check(prefix: ss58Prefix) {
                return truncateAddress(address)
            } else {
                return "-"
            }
        case .controller:
            return localized("reward_destination.controller")
        case .none:
            return localized("reward_destination.none")
        case .staked:
            return localized("reward_destination.staked")
        case .stash:
            return localized("reward_destination.stash")
        }
    }
}
