import SwiftUI

struct TrackerView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    
    var body: some View {
        VStack {
            // Updated DateSelectorView with onToday
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
                },
                onToday: {
                    viewModel.selectedDate = Date()
                    viewModel.updatePrayerTimesForSelectedDate()
                }
            )
            
            // Moved PrayerTimesListView
            PrayerTimesListView(viewModel: viewModel)
            
            // TrendView
            // TrendView(viewModel: viewModel)

            Spacer()
        }
        .onAppear {
            viewModel.fetchPrayerTimes(for: viewModel.selectedDate)
        }
    }
}