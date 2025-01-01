//
//  QiblaView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//
//
//  QiblaView.swift
//  Qibla Direction App
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
        let normalized = ((rawDifference + 180).truncatingRemainder(dividingBy: 360) - 180)
        return normalized < -180 ? normalized + 360 : normalized
    }
    
    var body: some View {
        ZStack {
            // Background color transitions
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
                
                // Qibla Direction Indicator
                ZStack {
                    
                    // Arrow indicating Qibla direction
                    Image(systemName: "arrow.up")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(adjustedBearing))
                        .animation(
                            .spring(
                                response: 0.8,
                                dampingFraction: 0.7,
                                blendDuration: 0.5
                            ),
                            value: adjustedBearing
                        )
                }
                
                // Bearing Info
                Text("\(Int(abs(adjustedBearing)))° \(abs(adjustedBearing) < 10 ? "Facing Qibla" : (adjustedBearing < 0 ? "Turn Left" : "Turn Right"))")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Spacer()
                
                // Location and Status Information
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
