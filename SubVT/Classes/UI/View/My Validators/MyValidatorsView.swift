//
//  MyValidatorsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 5.08.2022.
//

import SwiftUI

struct MyValidatorsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @State private var headerMaterialOpacity = 0.0
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                HStack(alignment: .top, spacing: 0) {
                    Text(localized("my_validators.title"))
                        .font(UI.Font.Common.tabViewTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(
                            width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft.get()
                        )
                    WSRPCStatusIndicatorView(
                        status: .subscribed(subscriptionId: 1),
                        isConnected: true,
                        size: UI.Dimension.Common.connectionStatusSize.get()
                    )
                    //.modifier(PanelAppearance(5, self.displayState))
                }
                Spacer()
            }
            .frame(height: UI.Dimension.Common.networkSelectorHeight)
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
        .background(
            VisualEffectView(effect: UIBlurEffect(
                style: .systemUltraThinMaterial
            ))
            .cornerRadius(
                UI.Dimension.Common.headerBlurViewCornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
            .opacity(self.headerMaterialOpacity)
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            headerView
                .zIndex(2)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.Common.contentAfterTitleMarginTop)
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                    .background(GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                    })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        self.headerMaterialOpacity = min(max($0, 0) / 40.0, 1.0)
                    }
                }
            }
            .zIndex(0)
            FooterGradientView()
                .zIndex(1)
        }
        .navigationBarHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                break
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                fatalError("Unknown scene phase: \(scenePhase)")
            }
        }
    }
}

struct MyValidatorsView_Previews: PreviewProvider {
    static var previews: some View {
        MyValidatorsView()
    }
}
