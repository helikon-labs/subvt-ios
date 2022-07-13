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
    let count: Int
    let eraValidatorCounts: [(UInt, UInt)]
    let chartRevealPercentage: CGFloat
    
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
    
    private var chartDataPoints: [(Int, Int)] {
        get {
            self.eraValidatorCounts.map { (index, count) in
                (Int(index), Int(count))
            }
        }
    }
    
    private var minValidatorCount: Int {
        get {
            let min = self.eraValidatorCounts.min(by: { p1, p2 in
                return p1.1 < p2.1
            })?.1 ?? 0
            return Int(min)
        }
    }
    
    private var maxValidatorCount: Int {
        get {
            let min = self.eraValidatorCounts.max(by: { p1, p2 in
                return p1.1 < p2.1
            })?.1 ?? 0
            return Int(min)
        }
    }
    
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
            LineChartView(
                dataPoints: self.chartDataPoints,
                chartMinY: self.minValidatorCount - 10,
                chartMaxY: self.maxValidatorCount + 10,
                revealPercentage: self.chartRevealPercentage
            )
            .padding(EdgeInsets(
                top: 0,
                leading: 4,
                bottom: 0,
                trailing: 4
            ))
            Text(String(self.count))
                .modifier(Counter(
                    format: "%d",
                    value: CGFloat(self.count)
                ))
                .animation(
                    .easeInOut(duration: UI.Duration.counterAnimation),
                    value: self.count
                )
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
        .frame(height: UI.Dimension.NetworkStatus.validatorCountPanelHeight.get())
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}

struct ValidatorListButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ValidatorListButtonView(
            title: LocalizedStringKey("active_validator_list.title"),
            count: 1234,
            eraValidatorCounts: [
                (0, 900),
                (1, 1000),
                (2, 1002),
                (3, 1004),
                (4, 982),
                (5, 990),
                (6, 1010),
                (7, 1050),
                (8, 1045),
                (9, 965)
            ],
            chartRevealPercentage: 1.0
        )
    }
}
