//
//  ValidatorListButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

struct ValidatorListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(
                x: 0,
                y: configuration.isPressed ? 2 : 0
            )
            .animation(
                .linear(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

struct ValidatorListButtonView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    let title: LocalizedStringKey
    var count: Int
    
    private let gradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(
                    red: 0.01,
                    green: 0.9,
                    blue: 0.18,
                    opacity: 1.0
                ),
                Color(
                    red: 0.01,
                    green: 0.9,
                    blue: 0.18,
                    opacity: 1.0
                ),
                Color(
                    red: 0.23,
                    green: 0.44,
                    blue: 1.00,
                    opacity: 1.0
                )
            ]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(self.title)
                    .font(UI.Font.Common.dataPanelTitle)
                    .foregroundColor(Color("Text"))
                Spacer()
                UI.Image.NetworkStatus.arrowRight(self.colorScheme)
            }
            .padding(EdgeInsets(
                top: 0,
                leading: UI.Dimension.Common.dataPanelPadding,
                bottom: 0,
                trailing: UI.Dimension.Common.dataPanelPadding
            ))
            ZStack {
                GeometryReader { geometry in
                    let height = geometry.size.height
                    let width = geometry.size.width
                    
                    Path { path in
                        path.move(to: CGPoint(x: -5, y: height - 7))
                        path.addLine(to: CGPoint(x: width + 5, y: 7))
                    }
                    .stroke(
                        self.gradient,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineJoin: .round
                        )
                    )
                    
                    Path { path in
                        path.move(to: CGPoint(x: -5, y: height - 7))
                        path.addLine(to: CGPoint(x: width + 5, y: 7))
                    }
                    .stroke(
                        self.gradient,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineJoin: .round
                        )
                    )
                    .offset(
                        x: 0,
                        y: 7
                    )
                    .opacity(0.3)
                    .blur(radius: 4)
                }
            }
            .frame(maxHeight: .infinity)
            Text(String(self.count))
                .font(UI.Font.NetworkStatus.dataLarge)
                .foregroundColor(Color("Text"))
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.dataPanelPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.dataPanelPadding
                ))
        }
        .padding(EdgeInsets(
            top: UI.Dimension.Common.dataPanelPadding,
            leading: 0,
            bottom: UI.Dimension.Common.dataPanelPadding,
            trailing: 0
        ))
        .frame(height: UI.Dimension.NetworkStatus.validatorCountPanelHeight)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct ValidatorListButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorListButtonView(
            title: LocalizedStringKey("active_validator_list.title"),
            count: 1234
        )
    }
}
