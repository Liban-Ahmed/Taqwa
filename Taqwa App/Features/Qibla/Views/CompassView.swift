//
//  CompassView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/5/25.
//
import SwiftUI

struct CompassView: View {
    /// The rotation angle of the arrow (mod 360) for display.
    let arrowAngle: Double
    
    let isAligned: Bool
    let alignmentThreshold: Double
    
    // Optional: cardinal points
    private let cardinalAngles: [Double] = [0, 90, 180, 270]
    private let secondaryAngles: [Double] = [45, 135, 225, 315]
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 3)
            
            // Inner ring
            Circle()
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                .frame(width: 260, height: 260)
            
            // Cardinal points
            ForEach(cardinalAngles, id: \.self) { angle in
                Text(cardinalPoint(for: angle))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: -135)
                    .rotationEffect(.degrees(angle))
            }
            
            // Secondary directions (optional)
            ForEach(secondaryAngles, id: \.self) { angle in
                Text(cardinalPoint(for: angle))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .offset(y: -135)
                    .rotationEffect(.degrees(angle))
            }
            
            // Qibla indicator
            VStack(spacing: 0) {
                Image(systemName: "location.north.line.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isAligned ? .green : .white)
                    .shadow(color: isAligned ? .green : .white, radius: 2)
                
                Rectangle()
                    .fill(isAligned ? Color.green : Color.white)
                    .frame(width: 2, height: 110)
                    .shadow(color: isAligned ? .green : .white, radius: 1)
            }
            // Rotate arrow negatively so 0° means "up"
            .rotationEffect(.degrees(-arrowAngle))
            .animation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8),
                       value: arrowAngle)
        }
        // Center decoration
        .overlay(
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 20, height: 20)
        )
        .shadow(color: .black.opacity(0.3), radius: 20)
    }
    
    private func cardinalPoint(for angle: Double) -> String {
        switch angle {
        case 0:   return "N"
        case 45:  return "NE"
        case 90:  return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default:  return ""
        }
    }
}

