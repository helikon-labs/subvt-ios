//
//  MyValidatorsView.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import SwiftUI
import SubVTData

struct MyValidatorsView: View {
    @AppStorage(WatchAppStorageKey.networks) private var networks: [Network]? = nil
    @StateObject private var viewModel = MyValidatorsViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
        }
        .onAppear() {
            if self.viewModel.fetchState == .idle {
                self.viewModel.initReportServices(networks: self.networks ?? [])
                self.viewModel.fetchMyValidators()
            }
        }
    }
}
