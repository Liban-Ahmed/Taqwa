//
//  CompassView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/5/25.
//
import SwiftUI

struct CompassView: View {
    let deviceHeading: Double
    let qiblaBearing: Double
    let isAligned: Bool
    
    private let cardinalAngles: [Double] = [0, 90, 180, 270]
    private let secondaryAngles: [Double] = [45, 135, 225, 315]
    private let tickMarks: [Double] = Array(stride(from: 0, through: 350, by: 10))
    private let alignedColor = Color(red: 0.3, green: 0.8, blue: 0.4)
    private let normalColor = Color.white
    
    var body: some View {
        ZStack {
            // Background rings
            Circle()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 3)
            
            Circle()
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                .frame(width: 260, height: 260)
            
            // Base compass with cardinal points and ticks
            ZStack {
                // Tick marks
                ForEach(tickMarks, id: \.self) { angle in
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: angle.truncatingRemainder(dividingBy: 30) == 0 ? 2 : 1,
                               height: angle.truncatingRemainder(dividingBy: 30) == 0 ? 15 : 10)
                        .offset(y: -135)
                        .rotationEffect(.degrees(angle))
                }
                
                // Cardinal points
                ForEach(cardinalAngles, id: \.self) { angle in
                    Text(cardinalPoint(for: angle))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.8))
                        .offset(y: -135)
                        .rotationEffect(.degrees(angle))
                }
                
                // Secondary directions
                ForEach(secondaryAngles, id: \.self) { angle in
                    Text(cardinalPoint(for: angle))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .offset(y: -135)
                        .rotationEffect(.degrees(angle))
                }
            }
            .rotationEffect(.degrees(-deviceHeading))
            
            // Qibla indicator
            VStack(spacing: 0) {
                Image(systemName: "location.north.line.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isAligned ? alignedColor : normalColor)
                    .shadow(color: isAligned ? alignedColor : normalColor, radius: 2)
                
                Rectangle()
                    .fill(isAligned ? alignedColor : normalColor)
                    .frame(width: 2, height: 110)
            }
            .rotationEffect(.degrees(qiblaBearing - deviceHeading))
            .animation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8), value: deviceHeading)
            
            // Center point
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [
                        isAligned ? alignedColor : normalColor,
                        (isAligned ? alignedColor : normalColor).opacity(0.1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 10
                ))
                .frame(width: 20, height: 20)
                .shadow(color: isAligned ? alignedColor : normalColor, radius: 4)
        }
    }
    
    private func cardinalPoint(for angle: Double) -> String {
        switch angle {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
}
