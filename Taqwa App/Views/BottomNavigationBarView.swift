import SwiftUI

struct BottomNavigationBarView: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    
    private let tabBarHeight: CGFloat = 60
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                tabButton(tab)
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .background(
            Glass(style: colorScheme == .dark ? .dark : .light)
        )
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .padding(.horizontal)
    }
    
    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        
        return Button(action: {
            handleTabSelection(tab)
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.blue : .secondary)
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(tab.title)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? Color.blue : .secondary)
            }
            .frame(height: tabBarHeight)
            .contentShape(Rectangle())
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

// Custom button style for tabs
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Enhanced glass effect background
struct Glass: View {
    enum Style {
        case light, dark
    }
    
    let style: Style
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(style == .light ? 0.8 : 0.7)
                .blur(radius: 3)
            
            Rectangle()
                .fill(style == .light ? .white.opacity(0.1) : .black.opacity(0.1))
            
            Rectangle()
                .stroke(style == .light ? .white.opacity(0.2) : .white.opacity(0.1), lineWidth: 1)
        }
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

