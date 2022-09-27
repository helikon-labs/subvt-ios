//
//  ValidatorSeachSummary.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.09.2022.
//

import SubVTData

extension ValidatorSearchSummary {
    func hasIdentity() -> Bool {
        return self.display != nil || self.parentDisplay != nil
    }
    
    var identityDisplay: String {
        get {
            if let parentDisplay = self.parentDisplay,
               let childDisplay = self.childDisplay {
                return "\(parentDisplay) / \(childDisplay)"
            } else if let display = self.display {
                return display
            } else {
                return truncateAddress(self.address)
            }
        }
    }
    
    func compare(
        sortOption: ValidatorListViewModel.SortOption,
        _ other: ValidatorSummary
    ) -> Bool {
        if !self.hasIdentity() {
            if other.hasIdentity() {
                return false
            } else {
                return self.address.compare(other.address) == .orderedAscending
            }
        } else {
            if other.hasIdentity() {
                return self.identityDisplay.uppercased().compare(
                    other.identityDisplay.uppercased()
                ) == .orderedAscending
            } else {
                return true
            }
        }
    }
}
