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
    var notificationIsReadUpdateBuffer: [UUID] = []
}
