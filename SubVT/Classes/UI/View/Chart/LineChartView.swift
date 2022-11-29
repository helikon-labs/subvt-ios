//
//  LineChartView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 12.07.2022.
//

import SwiftUI

struct LineChartView: View {
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
    
    private let gradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color("Blue"),
                Color("Green")
            ]
        ),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private func getPointAt(
        _ index: Int,
        height: CGFloat,
        xStep: CGFloat,
        yStep: CGFloat
    ) -> CGPoint {
        return CGPoint(
            x: CGFloat(self.dataPoints[index].0 - self.minX) * xStep,
            y: height - CGFloat(self.dataPoints[index].1 - self.chartMinY) * yStep
        )
    }
    
    func getAntipodal(
        point: CGPoint?,
        center: CGPoint?
    ) -> CGPoint? {
        guard let p1 = point, let center = center else {
            return nil
        }
        let newX = 2 * center.x - p1.x
        let diffY = abs(p1.y - center.y)
        let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)
        return CGPoint(x: newX, y: newY)
    }
    
    func getMidPoint(
        p1: CGPoint,
        p2: CGPoint
    ) -> CGPoint {
        return CGPoint(
            x: (p1.x + p2.x) / 2,
            y: (p1.y + p2.y) / 2
        );
    }
    
    private func getControlPoint(
        p1: CGPoint,
        p2: CGPoint,
        p3: CGPoint?
    ) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }
        let leftMidPoint  = getMidPoint(p1: p1, p2: p2)
        let rightMidPoint = getMidPoint(p1: p2, p2: p3)
        var controlPoint = getMidPoint(
            p1: leftMidPoint,
            p2: getAntipodal(point: rightMidPoint, center: p2)!
        )
        if p1.y.between(a: p2.y, b: controlPoint.y) {
            controlPoint.y = p1.y
        } else if p2.y.between(a: p1.y, b: controlPoint.y) {
            controlPoint.y = p2.y
        }
        let imaginContol = getAntipodal(point: controlPoint, center: p2)!
        if p2.y.between(a: p3.y, b: imaginContol.y) {
            controlPoint.y = p2.y
        }
        if p3.y.between(a: p2.y, b: imaginContol.y) {
            let diffY = abs(p2.y - p3.y)
            controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
        }
        controlPoint.x += (p2.x - p1.x) * 0.1
        return controlPoint
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let height = geometry.size.height
                let width = geometry.size.width
                let xStep = width / CGFloat(maxX - minX)
                let yStep = height / CGFloat(self.chartMaxY - self.chartMinY)
                ForEach (0...1, id:\.self) { i in
                    Path { path in
                        var lastPoint: CGPoint!
                        var lastControlPoint: CGPoint? = nil
                        for i in 0..<self.dataPoints.count {
                            let currentPoint = self.getPointAt(
                                i,
                                height: height,
                                xStep: xStep,
                                yStep: yStep
                            )
                            var nextPoint: CGPoint? = nil
                            if i == 0 {
                                lastPoint = currentPoint
                                path.move(to: currentPoint)
                            } else if i == 1 && self.dataPoints.count == 2 {
                                path.addLine(to: currentPoint)
                            } else {
                                if i < self.dataPoints.count - 1 {
                                    nextPoint = self.getPointAt(
                                        i + 1,
                                        height: height,
                                        xStep: xStep,
                                        yStep: yStep
                                    )
                                }
                                let controlPoint = self.getControlPoint(
                                    p1: lastPoint,
                                    p2: currentPoint,
                                    p3: nextPoint
                                )
                                path.addCurve(
                                    to: currentPoint,
                                    control1: lastControlPoint ?? lastPoint,
                                    control2: controlPoint ?? currentPoint
                                )
                                lastPoint = currentPoint
                                lastControlPoint = self.getAntipodal(
                                    point: controlPoint,
                                    center: currentPoint
                                )
                            }
                        }
                    }
                    .trim(from: 0, to: self.revealPercentage)
                    .stroke(
                        self.gradient,
                        style: StrokeStyle(
                            lineWidth: UI.Dimension.Common.lineChartLineWidth.get(),
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .offset(
                        x: 0,
                        y: 7 * CGFloat(i)
                    )
                    .opacity(1.0 - 0.7 * Double(i))
                    .blur(radius: 4 * CGFloat(i))
                    .animation(
                        .easeInOut(duration: UI.Duration.counterAnimation),
                        value: self.revealPercentage
                    )
                }
            }
        }
    }
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView(
            dataPoints: [
                (0, 0),
                (1, 10),
                (2, 5),
                (3, 5),
                (4, 7),
                (5, 5),
                (6, 2),
                (7, -5),
                (8, -7),
                (9, -2)
            ],
            chartMinY: -10,
            chartMaxY: 10,
            revealPercentage: 1.0
        )
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
}
