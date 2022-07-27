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
    var isConnected: Bool
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
            return isConnected
        default:
            break
        }
        return false
    }
    
    init(
        status: RPCSubscriptionServiceStatus,
        isConnected: Bool,
        size: CGFloat
    ) {
        self.status = status
        self.isConnected = isConnected
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
                    .foregroundColor(
                        self.isConnected
                        ? self.status.color
                        : Color("StatusWaiting")
                    )
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

struct WSRPCStatusIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        WSRPCStatusIndicatorView(
            status: .subscribed(subscriptionId: 1),
            isConnected: false,
            size: UI.Dimension.Common.connectionStatusSize.get()
        )
    }
}
