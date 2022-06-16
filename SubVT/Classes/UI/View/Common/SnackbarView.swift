//
//  Snackbar.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

struct SnackbarView: View {
    enum DisplayState: Equatable {
        case hidden
        case info
        case error(canRetry: Bool)
    }
    let message: LocalizedStringKey
    let state: DisplayState
    let action: () -> ()
    
    var bottomOffset: CGFloat {
        get {
            switch self.state {
            case .hidden:
                return 400
            case .error(_):
                fallthrough
            case .info:
                return -100
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(
                action: action,
                label: {
                    HStack {
                        Spacer()
                            .frame(width: UI.Dimension.Common.horizontalPadding)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(
                                cornerRadius: UI.Dimension.Common.cornerRadius,
                                style: .circular
                            )
                            .fill(Color("SnackbarBg"))
                            .frame(
                                maxWidth: .infinity,
                                minHeight: UI.Dimension.Snackbar.height,
                                maxHeight: UI.Dimension.Snackbar.height
                            )
                            HStack {
                                Spacer()
                                    .frame(width: UI.Dimension.Common.horizontalPadding)
                                Image("SnackbarExclamationIcon")
                                Spacer()
                                    .frame(width: 10)
                                Text(message)
                                    .lineLimit(1)
                                    .font(UI.Font.Snackbar.message)
                                    .foregroundColor(Color("Text"))
                                switch self.state {
                                case .error(let canRetry):
                                    if canRetry {
                                        Spacer()
                                        Text(LocalizedStringKey("common.retry"))
                                            .lineLimit(1)
                                            .font(UI.Font.Snackbar.action)
                                            .foregroundColor(Color("SnackbarAction"))
                                        Spacer()
                                            .frame(width: UI.Dimension.Common.horizontalPadding)
                                    }
                                default:
                                    Spacer()
                                        .frame(width: UI.Dimension.Common.horizontalPadding)
                                }
                            }
                        }
                        Spacer()
                            .frame(width: UI.Dimension.Common.horizontalPadding)
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .offset(y: self.bottomOffset)
        }
    }
}

struct SnackbarView_Previews: PreviewProvider {
    static var previews: some View {
        SnackbarView(
            message: LocalizedStringKey("error.connection"),
            state: .error(canRetry: true)
        ) {
            
        }
        //.preferredColorScheme(.dark)
    }
}
