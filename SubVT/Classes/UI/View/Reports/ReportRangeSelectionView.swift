//
//  ReportRangeSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.11.2022.
//

import SwiftUI

struct ReportRangeSelectionView: View {
    @StateObject private var viewModel = ReportRangeSelectionViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct ReportRangeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ReportRangeSelectionView()
    }
}
