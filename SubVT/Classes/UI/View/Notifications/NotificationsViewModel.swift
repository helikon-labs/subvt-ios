//
//  NotificationsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import Foundation
import SubVTData

class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [String] = []
}
