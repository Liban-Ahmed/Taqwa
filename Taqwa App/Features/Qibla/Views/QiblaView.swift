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
    
    // Track scenePhase if you want to stop/resume updates
    @Environment(\.scenePhase) private var scenePhase
    
    // If you want a haptic tap when user gets within certain alignment
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let alignmentThreshold: Double = 8.0
    
    var body: some View {
        
        // 1) Decide background color: dark or green?
        //    If user is “close enough” to Qibla, you might show green, else dark.
        let isClose = abs(viewModel.relativeAngle) < alignmentThreshold
        let backgroundColor = isClose ? Color.green : Color.black
        
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // 2) Top bar / location label
                VStack(alignment: .leading, spacing: 0) {
                    Text("LOCATION")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.7))
                        .padding(.bottom, 2)
                    
                    Text(viewModel.locationName) // e.g. "809 Bay Dr"
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .top], 24)
                
                Spacer()
                
                // 3) Compass: big arrow + partial arc
                CompassView(
                    deviceHeading: viewModel.deviceHeading,
                    qiblaBearing: viewModel.qiblaBearing, isAligned: true
                )
                .frame(width: 250, height: 250)
                
                // 4) Degrees + direction text
                //    "153°" + "to your left" or "slight left" etc.
                VStack(spacing: 4) {
                    // Convert the numeric angle to Int or keep Double with 0 decimals
                    let angleText = String(format: "%.0f°", viewModel.relativeAngle)
                    
                    Text(angleText)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.directionHint) // "to your left", "slight left", etc.
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.top, 16)
                
                Spacer()
                
                // 5) Bottom bar with phone icon & heart icon
                HStack {
                    // Left icon (could be phone rotation instructions)
                    Button(action: {
                        // Possibly call viewModel.startCalibration() or show info
                    }) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    // Right icon (could be a favorite or "like")
                    Button(action: {
                        // Your logic here
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.2)))
                    }
                }
                .padding([.leading, .trailing, .bottom], 24)
            }
        }
        .onAppear {
            viewModel.resumeUpdates()
        }
        .onDisappear {
            viewModel.stopAllUpdates()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                viewModel.resumeUpdates()
            case .inactive, .background:
                viewModel.stopAllUpdates()
            @unknown default:
                break
            }
        }
        // 6) Haptic feedback if user crosses alignment threshold
        .onChange(of: isClose) { newValue in
            if newValue {
                hapticFeedback.prepare()
                hapticFeedback.impactOccurred(intensity: 0.7)
            }
        }
    }
}
