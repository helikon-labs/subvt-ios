//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import SubVTData
import SwiftUI

@main
struct SubVTApp: App {
    let persistenceController = PersistenceController.shared
    private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
}
