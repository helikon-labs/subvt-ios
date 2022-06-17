//
//  BgMorphView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

struct BgMorphView: View {
    enum Step {
        case start
        case mid
        case end
        
        var next: Step {
            switch self {
            case .start:
                return .mid
            case .mid:
                return .end
            case .end:
                return .start
            }
        }
    }
    
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    @State var step: Step = .start
    
    let timer = Timer.publish(
        every: 4,
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let leftViewSize = UI.Dimension.BgMorph.getLeftViewSize(
                colorScheme: colorScheme,
                geometry: geometry,
                step: step
            )
            let leftViewOffset = UI.Dimension.BgMorph.getLeftViewOffset(
                colorScheme: colorScheme,
                geometry: geometry,
                step: step
            )
            let middleViewSize = UI.Dimension.BgMorph.getMiddleViewSize(
                geometry: geometry
            )
            let middleViewOffset = UI.Dimension.BgMorph.getMiddleViewOffset(
                geometry: geometry,
                step: step
            )
            let rightViewSize = UI.Dimension.BgMorph.getRightViewSize(
                geometry: geometry
            )
            let rightViewOffset = UI.Dimension.BgMorph.getRightViewOffset(
                geometry: geometry,
                step: step
            )
            ZStack(alignment: .leading) {
                Ellipse()
                    .fill(Color("BgMorphLeftView"))
                    .blur(radius: UI.Dimension.BgMorph.leftViewBlurRadius)
                    .frame(
                        width: leftViewSize.0,
                        height: leftViewSize.1
                    )
                    .transformEffect(
                        UI.Dimension.BgMorph.getLeftViewTransform(
                            colorScheme: colorScheme
                        )
                    )
                    .rotationEffect(.degrees(
                        UI.Dimension.BgMorph.leftViewRotation(
                            colorScheme: self.colorScheme,
                            step: self.step
                        )
                    ))
                    .position(
                        x: leftViewSize.0 / 2 + leftViewOffset.0,
                        y: leftViewSize.1 / 2 + leftViewOffset.1
                    )
                if colorScheme == .dark {
                    Ellipse()
                        .fill(Color("BgMorphMiddleView"))
                        .blur(radius: UI.Dimension.BgMorph.middleViewBlurRadius)
                        .frame(
                            width: middleViewSize.0,
                            height: middleViewSize.1
                        )
                        .transformEffect(
                            UI.Dimension.BgMorph.getMiddleViewTransform(
                                colorScheme: colorScheme
                            )
                        )
                        .position(
                            x: middleViewSize.0 / 2 + middleViewOffset.0,
                            y: middleViewSize.1 / 2 + middleViewOffset.1
                        )
                }
                Ellipse()
                    .fill(Color("BgMorphRightView"))
                    .blur(radius: UI.Dimension.BgMorph.rightViewBlurRadius)
                    .frame(
                        width: rightViewSize.0,
                        height: rightViewSize.1
                    )
                    .transformEffect(
                        UI.Dimension.BgMorph.getRightViewTransform(
                            colorScheme: colorScheme
                        )
                    )
                    .rotationEffect(.degrees(UI.Dimension.BgMorph.rightViewRotation))
                    .position(
                        x: rightViewSize.0 / 2 + rightViewOffset.0,
                        y: rightViewSize.1 / 2 + rightViewOffset.1
                    )
            }
            .animation(
                .easeInOut(duration: 3.5),
                value: self.step
            )
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                self.step = self.step.next
            }
            .onAppear() {
                DispatchQueue.main.async() {
                    self.step = self.step.next
                }
            }
        }
    }
}

struct BgMorphView_Previews: PreviewProvider {
    static var previews: some View {
        BgMorphView()
    }
}
