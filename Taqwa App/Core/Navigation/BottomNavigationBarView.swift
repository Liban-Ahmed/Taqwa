import SwiftUI

enum Tab: String, CaseIterable {
    case prayer
    case qibla
    case tracker
    case settings
    
    var icon: String {
        switch self {
        case .prayer: return "clock.fill"
        case .qibla: return "location.north.line.fill"
        case .tracker: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .prayer: return "Prayer"
        case .qibla: return "Qibla"
        case .tracker: return "Tracker"
        case .settings: return "Settings"
        }
    }
}

struct BottomNavigationBarView: View {
    @Binding var selectedTab: Tab
    
    // MARK: - Constants
    private let tabBarHeight: CGFloat = 49
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let selectedColor = Color.accentColor
    private let unselectedColor = Color.secondary.opacity(0.6)
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                tabButton(tab)
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .padding(.horizontal)
        .onAppear {
            // Prepare haptic feedback in advance
            impactGenerator.prepare()
        }
    }
    
    // MARK: - Tab Button
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button(action: {
            if selectedTab != tab {
                handleTabSelection(tab)
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? selectedColor : unselectedColor)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? selectedColor : unselectedColor)
            }
            .frame(height: tabBarHeight - 10)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(OptimizedTabButtonStyle())
        .accessibilityLabel("\(tab.title) Tab")
    }
    
    private func handleTabSelection(_ tab: Tab) {
        // Trigger haptic first
        impactGenerator.impactOccurred(intensity: 0.4)
        
        // Then update UI
        withAnimation(.easeOut(duration: 0.2)) {
            selectedTab = tab
        }
    }
}

// MARK: - Optimized Button Style
struct OptimizedTabButtonStyle: ButtonStyle {
    @State private var isPressed = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
