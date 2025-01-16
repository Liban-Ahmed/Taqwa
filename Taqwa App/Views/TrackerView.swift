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
            
            Spacer().frame(height: 20)
            
            // Moved PrayerTimesListView
            PrayerTimesListView(viewModel: viewModel)
            
            // TrendView
            TrendView(viewModel: viewModel)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                    // Match prayer list background color or gradient
                        .fill(Color(.systemBackground).opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.bottom, 8) // Place at bottom with some space
            
        }
        .onAppear {
            viewModel.fetchPrayerTimes(for: viewModel.selectedDate)
        }
    }
}
