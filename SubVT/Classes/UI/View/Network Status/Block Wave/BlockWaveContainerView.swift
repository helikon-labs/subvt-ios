//
//  BlockWaveContainerView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.07.2022.
//

import SwiftUI

struct BlockWaveContainerView: View {
    let parameters: BlockWaveParameters
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.clear,
                    lineWidth: 1
                )
                .background(Color("BlockWaveViewBg").clipShape(Circle()))
                .overlay(
                    BlockWaveShape(parameters: self.parameters)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color("StatusActive"),
                                    Color("StatusActive"),
                                    Color("Progress")
                                ]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Circle())
                )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct BlockWaveContainerView_Previews: PreviewProvider {
    static var previews: some View {
        BlockWaveContainerView(parameters: BlockWaveParameters(
            offset: Angle(degrees: 0),
            progress: 0.5,
            amplitude: 0.15
        ))
    }
}
