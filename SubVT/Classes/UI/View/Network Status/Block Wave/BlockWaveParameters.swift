//
//  BlockWaveParameters.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.07.2022.
//

import SwiftUI

fileprivate let maxAmplitude = 0.25

struct BlockWaveParameters {
    let offset: Angle
    let progress: Double
    let amplitude: Double
    
    init(
        offset: Angle,
        progress: Double,
        amplitude: Double
    ) {
        self.offset = offset
        self.progress = min(1.0, progress)
        self.amplitude = min(maxAmplitude, amplitude)
    }
}
