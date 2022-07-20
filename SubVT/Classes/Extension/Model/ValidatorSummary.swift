//
//  File.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.07.2022.
//

import SubVTData

extension ValidatorSummary {
    func filter(ss58Prefix: UInt16, _ filter: String) -> Bool {
        if filter.isEmpty {
            return true
        }
        let fullText = (self.display ?? "")
            + (self.parentDisplay ?? "")
            + (self.childDisplay ?? "")
            //+ ((try? self.accountId.toSS58Check(prefix: ss58Prefix)) ?? "")
        return fullText.lowercased().contains(filter.lowercased())
    }
}
