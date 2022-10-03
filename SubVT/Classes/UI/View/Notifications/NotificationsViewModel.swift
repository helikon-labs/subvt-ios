//
//  NotificationsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import Foundation
import SubVTData
import SwiftUI

class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [String] = []
    
    /*
     notifs enabled & setup not complete => complete setup w/ error cases + create rules
     all done & rules not created => create rules
     */
}
