//
//  File.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.07.2022.
//

import SubVTData

extension ValidatorSummary {
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
}
