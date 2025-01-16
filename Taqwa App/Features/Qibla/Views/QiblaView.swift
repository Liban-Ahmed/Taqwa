//
//  QiblaView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//

import SwiftUI
import CoreLocation
import Combine

struct QiblaView: View {
    @StateObject private var viewModel = QiblaDirectionViewModel()
    
    // A helper that returns arrowAngle in [-180, 180] or [0..360], whichever you prefer
    private var adjustedAngle: Double {
        // Keep the angle in [-180, 180] for easy "Turn Left/Right" logic
        var angle = viewModel.arrowAngle.truncatingRemainder(dividingBy: 360)
        if angle > 180 { angle -= 360 }
        if angle < -180 { angle += 360 }
        return angle
    }
    
    private var isFacingQibla: Bool {
        abs(adjustedAngle) < 10
    }
    
    private var directionText: String {
        if isFacingQibla {
            return "Facing Qibla"
        } else {
            // If angle is negative, Qibla is to your left; if positive, it's to your right
            return adjustedAngle < 0 ? "Turn Left" : "Turn Right"
        }
    }
    
    private var angleDegrees: Int {
        Int(abs(adjustedAngle))
    }
    
    var body: some View {
        ZStack {
            // If we’re within ±10°, use green; otherwise gray
            Color(isFacingQibla ? .green : .gray)
                .ignoresSafeArea()
            // Animate color changes over 0.5s
                .animation(.easeInOut(duration: 0.5), value: isFacingQibla)
            
            VStack(spacing: 30) {
                // Location Title
                Text(viewModel.locationName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Central Qibla Direction Indicator
                ZStack {
                    // A subtle disc
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 300, height: 300)
                    
                    // Cardinal markers (N, E, S, W)
                    ForEach(0..<4) { index in
                        let labels = ["N", "E", "S", "W"]
                        let angle = Double(index) * 90.0
                        Text(labels[index])
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(-angle)) // Keep text upright
                            .offset(x: 0, y: -140) // position label on circle
                            .rotationEffect(.degrees(angle))
                    }
                    
                    // Arrow
                    Image(systemName: "arrow.up")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                        .rotationEffect(.degrees(viewModel.arrowAngle))
                }
                .frame(width: 300, height: 300)
                
                Spacer()
                
                // Location Info
                VStack(spacing: 5) {
                    Text(viewModel.locationStatus)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Your Location: \(viewModel.locationName)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}
