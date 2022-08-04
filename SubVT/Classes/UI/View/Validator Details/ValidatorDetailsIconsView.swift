//
//  ValidatorDetailsIconsView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 1.08.2022.
//

import SubVTData
import SwiftUI

fileprivate let tooltipTailHeight: CGFloat = 10

fileprivate struct TooltipBgShape: Shape {
    fileprivate let tailWidth: CGFloat = 16
    private let radius: CGFloat = 10
    private let tailSize: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            path.addLine(to: CGPoint(
                x: rect.minX + rect.width / 2 + tailWidth / 2,
                y: rect.maxY
            ))
            path.addLine(to: CGPoint(
                x: rect.minX + rect.width / 2,
                y: rect.maxY + tooltipTailHeight
            ))
            path.addLine(to: CGPoint(
                x: rect.minX + rect.width / 2 - tailWidth / 2,
                y: rect.maxY
            ))
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
        }
    }
}

enum ValidatorDetailsIcon: Equatable, Identifiable {
    case onekv
    case paravalidator
    case activeNextSession
    case heartbeatReceived
    case oversubscribed
    case blocksNominations
    case slashed
    
    var id: Self { self }
    
    var tooltip: String {
        switch self {
        case .onekv:
            return localized("validator_details.tooltip.onekv")
        case .paravalidator:
            return localized("validator_details.tooltip.paravalidator")
        case .activeNextSession:
            return localized("validator_details.tooltip.active_next_session")
        case .heartbeatReceived:
            return localized("validator_details.tooltip.heartbeat_received")
        case .oversubscribed:
            return localized("validator_details.tooltip.oversubscribed")
        case .blocksNominations:
            return localized("validator_details.tooltip.blocks_nominations")
        case .slashed:
            return localized("validator_details.tooltip.slashed")
        }
    }
    
    var image: Image {
        switch self {
        case .onekv:
            return Image("1KVIcon")
        case .paravalidator:
            return Image("ParaValidatorIcon")
        case .activeNextSession:
            return Image("ActiveNextSessionIcon")
        case .heartbeatReceived:
            return Image("HeartbeatReceivedIcon")
        case .oversubscribed:
            return Image("OversubscribedIcon")
        case .blocksNominations:
            return Image("BlocksNominationsIcon")
        case .slashed:
            return Image("SlashedIcon")
        }
    }
}

fileprivate struct ValidatorDetailsIconView: View {
    @Binding var selectedIcon: ValidatorDetailsIcon?
    let icon: ValidatorDetailsIcon
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedIcon == self.icon {
                Text(self.icon.tooltip)
                    .lineLimit(1)
                    .font(UI.Font.Common.tooltip)
                    .foregroundColor(Color("Text"))
                    .padding(EdgeInsets(
                        top: 10,
                        leading: 14,
                        bottom: 10,
                        trailing: 14
                    ))
                    .background(
                        TooltipBgShape()
                            .foregroundColor(Color("Bg"))
                            .shadow(
                                color: Color("TooltipShadow").opacity(0.2),
                                radius: 19,
                                x: 0,
                                y: 0
                            )
                    )
                Spacer()
                    .frame(height: tooltipTailHeight + 6)
            }
            Button {
                if self.selectedIcon == self.icon {
                    self.selectedIcon = nil
                } else {
                    self.selectedIcon = self.icon
                }
            } label: {
                self.icon.image
                    .resizable()
                    .frame(
                        width: UI.Dimension.ValidatorDetails.iconSize,
                        height: UI.Dimension.ValidatorDetails.iconSize
                    )
            }
            .buttonStyle(PushButtonStyle())
        }
    }
}

struct ValidatorDetailsIconsView: View {
    @State private var selectedIcon: ValidatorDetailsIcon? = nil
    let icons: [ValidatorDetailsIcon]
    
    init(icons: [ValidatorDetailsIcon]) {
        self.icons = icons
    }
    
    init(validatorDetails details: ValidatorDetails) {
        var icons = [ValidatorDetailsIcon]()
        if details.onekvCandidateRecordId != nil {
            icons.append(.onekv)
        }
        if details.isParaValidator {
            icons.append(.paravalidator)
        }
        if details.activeNextSession {
            icons.append(.activeNextSession)
        }
        if details.heartbeatReceived ?? false {
            icons.append(.heartbeatReceived)
        }
        if details.oversubscribed {
            icons.append(.oversubscribed)
        }
        if details.preferences.blocksNominations {
            icons.append(.blocksNominations)
        }
        if details.slashCount > 0 {
            icons.append(.slashed)
        }
        self.icons = icons
    }
    
    init(validatorSummary summary: ValidatorSummary) {
        var icons = [ValidatorDetailsIcon]()
        if summary.isEnrolledIn1Kv {
            icons.append(.onekv)
        }
        if summary.isParaValidator {
            icons.append(.paravalidator)
        }
        if summary.activeNextSession {
            icons.append(.activeNextSession)
        }
        if summary.heartbeatReceived ?? false {
            icons.append(.heartbeatReceived)
        }
        if summary.oversubscribed {
            icons.append(.oversubscribed)
        }
        if summary.preferences.blocksNominations {
            icons.append(.blocksNominations)
        }
        if summary.slashCount > 0 {
            icons.append(.slashed)
        }
        self.icons = icons
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                ForEach(self.icons.indices, id: \.self) { index in
                    ValidatorDetailsIconView(
                        selectedIcon: self.$selectedIcon,
                        icon: self.icons[index]
                    )
                        .offset(
                            x: CGFloat(index) * 50,
                            y: 0
                        )
                }
            }
            .offset(
                x: CGFloat(-self.icons.count * 25) + 25,
                y: 0
            )
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct ValidatorDetailsIconsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ValidatorDetailsIconsView(icons: [
                .onekv,
                .paravalidator,
                .activeNextSession,
                .heartbeatReceived,
                .oversubscribed,
                .blocksNominations,
                .slashed
            ])
        }
    }
}
