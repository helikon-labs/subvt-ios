//
//  View.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.07.2022.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
