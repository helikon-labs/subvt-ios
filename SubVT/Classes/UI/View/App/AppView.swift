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
    @Environment(\.scenePhase) private var scenePhase
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
    @AppStorage(AppStorageKey.onekvNominators) private var onekvNominators: [UInt64:[String]] = [:]
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @StateObject private var viewModel = AppViewModel()
    
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
        .onAppear() {
            self.viewModel.initReportServices(networks: self.networks ?? [])
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                for network in self.networks ?? [] {
                    self.viewModel.fetchOneKVNominatorsForNetwork(network) {
                        nominators in
                        self.onekvNominators[network.id] = nominators
                    }
                }
            default:
                break
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
