//
//  ContentView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import CoreData
import SubVTData
import SwiftUI

struct AppView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Item.timestamp,
            ascending: true
        )],
        animation: .default
    )
    private var items: FetchedResults<Item>
    @AppStorage(AppStorageKey.hasCompletedIntroduction) private var hasCompletedIntroduction = false
    @AppStorage(AppStorageKey.hasBeenOnboarded) private var hasBeenOnboarded = false
    @AppStorage(AppStorageKey.selectedNetwork) private var selectedNetwork: Network? = nil
    
    var body: some View {
        ZStack {
            Color("Bg").ignoresSafeArea()
            if !hasCompletedIntroduction {
                IntroductionView()
            } else if !hasBeenOnboarded {
                OnboardingParentView()
            } else if selectedNetwork == nil {
                NetworkSelectionView()
            } else {
                HomeView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}
