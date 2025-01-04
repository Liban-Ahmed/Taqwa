import SwiftUI
struct BottomNavigationBarView: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    
    private let tabBarHeight: CGFloat = 60
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private let selectedGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.75, blue: 0.45),
            Color(red: 1.00, green: 0.88, blue: 0.60)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    private let unselectedGradient = LinearGradient(
        colors: [Color.secondary, Color.secondary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                tabButton(tab)
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .background(.ultraThinMaterial.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal)
    }
    
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button(action: {
            handleTabSelection(tab)
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24))
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
    }
    
    private func handleTabSelection(_ tab: Tab) {
            impactGenerator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
