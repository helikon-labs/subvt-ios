//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import Combine
import SubVTData
import SwiftUI

@main
struct SubVTApp: App {
    let persistenceController = PersistenceController.shared
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        let service = ReportService()
        let publisher = service.getEraReport(startEraIndex: 3391)
        publisher
            .sink { (response) in
                if response.error != nil {
                    print("Service call error: \(response.error!)")
                } else {
                    print("Service call success: \(response.value!)")
                }
            }
            .store(in: &cancellables)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
