//
//  WSRPCStatusIndicatorView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 26.07.2022.
//

import Combine
import SubVTData
import SwiftUI

struct WSRPCStatusIndicatorView: View {
    var status: RPCSubscriptionServiceStatus
    @State var pulseSize: CGFloat
    @State var pulseOpacity: Double = 0.8
    
    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(pulseSize, pulseOpacity) }
        set {
            self.pulseSize = newValue.first
            self.pulseOpacity = newValue.second
        }
    }
    let size: CGFloat
    
    var pulseIsVisible: Bool {
        switch self.status {
        case .subscribed:
            return true
        default:
            return false
        }
    }
    
    init(
        status: RPCSubscriptionServiceStatus,
        size: CGFloat
    ) {
        self.status = status
        self.size = size
        self.pulseSize = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(
                    width: self.pulseSize,
                    height: self.pulseSize
                )
                .foregroundColor(self.status.color)
                .opacity(self.pulseIsVisible ? self.pulseOpacity : 0.0)
            // status
            switch self.status {
            case .subscribed:
                Circle()
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                    .foregroundColor(self.status.color)
            default:
                Circle()
                    .frame(
                        width: self.size,
                        height: self.size
                    )
                    .foregroundColor(self.status.color)
            }
        }
        .frame(
            width: self.size,
            height: self.size
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    self.pulseSize = self.size * 3.0
                    self.pulseOpacity = 0.0
                }
            }
        }
    }
}
