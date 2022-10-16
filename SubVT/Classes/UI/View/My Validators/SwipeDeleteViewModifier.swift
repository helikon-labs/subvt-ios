//
//  Delete.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 26.08.2022.
//

import SubVTData
import SwiftUI

struct SwipeDeleteViewModifier: ViewModifier {
    let halfDeletionDistance = CGFloat(50)
    let tappableDeletionWidth = CGFloat(100)
    
    @State private var offset: CGSize = .zero
    @State private var initialOffset: CGSize = .zero
    @State private var contentWidth: CGFloat = .zero
    @State private var trashIconOpacity: Double = .zero
    
    let action: () -> Void
   
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.clear)
                            .cornerRadius(16)
                        Button {
                            self.delete()
                        } label: {
                            Image("TrashIcon")
                                .opacity(self.trashIconOpacity)
                        }
                        .buttonStyle(PushButtonStyle())
                    }
                    .frame(width: -self.offset.width)
                    .clipped()
                    .offset(x: geometry.size.width)
                    .onAppear {
                        self.contentWidth = geometry.size.width
                    }
                }
            )
            .offset(x: self.offset.width, y: 0)
            .gesture (
                /*
                 minimumDistance is utilized to avoid interference with navigation view's
                 swipe-left gesture.
                 */
                DragGesture(minimumDistance: 20)
                    .onChanged { gesture in
                        if gesture.translation.width + self.initialOffset.width <= 0 {
                            self.offset.width = max(
                                gesture.translation.width + self.initialOffset.width,
                                -self.tappableDeletionWidth
                            )
                            self.trashIconOpacity = min(
                                1.0,
                                -self.offset.width / self.tappableDeletionWidth
                            )
                        }
                    }
                    .onEnded { _ in
                        if self.offset.width < -self.halfDeletionDistance {
                            self.offset.width = -self.tappableDeletionWidth
                            self.initialOffset.width = -self.tappableDeletionWidth
                            self.trashIconOpacity = 1.0
                        } else {
                            self.offset = .zero
                            self.initialOffset = .zero
                            self.trashIconOpacity = .zero
                        }
                    }
            )
            .animation(.interactiveSpring(), value: self.offset)
    }
    
    private func delete() {
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.offset = .zero
            self.initialOffset = .zero
            self.trashIconOpacity = .zero
        }
    }
}
