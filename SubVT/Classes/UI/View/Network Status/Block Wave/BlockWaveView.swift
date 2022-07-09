//
//  BlockWaveView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.07.2022.
//

import SwiftUI

struct BlockWaveView: View {
    let parameters: BlockWaveParameters
    
    var body: some View {
        ZStack {
            BlockWaveContainerView(parameters: self.parameters)
            BlockWaveContainerView(parameters: self.parameters)
            .blur(radius: 10)
            .scaleEffect(1.05)
            .opacity(0.75)
            .blendMode(.normal)
        }
    }
}

struct BlockWaveView_Previews: PreviewProvider {
    static var previews: some View {
        BlockWaveView(parameters: BlockWaveParameters(
            offset: Angle(degrees: 0),
            progress: 0.5,
            amplitude: 0.15
        ))
    }
}
