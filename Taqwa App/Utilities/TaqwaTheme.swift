import SwiftUI

struct TaqwaTheme {
    static let colors = ThemeColors()
    static let fonts = ThemeFonts()
    static let layout = ThemeLayout()
}

struct ThemeColors {
    let primary = Color(red: 0.2, green: 0.5, blue: 0.9)
    let secondary = Color(red: 0.3, green: 0.6, blue: 0.9)
    let accent = Color.orange
    let background = Color(.systemBackground)
    let surface = Color(.secondarySystemBackground)
}

struct ThemeFonts {
    let title = Font.system(size: 28, weight: .bold)
    let heading = Font.system(size: 22, weight: .semibold)
    let body = Font.system(size: 16, weight: .regular)
}

struct ThemeLayout {
    let padding: CGFloat = 16
    let cornerRadius: CGFloat = 12
    let spacing: CGFloat = 20
}
