//
//  BgMorphView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

struct BgMorphView: View {
    var body: some View {
        GeometryReader { geometry in
            let blueWidth = geometry.size.width * 0.85
            let blueHeight = geometry.size.height * 0.58
            let grayWidth = geometry.size.width * 0.56
            let grayHeight = geometry.size.height * 0.51
            let greenWidth = geometry.size.width * 0.98
            let greenHeight = geometry.size.height * 0.58
            ZStack {
                Ellipse()
                    .fill(Color(0x2AFB4D))
                    .blur(radius: 50)
                    .rotationEffect(.degrees(-13.6))
                    .frame(
                        width: greenWidth,
                        height: greenHeight
                    )
                    .offset(x: 170, y: -120)
                Ellipse()
                    .fill(Color(0xF5F5F5))
                    .blur(radius: 84)
                    .transformEffect(__CGAffineTransformMake(
                        1,
                        0.72,
                        -0.03,
                        0.86,
                        0,
                        0
                    ))
                    .frame(
                        width: grayWidth,
                        height: grayHeight
                    )
                    .offset(x: 0, y: -220)
                Ellipse()
                    .fill(Color(0x3B6EFF))
                    .blur(radius: 74)
                    .rotationEffect(.degrees(15))
                    .frame(
                        width: blueWidth,
                        height: blueHeight
                    )
                    .offset(x: -100, y: -120)
            }
            
        }
    }
}

struct BgMorphView_Previews: PreviewProvider {
    static var previews: some View {
        BgMorphView()
    }
}
