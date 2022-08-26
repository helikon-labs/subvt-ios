//
//  Event.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.08.2022.
//

import Foundation
import SwiftEventBus
import SubVTData

enum Event: String {
    case validatorAdded = "io.subvt.event.validator_added"
    case validatorRemoved = "io.subvt.event.validator_removed"
    
    func post(_ object: Any?) {
        SwiftEventBus.post(self.rawValue, sender: object)
    }
}
