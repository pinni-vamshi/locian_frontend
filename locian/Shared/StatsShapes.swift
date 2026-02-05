//
//  StatsShapes.swift
//  locian
//
//  Created for Advanced Stats Visualization.
//  Centralized custom shapes (Radar, Donut, Wave) as requested.
//

import SwiftUI

// MARK: - 1. Radar Chart Shape
struct RadarChartShape: Shape {
    let data: [Double] // Normalized 0.0 to 1.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count >= 3 else { return path }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleStep = (2 * .pi) / Double(data.count)
        
        // Start angle (Upwards = -pi/2)
        var currentAngle = -Double.pi / 2
        
        for (index, value) in data.enumerated() {
            let pointRadius = radius * CGFloat(value)
            let x = center.x + pointRadius * CGFloat(cos(currentAngle))
            let y = center.y + pointRadius * CGFloat(sin(currentAngle))
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            currentAngle += angleStep
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - 2. Radar Grid (Background Web)
struct RadarGridShape: Shape {
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard sides >= 3 else { return path }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleStep = (2 * .pi) / Double(sides)
        
        var currentAngle = -Double.pi / 2
        
        for index in 0..<sides {
            let x = center.x + radius * CGFloat(cos(currentAngle))
            let y = center.y + radius * CGFloat(sin(currentAngle))
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            currentAngle += angleStep
        }
        
        path.closeSubpath()
        return path
    }
}


// MARK: - 3. Donut Segment Shape
struct DonutSegmentShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadiusRatio: CGFloat // 0.6 = 60% hole
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio
        
        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - 4. Wave Graph Shape (Fluency)
struct WaveGraphShape: Shape {
    let dataPoints: [Double] // Normalized 0.0 to 1.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard dataPoints.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(dataPoints.count - 1)
        
        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: rect.height * (1.0 - CGFloat(dataPoints[0]))))
        
        for index in 1..<dataPoints.count {
            let x = CGFloat(index) * stepX
            let val = dataPoints[index]
            let y = rect.height * (1.0 - CGFloat(val))
            
            // Simple line for now (Bezier logic complex without full interpolation lib)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - 5. Area Fill for Wave
struct WaveAreaShape: Shape {
    let dataPoints: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard dataPoints.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(dataPoints.count - 1)
        
        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // First point
        path.addLine(to: CGPoint(x: 0, y: rect.height * (1.0 - CGFloat(dataPoints[0]))))
        
        // Loop
        for index in 1..<dataPoints.count {
            let x = CGFloat(index) * stepX
            let val = dataPoints[index]
            let y = rect.height * (1.0 - CGFloat(val))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close to bottom right then bottom left
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}
