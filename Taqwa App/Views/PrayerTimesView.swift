//
//  PrayerTimesView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @State private var selectedTab: Tab = .prayer
    
    var body: some View {
        VStack(spacing: 0) {
            // Dynamic Content Switching
            switch selectedTab {
            case .prayer:
                VStack {
                    // Top Section
                    TopSectionView(
                        currentPrayer: viewModel.currentPrayer,
                        timeRemaining: viewModel.timeRemaining
                    )
                    // Grid Section
                    GridLayoutView()
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                       }
                       .padding(.top, 16)
                       .background(
                           LinearGradient(
                               gradient: Gradient(colors: [
                                   Color(red: 0.05, green: 0.10, blue: 0.30),
                                   Color(red: 0.50, green: 0.25, blue: 0.60)
                               ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           )
                       )
                
                
                
            case .qibla:
                QiblaView() // Show Qibla View when "Qibla" tab is selected
                
            case .tracker:
                TrackerView() // Placeholder for tracker content
                
            case .settings:
                Text("Settings") // Placeholder for settings content
            }

            // Bottom Navigation Bar
            BottomNavigationBarView(selectedTab: $selectedTab)
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.fetchPrayerTimes(for: Date())
        }
    }
}
