//
//  ValidatorDetailsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 27.07.2022.
//

import SubVTData
import SwiftUI

struct ValidatorDetailsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.presentationMode) private var presentationMode
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var lastScroll: CGFloat = 0
    let accountId: AccountId
    
    var body: some View {
        ZStack {
            Color("Bg")
                .ignoresSafeArea()
            BgMorphView()
                .offset(
                    x: 0,
                    y: UI.Dimension.BgMorph.yOffset(
                        displayState: self.displayState
                    )
                )
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .animation(
                    .easeOut(duration: 0.75),
                    value: self.displayState
                )
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: UI.Dimension.Common.titleMarginTop)
                    HStack(alignment: .center) {
                        Button(
                            action: {
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            label: {
                                BackButtonView()
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        Spacer()
                        NetworkSelectorButtonView()
                        Button(
                            action: {
                                
                            },
                            label: {
                                ZStack {
                                    UI.Image.ValidatorDetails.addValidatorIcon(self.colorScheme)
                                }
                                .frame(
                                    width: UI.Dimension.Common.networkSelectorHeight,
                                    height: UI.Dimension.Common.networkSelectorHeight
                                )
                                .background(Color("NetworkSelectorBg"))
                                .cornerRadius(UI.Dimension.Common.cornerRadius)
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        Button(
                            action: {
                                
                            },
                            label: {
                                ZStack {
                                    UI.Image.ValidatorDetails.validatorReportsIcon(self.colorScheme)
                                }
                                .frame(
                                    width: UI.Dimension.Common.networkSelectorHeight,
                                    height: UI.Dimension.Common.networkSelectorHeight
                                )
                                .background(Color("NetworkSelectorBg"))
                                .cornerRadius(UI.Dimension.Common.cornerRadius)
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                    }
                    .frame(height: UI.Dimension.ValidatorList.titleSectionHeight)
                    .modifier(PanelAppearance(1, self.displayState))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
                    trailing: UI.Dimension.Common.padding
                ))
            }
            .background(
                VisualEffectView(effect: UIBlurEffect(
                    style: .systemUltraThinMaterial
                ))
                .cornerRadius(
                    UI.Dimension.Common.headerBlurViewCornerRadius,
                    corners: [.bottomLeft, .bottomRight]
                )
                .opacity(self.headerMaterialOpacity)
                .modifier(PanelAppearance(
                    0,
                    self.displayState,
                    animateOffset: false
                ))
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        
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
                        self.headerMaterialOpacity = max($0, 0) / 20.0
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.displayState = .appeared
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    // fetch data
                }
            }
        }
    }
}

struct ValidatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorDetailsView(accountId: AccountId.init(
            hex: "0xA00505EB2A4607F27837F57232F0C456602E39540582685B4F58CDE293F1A116"
        ))
    }
}
