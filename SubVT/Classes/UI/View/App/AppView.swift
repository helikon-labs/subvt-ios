//
//  ContentView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import SwiftUI
import CoreData

struct AppView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        if Settings.hasOnboarded {
            IntroductionView()
        } else {
            IntroductionView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView().environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
    }
}