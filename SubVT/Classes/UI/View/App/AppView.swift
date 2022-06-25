//
//  ContentView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import SwiftUI
import CoreData

struct AppView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Item.timestamp,
            ascending: true
        )],
        animation: .default
    )
    private var items: FetchedResults<Item>
    
    
    var body: some View {
        ZStack {
            Color("Bg").ignoresSafeArea()
            switch self.appState.stage {
            case .introduction:
                IntroductionView()
                    .environmentObject(self.appState)
            case .onboarding:
                OnboardingParentView()
                    .environmentObject(self.appState)
            case .networkSelection:
                NetworkSelectionView()
                    .environmentObject(self.appState)
            case .home:
                HomeView()
                    .environmentObject(self.appState)
            }
        }
        .animation(nil, value: self.appState.stage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environmentObject(AppState())
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}
