//
//  SubVTApp.swift
//  SubVTWatch WatchKit Extension
//
//  Created by Kutsal Kaan Bilgin on 26.07.2022.
//

import SwiftUI

@main
struct SubVTApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
