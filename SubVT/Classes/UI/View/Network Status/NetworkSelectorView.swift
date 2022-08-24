//
//  NetworkSelectorView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 19.08.2022.
//

import SubVTData
import SwiftUI

struct NetworkSelectorView: View {
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @AppStorage(AppStorageKey.selectedNetwork) private var network: Network = PreviewData.kusama
    @Binding var isOpen: Bool
    let serviceStatus: RPCSubscriptionServiceStatus
    let serviceIsConnected: Bool
    let onChangeNetwork: (Network) -> ()
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                HStack(alignment: .top, spacing: 0) {
                    Text(localized("network_status.title"))
                        .font(UI.Font.Common.tabViewTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(
                            width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft.get()
                        )
                    WSRPCStatusIndicatorView(
                        status: self.serviceStatus,
                        isConnected: self.serviceIsConnected,
                        size: UI.Dimension.Common.connectionStatusSize.get()
                    )
                    //.modifier(PanelAppearance(5, self.displayState))
                }
                Spacer()
                Button(
                    action: {
                        self.isOpen = false
                    },
                    label: {
                        NetworkSelectorButtonView(
                            network: self.network,
                            displayType: .selector(isOpen: true)
                        )
                    }
                )
                .buttonStyle(NetworkSelectorButtonStyle())
            }
            Spacer()
                .frame(height: UI.Dimension.NetworkStatus.networkListMarginTop.get())
            if let networks = self.networks {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        ForEach(networks.indices, id: \.self) { i in
                            Button(
                                action: {
                                    if networks[i].id != self.network.id {
                                        self.network = networks[i]
                                        self.onChangeNetwork(self.network)
                                        /*
                                        UserDefaults(
                                            suiteName: "io.helikon.subvt.user_defaults"
                                        )!.synchronize()
                                         */
                                    }
                                },
                                label: {
                                    HStack(alignment: .center, spacing: 0) {
                                        Spacer()
                                            .frame(width: 12)
                                        UI.Image.Common.networkIcon(
                                            network: networks[i]
                                        )
                                        .resizable()
                                        .frame(
                                            width: UI.Dimension.NetworkStatus.networkListIconSize,
                                            height: UI.Dimension.NetworkStatus.networkListIconSize
                                        )
                                        Spacer()
                                            .frame(width: 16)
                                        Text(networks[i].display)
                                            .font(UI.Font.NetworkStatus.networkSelectorList)
                                            .foregroundColor(Color("Text"))
                                        Spacer()
                                        if self.network.id == networks[i].id {
                                            Circle()
                                                .fill(Color("NetworkButtonSelectionIndicator"))
                                                .frame(
                                                    width: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize,
                                                    height: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize
                                                )
                                                .shadow(
                                                    color: Color("NetworkButtonSelectionIndicator"),
                                                    radius: 3,
                                                    x: 0,
                                                    y: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize / 2
                                                )
                                            Spacer()
                                                .frame(width: 24)
                                        }
                                    }
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            )
                            .zIndex(100 - Double(i))
                            if i < networks.count - 1 {
                                Color("NetworkSelectorListDivider")
                                    .frame(height: 1)
                            }
                        }
                    }
                    .background(Color("NetworkSelectorOpenBg"))
                    .cornerRadius(UI.Dimension.Common.cornerRadius)
                    .frame(width: 175, alignment: .leading)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
        .background(Color("Bg").opacity(0.9))
        .onAppear {
            print("\(self.networks?.count ?? 0) networks")
        }
        .onTapGesture {
            self.isOpen = false
        }
    }
}

struct NetworkSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectorView(
            isOpen: .constant(true),
            serviceStatus: .subscribed(subscriptionId: 4),
            serviceIsConnected: true
        ) { _ in }
    }
}
