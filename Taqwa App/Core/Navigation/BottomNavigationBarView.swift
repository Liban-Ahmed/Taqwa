import SwiftUI
struct BottomNavigationBarView: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    
    private let tabBarHeight: CGFloat = 49
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private let selectedGradient = Color.accentColor
    
    private let unselectedGradient = Color.secondary.opacity(0.75)
    
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
    }
    
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button(action: {
            handleTabSelection(tab)
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isSelected ? selectedGradient : unselectedGradient)
                    .frame(height: 30)
                
                Text(tab.title)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? selectedGradient : unselectedGradient)
            }
            .frame(height: tabBarHeight - 10)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabButtonStyle())
        .accessibilityLabel("\(tab.title) Tab")
    }
    
    private func handleTabSelection(_ tab: Tab) {
            impactGenerator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                selectedTab = tab
            }
        }
}

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

enum Tab: String, CaseIterable {
    case prayer, qibla, tracker, settings
    
    var title: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .prayer: "sun.max.fill"
        case .qibla: "location.north.line.fill"
        case .tracker: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }
}
