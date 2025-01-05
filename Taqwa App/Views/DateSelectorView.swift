import SwiftUI


struct DateSelectorView: View {
    let selectedDate: Date
    let hijriDate: String
    let onPreviousDate: () -> Void
    let onNextDate: () -> Void

    // New closure
    let onToday: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    static private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        formatter.locale = .current
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            // "Today" button now on top
            Button(action: {
                hapticFeedback.impactOccurred()
                onToday()
            }) {
                Text("Today")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.clear)
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.blue, lineWidth: 1)
                    )
        }
        }
        HStack {
            // Previous Date Button
            DateNavigationButton(
                systemName: "chevron.left",
                action: onPreviousDate,
                hapticFeedback: hapticFeedback,
                accessibilityLabel: "Previous Day"
            )
            
            Spacer()
            
            // Date Display
            VStack(spacing: 4) {
                Text(selectedDate, formatter: Self.fullDateFormatter)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primary)
                    .dynamicTypeSize(.large)
                
                Text(hijriDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                    .dynamicTypeSize(.large)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            
            Spacer()
            
            // Next Date Button
            DateNavigationButton(
                systemName: "chevron.right",
                action: onNextDate,
                hapticFeedback: hapticFeedback,
                accessibilityLabel: "Next Day"
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            // RoundedRectangle(cornerRadius: 12)
            //     .fill(
            //         LinearGradient(
            //             colors: [
            //                 colorScheme == .dark ? Color(.systemGray6) : .white,
            //                 colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6).opacity(0.5)
            //             ],
            //             startPoint: .top,
            //             endPoint: .bottom
            //         )
            //     )
            Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
            radius: 5,
            x: 0,
            y: colorScheme == .dark ? 2 : 1
        )
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        hapticFeedback.impactOccurred(intensity: 0.7)
                        if value.translation.width > 0 {
                            onPreviousDate()
                        } else {
                            onNextDate()
                        }
                    }
                }
        )
        .animation(.easeInOut(duration: 0.2), value: selectedDate)
    }
}

struct DateNavigationButton: View {
    let systemName: String
    let action: () -> Void
    let hapticFeedback: UIImpactFeedbackGenerator
    let accessibilityLabel: String
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                hapticFeedback.impactOccurred(intensity: 0.7)
                action()
            }
        }) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.primary.opacity(0.8))
                .frame(width: 44, height: 44)
                .background(Color.primary.opacity(0.05))
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeOut(duration: 0.2), value: isPressed)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(accessibilityLabel)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
