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
    // Observed/StateObject ensures the view model lives as long as this view hierarchy
    @StateObject private var viewModel = QiblaDirectionViewModel()
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    // Haptic feedback generator
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // Alignment threshold (could also live in your QiblaDirectionViewModel)
    private let alignmentThreshold: Double = 8.0
    
    // Compass dimension
    private let compassSize: CGFloat = 300
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                headerView
                Spacer()
                
                compassSection
                    .onChange(of: isAligned, perform: handleAlignmentChange)
                
                directionStatusView
                Spacer()
                
                statusView
            }
            .padding()
        }
        .navigationBarHidden(true) // or .toolbar(.hidden) on iOS 16+
        .onAppear(perform: handleOnAppear)
        .onDisappear(perform: handleOnDisappear)
        .onChange(of: scenePhase, perform: handleScenePhaseChange)
    }
}

// MARK: - Computed Properties & Helpers
extension QiblaView {
    
    /// The difference between Qibla bearing and device heading in the range [−180, 180].
    private var bearingDifference: Double {
        let bearing = viewModel.qiblaBearing
        let heading = viewModel.deviceHeading
        var diff = (bearing - heading).truncatingRemainder(dividingBy: 360)
        if diff > 180  { diff -= 360 }
        if diff < -180 { diff += 360 }
        return diff
    }
    
    /// Determines if user is within alignmentThreshold of Qibla direction.
    private var isAligned: Bool {
        abs(bearingDifference) < alignmentThreshold
    }
    
    /// Instructional text based on whether user is aligned or needs to turn left/right.
    private var directionMessage: String {
        if isAligned {
            return "Facing Qibla"
        }
        return bearingDifference > 0 ? "Turn Right" : "Turn Left"
    }
    
    /// Wrap error message in an identifiable struct to present as an Alert.
    private var errorWrapper: IdentifiableError? {
        guard let errorMessage = viewModel.errorMessage else { return nil }
        return IdentifiableError(message: errorMessage)
    }
}

// MARK: - Subviews
extension QiblaView {
    
    /// Background gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.10, blue: 0.30),
                Color(red: 0.50, green: 0.25, blue: 0.60)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Top header with back button, title, and calibration button
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
    
    /// Compass + alignment indicator using the extremely smooth `SmoothCompassView`
    private var compassSection: some View {
        SmoothCompassView(
            deviceHeading: viewModel.deviceHeading,
            qiblaBearing: viewModel.qiblaBearing,
            isAligned: isAligned
        )
        .frame(width: compassSize, height: compassSize)
    }
    
    /// Direction message (Facing Qibla / Turn Left / Turn Right) + location name
    private var directionStatusView: some View {
        VStack(spacing: 12) {
            Text(directionMessage)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(isAligned ? .green : .white)
                .animation(.easeInOut(duration: 0.3), value: directionMessage)
            
            Text(viewModel.locationName)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 30)
    }
    
    /// Accuracy & calibration status below
    private var statusView: some View {
        VStack(spacing: 8) {
            accuracyStatusView
            calibrationStatusView
        }
        .padding(.bottom, 20)
    }
    
    /// Shows current accuracy level & status text
    private var accuracyStatusView: some View {
        HStack {
            Image(systemName: viewModel.accuracy == .high
                  ? "checkmark.circle.fill"
                  : "exclamationmark.circle.fill")
                .foregroundColor(viewModel.accuracy == .high ? .green : .orange)
            
            Text(viewModel.locationStatus)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 16))
        }
    }
    
    /// If calibrationRequired, prompt user to calibrate
    private var calibrationStatusView: some View {
        if viewModel.calibrationRequired {
            return AnyView(
                Text("Please calibrate your device")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

// MARK: - Lifecycle & Interaction Handlers
extension QiblaView {
    
    /// Called when `scenePhase` changes (foreground, background, etc.)
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // Optionally force calibration upon return
            viewModel.startCalibration()
        case .inactive, .background:
            // Stop or reduce updates to save battery, if desired
            break
        @unknown default:
            break
        }
    }
    
    /// Called when the view appears
    private func handleOnAppear() {
        // Resume location/heading updates if you want them only while this view is active
        viewModel.resumeUpdates()
    }
    
    /// Called when the view disappears
    private func handleOnDisappear() {
        // Stop location/heading updates to save battery
        viewModel.stopAllUpdates()
    }
    
    /// Called whenever `isAligned` changes
    private func handleAlignmentChange(_ aligned: Bool) {
        if aligned {
            hapticFeedback.prepare()
            hapticFeedback.impactOccurred(intensity: 0.7)
        }
    }
}

// MARK: - Alert Handling (if you want an Alert for errors)
extension QiblaView {
    private func showErrorAlert(error: IdentifiableError) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(error.message),
            dismissButton: .default(Text("OK"))
        )
    }
}

// MARK: - IdentifiableError for Alerts
struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}
