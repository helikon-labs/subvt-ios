//
//  EraReportsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.11.2022.
//

import Foundation
import SubVTData

class EraReportsViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    private var network: Network = PreviewData.kusama
}
