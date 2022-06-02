//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import SwiftUI

@main
struct SubVTApp: App {
    let persistenceController = PersistenceController.shared
    
    init () {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
