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
            // Dynamic gradient background instead of solid color
            LinearGradient(
                gradient: Gradient(colors: [
                    isFacingQibla ? Color.green.opacity(0.6) : Color.gray.opacity(0.6),
                    isFacingQibla ? Color.green.opacity(0.3) : Color.gray.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: isFacingQibla)
            
            VStack(spacing: 30) {
                // Enhanced Location Header
                VStack(spacing: 8) {
                    Text(viewModel.locationName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Direction Text with dynamic styling
                    Text(directionText)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isFacingQibla ? .white : .white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isFacingQibla ? Color.green.opacity(0.3) : Color.white.opacity(0.1))
                        )
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Compass Container
                ZStack {
                    // Outer ring
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 320, height: 320)
                    
                    // Inner ring
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 280, height: 280)
                    
                    // Cardinal markers with improved styling
                    ForEach(0..<4) { index in
                        let labels = ["N", "E", "S", "W"]
                        let angle = Double(index) * 90.0
                        Text(labels[index])
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(-angle))
                            .offset(x: 0, y: -150)
                            .rotationEffect(.degrees(angle))
                    }
                    
                    // Existing Arrow (unchanged)
                    Image(systemName: "arrow.up")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                        .rotationEffect(.degrees(viewModel.arrowAngle))
                }
                .frame(width: 320, height: 320)
                
                Spacer()
                
                // Enhanced Status Footer
                VStack(spacing: 12) {
                    // Accuracy indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isFacingQibla ? Color.green : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                        Text(viewModel.locationStatus)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    
                    Text("Your Location: \(viewModel.locationName)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}
