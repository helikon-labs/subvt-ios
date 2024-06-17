//
//  ContentView.swift
//  SubVT Watch Watch App
//
//  Created by Kutsal Kaan Bilgin on 11.02.2024.
//
import SwiftUI
import SubVTData

struct WatchAppView: View {
    @AppStorage(WatchAppStorageKey.hasBeenOnboarded) private var hasBeenOnboarded = false
    
    var body: some View {
        ZStack {
            Color("Bg").ignoresSafeArea()
            if !self.hasBeenOnboarded {
                OnboardingView()
            } else {
                HomeView()
            }
        }
    }
}

#Preview {
    WatchAppView()
}
