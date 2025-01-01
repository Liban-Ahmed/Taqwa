import SwiftUI

struct DateSelectorView: View {
    let selectedDate: Date
    let hijriDate: String
    let onPreviousDate: () -> Void
    let onNextDate: () -> Void

    var body: some View {
        HStack {
            // Previous Date Button
            Button(action: onPreviousDate) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primary.opacity(0.8))
            }
            Spacer()

            // Date Display - In single line with distinct styles
            VStack(spacing: 4) {
                Text(selectedDate, formatter: Self.fullDateFormatter)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primary)
                Text(hijriDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.orange)
            }

            Spacer()

            // Next Date Button
            Button(action: onNextDate) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primary.opacity(0.8))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // Date Formatter for Full Date Display
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"  // Example: Monday 30th December
        return formatter
    }()
}
