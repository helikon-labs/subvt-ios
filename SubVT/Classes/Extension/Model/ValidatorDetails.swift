//
//  ValidatorDetails.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 28.07.2022.
//

import SubVTData

extension ValidatorDetails {
    var identityDisplay: String {
        get {
            if let parentDisplay = self.account.parent?.boxed.identity?.display,
               let childDisplay = self.account.childDisplay {
                return "\(parentDisplay) / \(childDisplay)"
            } else if let display = self.account.identity?.display {
                return display
            } else {
                return truncateAddress(self.account.address)
            }
        }
    }
}
