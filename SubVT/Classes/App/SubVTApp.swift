//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import SubVTData
import SwiftUI

enum CurrentView: Int {
    case introduction
    case onboarding
    case networkSelection
}

class AppData : ObservableObject {
    @Published var currentView: CurrentView = Settings.hasOnboarded
        ? .networkSelection
        : .introduction
}

@main
struct SubVTApp: App {
    let persistenceController = PersistenceController.shared
    private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appData)
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
}
