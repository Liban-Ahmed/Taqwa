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
                        timeRemaining: viewModel.timeRemaining
                    )
                    // Quick Actions Grid
                    HStack(spacing: 16) {
                               VStack(spacing: 8) {
                                   HStack {
                                       Text("Today's Prayers")
                                           .font(.headline)
                                       Spacer()
                                       Image(systemName: "calendar")
                                           .font(.system(size: 18))
                                           .foregroundColor(.blue)
                                   }
                                   Text("5/5 Completed")
                                       .font(.subheadline)
                                       .foregroundColor(.gray)
                               }
                               .padding()
                               .background(Color(.systemBackground))
                               .cornerRadius(12)
                               .shadow(radius: 4)
                               
                               VStack(spacing: 8) {
                                   HStack {
                                       Text("Qibla")
                                           .font(.headline)
                                       Spacer()
                                       Image(systemName: "location.north.line.fill")
                                           .font(.system(size: 18))
                                           .foregroundColor(.blue)
                                   }
                                   Text("125° NE")
                                       .font(.subheadline)
                                       .foregroundColor(.gray)
                               }
                               .padding()
                               .background(Color(.systemBackground))
                               .cornerRadius(12)
                               .shadow(radius: 4)
                           }
                       }
                       .padding(.top, 16)
                
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
