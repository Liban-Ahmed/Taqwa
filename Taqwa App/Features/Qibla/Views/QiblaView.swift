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
                    Image(systemName: "arrow.up")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 250, height: 250)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                        // Rotate using arrowAngle directly
                        .rotationEffect(.degrees(viewModel.arrowAngle))
                }
                // We do NOT add extra .animation here because we already animate in the ViewModel
                // If you want a slight “extra” effect, you can add it, but it can cause double-animations.
                
                // Bearing Info
                Text("\(angleDegrees)° \(directionText)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
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
