//
//  Snackbar.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

struct SnackbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}

struct SnackbarView: View {
    enum SnackbarType: Equatable {
        case info
        case error(canRetry: Bool)
    }
    let message: String
    let type: SnackbarType
    let action: () -> ()
    
    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    Spacer()
                        .frame(width: UI.Dimension.Common.padding)
                    ZStack(alignment: .leading) {
                        VStack {
                            HStack {
                                Spacer()
                                    .frame(width: UI.Dimension.Common.padding)
                                Image("SnackbarExclamationIcon")
                                Spacer()
                                    .frame(width: UI.Dimension.Snackbar.messageMarginLeft)
                                Text(message)
                                    .font(UI.Font.Snackbar.message)
                                    .foregroundColor(Color("Text"))
                                    .lineSpacing(UI.Dimension.Snackbar.lineSpacing)
                                switch self.type {
                                case .info:
                                    Spacer()
                                        .frame(width: UI.Dimension.Common.padding)
                                case .error(let canRetry):
                                    Spacer()
                                    if canRetry {
                                        Text(LocalizedStringKey("common.retry"))
                                            .lineLimit(1)
                                            .font(UI.Font.Snackbar.message)
                                            .foregroundColor(Color("SnackbarAction"))
                                    } else {
                                        Text(LocalizedStringKey("common.ok"))
                                            .lineLimit(1)
                                            .font(UI.Font.Snackbar.message)
                                            .foregroundColor(Color("SnackbarAction"))
                                    }
                                    Spacer()
                                        .frame(width: UI.Dimension.Common.padding)
                                }
                            }
                        }
                        .padding(EdgeInsets(
                            top: UI.Dimension.Snackbar.verticalPadding,
                            leading: 0,
                            bottom: UI.Dimension.Snackbar.verticalPadding,
                            trailing: 0
                        ))
                    }
                    .background(Color("SnackbarBg"))
                    .cornerRadius(UI.Dimension.Common.cornerRadius)
                    Spacer()
                        .frame(width: UI.Dimension.Common.padding)
                }
                .frame(maxWidth: .infinity)
            }
        )
        .buttonStyle(SnackbarButtonStyle())
    }
}

struct SnackbarView_Previews: PreviewProvider {
    static var previews: some View {
        SnackbarView(
            message: localized("network_selection.error.network_list"),
            type: .error(canRetry: true)
        ) {
            // no-op
        }
        //.preferredColorScheme(.dark)
    }
}
