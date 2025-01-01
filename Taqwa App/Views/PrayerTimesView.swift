//
//  PrayerTimesView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()

    var body: some View {
        VStack(spacing: 0) {
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

            // Bottom Navigation Bar
            BottomNavigationBarView()
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.fetchPrayerTimes(for: Date())
        }
    }
}
