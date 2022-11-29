//
//  BarChartView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 28.11.2022.
//

import SwiftUI

struct BarChartView: View {
    private let dataPoints: [(Double, Double)]
    private let minX: Double
    private let maxX: Double
    private let chartMinY: Double
    private let chartMaxY: Double
    private let revealPercentage: CGFloat
    
    init(
        dataPoints: [(Double, Double)],
        chartMinY: Double,
        chartMaxY: Double,
        revealPercentage: CGFloat
    ) {
        self.dataPoints = dataPoints.sorted { pair1, pair2 in
            pair1.0 < pair2.0
        }
        self.minX = self.dataPoints.first?.0 ?? 0
        self.maxX = self.dataPoints.last?.0 ?? 0
        self.chartMinY = chartMinY
        self.chartMaxY = chartMaxY
        self.revealPercentage = revealPercentage
    }
    
    init(
        dataPoints: [(Int, Int)],
        chartMinY: Int,
        chartMaxY: Int,
        revealPercentage: CGFloat
    ) {
        self.dataPoints = dataPoints
            .map({ (Double($0), Double($1)) })
            .sorted { $0.0 < $1.0 }
        self.minX = self.dataPoints.first?.0 ?? 0
        self.maxX = self.dataPoints.last?.0 ?? 0
        self.chartMinY = Double(chartMinY)
        self.chartMaxY = Double(chartMaxY)
        self.revealPercentage = revealPercentage
    }
    
    init(
        dataPoints: [(Int, Double)],
        chartMinY: Double,
        chartMaxY: Double,
        revealPercentage: CGFloat
    ) {
        self.dataPoints = dataPoints
            .map({ (Double($0), $1) })
            .sorted { $0.0 < $1.0 }
        self.minX = self.dataPoints.first?.0 ?? 0
        self.maxX = self.dataPoints.last?.0 ?? 0
        self.chartMinY = chartMinY
        self.chartMaxY = chartMaxY
        self.revealPercentage = revealPercentage
    }
    
    private let gradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color("Green"),
                Color("Blue")
            ]
        ),
        startPoint: .bottom,
        endPoint: .top
    )
    
    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { geometry in
                HStack(alignment: .center) {
                    let itemWidth = geometry.size.width / CGFloat(self.dataPoints.count * 2 - 1)
                    ForEach(self.dataPoints.indices, id: \.self) { i in
                        let dataPoint = self.dataPoints[i]
                        let heightRatio = (dataPoint.1 - self.chartMinY) / (self.chartMaxY - self.chartMinY) * self.revealPercentage
                        ZStack {
                            VStack(spacing: 0) {
                                Color("BarChartBarBg")
                                    .frame(
                                        height: geometry.size.height * (1 - heightRatio)
                                    )
                                self.gradient
                            }
                            .cornerRadius(itemWidth / 2)
                            VStack {
                                Spacer()
                                    .frame(
                                        height: geometry.size.height * (1 - heightRatio)
                                    )
                                self.gradient
                                    .cornerRadius(itemWidth / 2)
                                    .blur(radius: 4)
                                    .opacity(0.6)
                            }
                        }
                        .frame(
                            width: itemWidth,
                            height: geometry.size.height
                        )
                        .animation(
                            .easeInOut(duration: UI.Duration.chartRevealAnimation),
                            value: self.revealPercentage
                        )
                        if i < (self.dataPoints.count - 1) {
                            Spacer()
                                .frame(width: itemWidth)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(
            dataPoints: [
                (0, 0),
                (1, 10),
                (2, 5),
                (3, 5),
                (4, 7),
                (5, 5),
                (6, 2),
                (7, 1),
                (8, 3),
                (9, 7)
            ],
            chartMinY: 0,
            chartMaxY: 13,
            revealPercentage: 1.0
        )
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
}
