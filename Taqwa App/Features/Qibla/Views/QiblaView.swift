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
    @Environment(\.dismiss) private var dismiss
    
    // Constants
    private let alignmentThreshold: Double = 10.0
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // Computed Properties
    private var bearingDifference: Double {
        var diff = viewModel.qiblaBearing - viewModel.deviceHeading
        // Normalize to -180 to 180 range
        diff = diff.truncatingRemainder(dividingBy: 360)
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        return diff
    }
    
    private var isAligned: Bool {
        abs(bearingDifference) < alignmentThreshold
    }
    
    private var directionMessage: String {
        if isAligned {
            return "Facing Qibla"
        }
        // Correct direction logic - if bearing difference is positive, turn right
        return bearingDifference > 0 ? "Turn Right" : "Turn Left"
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.30),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                Spacer()
                
                // Compass with continuous rotation
                CompassView(
                    deviceHeading: viewModel.deviceHeading,
                    qiblaBearing: viewModel.qiblaBearing,
                    isAligned: isAligned
                )
                .frame(width: 300, height: 300)
                .onChange(of: isAligned) { aligned in
                    if aligned {
                        hapticFeedback.impactOccurred(intensity: 0.7)
                    }
                }
                
                directionStatusView
                Spacer()
                statusView
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Qibla Direction")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { viewModel.startCalibration() }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var directionStatusView: some View {
        VStack(spacing: 12) {
            Text(directionMessage)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(isAligned ? .green : .white)
                .animation(.easeInOut, value: directionMessage)
            
            Text(viewModel.locationName)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 30)
    }
    
    private var statusView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: viewModel.accuracy == .high ?
                      "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(viewModel.accuracy == .high ? .green : .orange)
                Text(viewModel.locationStatus)
                    .foregroundColor(.white.opacity(0.8))
            }
            .font(.system(size: 16))
            
            if viewModel.calibrationRequired {
                Text("Please calibrate your device")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
        }
        .padding(.bottom, 20)
    }
}
