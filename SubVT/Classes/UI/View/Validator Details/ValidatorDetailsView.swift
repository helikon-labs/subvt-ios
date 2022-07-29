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
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @StateObject private var viewModel = ValidatorDetailsViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var lastScroll: CGFloat = 0
    let validatorSummary: ValidatorSummary
    
    
    
    var identityDisplay: String {
        return self.viewModel.validatorDetails?.identityDisplay
            ?? validatorSummary.identityDisplay
    }
    
    private var identityIcon: Image? {
        if let account = self.viewModel.validatorDetails?.account {
            if let _ = account.parent?.boxed.identity?.display {
                if account.parent?.boxed.identity?.confirmed == true {
                    return Image("ParentIdentityConfirmedIcon")
                } else {
                    return Image("ParentIdentityNotConfirmedIcon")
                }
            } else if account.identity?.display != nil {
                if account.identity?.confirmed == true {
                    return Image("IdentityConfirmedIcon")
                } else {
                    return Image("IdentityNotConfirmedIcon")
                }
            }
        } else if self.validatorSummary.parentDisplay != nil {
            if self.validatorSummary.confirmed {
                return Image("ParentIdentityConfirmedIcon")
            } else {
                return Image("ParentIdentityNotConfirmedIcon")
            }
        } else if self.validatorSummary.display != nil {
            if self.validatorSummary.confirmed {
                return Image("IdentityConfirmedIcon")
            } else {
                return Image("IdentityNotConfirmedIcon")
            }
        }
        return nil
    }
    
    private func getIcon(_ name: String) -> some View {
        return Button {
            // no-op
        } label: {
            Image(name)
                .resizable()
                .frame(
                    width: UI.Dimension.ValidatorDetails.iconSize,
                    height: UI.Dimension.ValidatorDetails.iconSize
                )
        }
        .buttonStyle(PushButtonStyle())

    }
    
    private var isOneKV: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.onekvCandidateRecordId != nil
        } else {
            return self.validatorSummary.isEnrolledIn1Kv
        }
    }
    
    private var isParaValidator: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.isParaValidator
        } else {
            return self.validatorSummary.isParaValidator
        }
    }
    
    private var isActiveNextSession: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.activeNextSession
        } else {
            return self.validatorSummary.activeNextSession
        }
    }
    
    private var heartbeatReceived: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.heartbeatReceived ?? false
        } else {
            return self.validatorSummary.heartbeatReceived ?? false
        }
    }
    
    private var isOversubscribed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.oversubscribed
        } else {
            return self.validatorSummary.oversubscribed
        }
    }
    
    private var blocksNominations: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.preferences.blocksNominations
        } else {
            return self.validatorSummary.preferences.blocksNominations
        }
    }
    
    private var hasBeenSlashed: Bool {
        if let details = self.viewModel.validatorDetails {
            return details.slashCount > 0
        } else {
            return self.validatorSummary.slashCount > 0
        }
    }
    
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
                                self.viewModel.unsubscribe()
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            label: {
                                BackButtonView()
                            }
                        )
                        .buttonStyle(PushButtonStyle())
                        .modifier(PanelAppearance(1, self.displayState))
                        Spacer()
                        NetworkSelectorButtonView()
                            .modifier(PanelAppearance(2, self.displayState))
                        Button(
                            action: {
                                // add validator
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
                        .modifier(PanelAppearance(3, self.displayState))
                        Button(
                            action: {
                                // validator reports
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
                        .modifier(PanelAppearance(4, self.displayState))
                    }
                    .frame(height: UI.Dimension.ValidatorList.titleSectionHeight)
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
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(1)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.ValidatorDetails.scrollContentMarginTop)
                        IdenticonSceneView()
                            .frame(height: UI.Dimension.ValidatorDetails.identiconHeight)
                            // .background(Color.clear)
                            .modifier(PanelAppearance(5, self.displayState))
                        VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                            HStack(
                                alignment: .center,
                                spacing: UI.Dimension.ValidatorDetails.identityIconMarginRight
                            ) {
                                if let identityIcon = self.identityIcon {
                                    identityIcon
                                        .resizable()
                                        .frame(
                                            width: UI.Dimension.ValidatorDetails.identityIconSize,
                                            height: UI.Dimension.ValidatorDetails.identityIconSize
                                        )
                                }
                                Text(self.identityDisplay)
                                    .font(UI.Font.ValidatorDetails.identityDisplay)
                                    .foregroundColor(Color("Text"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .truncationMode(.middle)
                                Spacer()
                                    .frame(width: UI.Dimension.ValidatorDetails.identityIconSize / 2)
                            }
                            .modifier(PanelAppearance(6, self.displayState))
                        }
                        .padding(EdgeInsets(
                            top: 0,
                            leading: UI.Dimension.Common.padding,
                            bottom: 0,
                            trailing: UI.Dimension.Common.padding
                        ))
                    }
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
            HStack(alignment: .center) {
                if self.isOneKV {
                    self.getIcon("1KVIcon")
                }
                if self.isParaValidator {
                    self.getIcon("ParaValidatorIcon")
                }
                if self.isActiveNextSession {
                    self.getIcon("ActiveNextSessionIcon")
                }
                if self.heartbeatReceived {
                    self.getIcon("HeartbeatReceivedIcon")
                }
                if self.isOversubscribed {
                    self.getIcon("OversubscribedIcon")
                }
                if self.blocksNominations {
                    self.getIcon("BlocksNominationsIcon")
                }
                if self.blocksNominations {
                    self.getIcon("BlocksNominationsIcon")
                }
                /*
                if self.hasBeenSlashed {
                    self.getIcon("SlashedIcon")
                }
                 */
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(EdgeInsets(
                top: 0,
                leading: 0,
                bottom: UI.Dimension.ValidatorDetails.iconContainerMarginBottom,
                trailing: 0
            ))
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
                    self.viewModel.subscribeToValidatorDetails(
                        network: self.network,
                        accountId: self.validatorSummary.accountId
                    )
                }
            }
        }
    }
}

struct ValidatorDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorDetailsView(validatorSummary: PreviewData.validatorSummary)
    }
}
