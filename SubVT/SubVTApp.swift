//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 12.01.2022.
//

import SwiftUI

@main
struct SubVTApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
