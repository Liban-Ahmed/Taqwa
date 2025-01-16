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
    
    private var adjustedBearing: Double {
        let rawDifference = viewModel.qiblaBearing - viewModel.deviceHeading
        let normalized = rawDifference.truncatingRemainder(dividingBy: 360)
        return normalized
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(abs(adjustedBearing) < 10 ? .green : .gray)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: adjustedBearing)
            
            VStack(spacing: 30) {
                // Location Title
                Text(viewModel.locationName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Central Qibla Direction Indicator
                ZStack {
                    // Main arrow
                    Image(systemName: "arrow.up")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 250, height: 250)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                        .rotationEffect(.degrees(adjustedBearing))
                        .animation(
                            .interpolatingSpring(
                                mass: 1.0,
                                stiffness: 50,
                                damping: 8,
                                initialVelocity: 0
                            ),
                            value: adjustedBearing
                        )
                }
                
                // Bearing Info
                Text("\(Int(abs(adjustedBearing.truncatingRemainder(dividingBy: 360))))° \(abs(adjustedBearing.truncatingRemainder(dividingBy: 360)) < 10 ? "Facing Qibla" : (adjustedBearing < 0 ? "Turn Left" : "Turn Right"))")
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
