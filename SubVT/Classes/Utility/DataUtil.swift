//
//  DataUtility.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.11.2022.
//

import CoreData
import Foundation
import SwiftUI

struct DataUtil {
    static func updateAppNotificationBadge(context: NSManagedObjectContext) {
        do {
            let fetchRequest : NSFetchRequest<Notification> = Notification.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "isRead == %@",
                NSNumber(value: false)
            )
            let count = try context.count(for: fetchRequest)
            UIApplication.shared.applicationIconBadgeNumber = count
        } catch {
            log.error("Error while updating app badge: \(error)")
        }
    }
}
