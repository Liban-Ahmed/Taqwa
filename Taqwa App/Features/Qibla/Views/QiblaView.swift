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
    
    /// Tracks the compass arrow position continuously (can exceed ±360).
    @State private var internalCompassAngle: Double = 0.0
    
    /// Threshold for showing "Facing Qibla" (e.g. ±10°).
    private let alignmentThreshold: Double = 10.0
    
    /**
     A smaller "snap" threshold for freezing the arrow near 0°.
     If you're within ±2°, the arrow locks at 0, avoiding flips.
     */
    private let snapThreshold: Double = 2.0
    
    // MARK: - Body
    
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
                
                // Compass
                CompassView(
                    // Display angle mod 360, but track continuously internally
                    arrowAngle: internalCompassAngle.truncatingRemainder(dividingBy: 360),
                    isAligned: isAligned,
                    alignmentThreshold: alignmentThreshold
                )
                .frame(width: 300, height: 300)
                .onChange(of: viewModel.deviceHeading) { _ in
                    recalcCompassAngle()
                }
                .onChange(of: viewModel.qiblaBearing) { _ in
                    recalcCompassAngle()
                }
                .onAppear {
                    // Initialize the compass angle on appear
                    recalcCompassAngle()
                }
                
                // Direction & location
                directionStatusView
                
                Spacer()
                
                // Accuracy & calibration info
                statusView
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Computed Properties
    
    /// True if the device heading is within `alignmentThreshold` degrees of the Qibla.
    private var isAligned: Bool {
        let diff = minimalDifferenceBetween(
            from: viewModel.deviceHeading,
            to: viewModel.qiblaBearing
        )
        return abs(diff) < alignmentThreshold
    }
    
    /// Message for left/right or "Facing Qibla".
    private var directionMessage: String {
        let diff = minimalDifferenceBetween(
            from: viewModel.deviceHeading,
            to: viewModel.qiblaBearing
        )
        
        if abs(diff) < alignmentThreshold {
            return "Facing Qibla"
        }
        // Swap "Turn Right" / "Turn Left" if reversed on your device
        return diff > 0 ? "Turn Right" : "Turn Left"
    }
    
    /// Icons & colors for accuracy
    private var accuracyIcon: String {
        viewModel.accuracy == .high ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }
    private var accuracyColor: Color {
        viewModel.accuracy == .high ? .green : .orange
    }
    
    // MARK: - Updating the Compass Angle
    
    /**
     Recalculate the arrow angle whenever the device heading or Qibla bearing changes.
     We lock (freeze) the arrow at 0° if the difference is within `snapThreshold`,
     to avoid flipping near 0°.
     */
    private func recalcCompassAngle() {
        let newAngle = -(viewModel.qiblaBearing - viewModel.deviceHeading)
        
        // Check how close we are to Qibla
        let diff = minimalDifferenceBetween(
            from: viewModel.deviceHeading,
            to: viewModel.qiblaBearing
        )
        
        if abs(diff) < snapThreshold {
            // If we’re within ±2°, freeze the arrow at 0°
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                internalCompassAngle = 0
            }
        } else {
            // Otherwise update continuously
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                internalCompassAngle = updateContinuously(
                    oldAngle: internalCompassAngle,
                    newAngle: newAngle
                )
            }
        }
    }
    
    /// Moves from `oldAngle` to `newAngle` by the smallest step, never flipping across ±180 abruptly.
    private func updateContinuously(oldAngle: Double, newAngle: Double) -> Double {
        let diff = minimalDifferenceBetween(from: oldAngle, to: newAngle)
        return oldAngle + diff
    }
    
    /**
     Returns the minimal difference between two angles in [–180, 180].
     Used to ensure we rotate by the shortest path.
     */
    func minimalDifferenceBetween(from: Double, to: Double) -> Double {
        var diff = (to - from).truncatingRemainder(dividingBy: 360)
        if diff > 180 { diff -= 360 }
        if diff <= -180 { diff += 360 }
        return diff
    }
}

// MARK: - Subviews

extension QiblaView {
    
    /// Header with back button, title, and calibration button
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
    
    /// Shows the direction message and location name
    fileprivate var directionStatusView: some View {
        VStack(spacing: 12) {
            Text(directionMessage)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(isAligned ? .green : .white)
            
            Text(viewModel.locationName)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 30)
    }
    
    /// Accuracy status and calibration notice
    private var statusView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: accuracyIcon)
                    .foregroundColor(accuracyColor)
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

// MARK: - CompassView

