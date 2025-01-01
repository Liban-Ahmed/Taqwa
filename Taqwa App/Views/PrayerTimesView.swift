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

                    // Date Selector
                    DateSelectorView(
                        selectedDate: viewModel.selectedDate,
                        hijriDate: viewModel.hijriDate,
                        onPreviousDate: {
                            viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? Date()
                            viewModel.updatePrayerTimesForSelectedDate()
                        },
                        onNextDate: {
                            viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? Date()
                            viewModel.updatePrayerTimesForSelectedDate()
                        }
                    )

                    // Prayer Times List
                    PrayerTimesListView(
                        prayerTimes: viewModel.prayerTimes,
                        currentPrayer: viewModel.currentPrayer,
                        currentTime: Date(),
                        selectedDate: viewModel.selectedDate // Use viewModel.selectedDate here
                    )
                }
                
            case .qibla:
                QiblaView() // Show Qibla View when "Qibla" tab is selected
                
            case .tracker:
                Text("Tracker") // Placeholder for tracker content
                
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
