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
    @State var animOpen = false
    
    let size: CGFloat
    private var pulseSize: CGFloat {
        size * (self.animOpen ? 3.0 : 1.0)
    }
    
    var body: some View {
        ZStack {
            // anim
            switch self.status {
            case .subscribed:
                if self.isConnected {
                    Circle()
                        .frame(
                            width: self.pulseSize,
                            height: self.pulseSize
                        )
                        .foregroundColor(self.status.color)
                        .opacity(self.animOpen ? 0 : 0.8)
                        .onAppear {
                            self.animOpen = false
                            withAnimation(
                                .easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: false)
                            ) {
                                self.animOpen = true
                            }
                        }
                }
            default:
                EmptyView()
            }
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
    }
}

struct WSRPCStatusIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        WSRPCStatusIndicatorView(
            status: .subscribed(subscriptionId: 1),
            isConnected: true,
            size: UI.Dimension.Common.connectionStatusSize.get()
        )
    }
}
