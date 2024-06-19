//
//  File.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.07.2022.
//

import SubVTData

extension ValidatorSummary {
    enum SortOption: String {
        case identity
        case stakeDescending
        case nominationDescending
    }
    
    enum FilterOption: String {
        case hasIdentity
        case isOneKV
        case isParavalidator
    }
    
    func filter(_ filter: String) -> Bool {
        if filter.isEmpty {
            return true
        }
        let fullText = (self.display ?? "")
            + (self.parentDisplay ?? "")
            + (self.childDisplay ?? "")
            + self.address
        return fullText.lowercased().contains(filter.lowercased())
    }
    
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
        sortOption: SortOption,
        _ other: ValidatorSummary
    ) -> Bool {
        let zeroBalance = Balance(integerLiteral: 0).value
        if self.networkId != other.networkId {
            return self.networkId < other.networkId
        }
        switch sortOption {
        case .identity:
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
        case .stakeDescending:
            let thisBalance = self.validatorStake?.totalStake.value ?? zeroBalance
            let otherBalance = other.validatorStake?.totalStake.value ?? zeroBalance
            return thisBalance > otherBalance
        case .nominationDescending:
            let thisNomination = self.inactiveNominations.totalAmount.value
            let otherNomination = other.inactiveNominations.totalAmount.value
            return thisNomination > otherNomination
        }
    }
}
