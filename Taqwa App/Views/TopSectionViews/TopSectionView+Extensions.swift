//
//  TopSectionView+Extensions.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//
import SwiftUI

extension TopSectionView {
    // MARK: - TIMELINE SECTION
    var timelineSection: some View {
        ZStack {
            // Sun/Moon pinned top-right
            SunMoonIndicator(isDaytime: isDaytime)
                .offset(x: 160, y: -90) // Hard-coded offset to top-right
                .animation(.easeInOut(duration: 1))
        }
        .padding(.horizontal, 30)
    }

    // MARK: - DAY/NIGHT CHECK
        var isDaytime: Bool {
            // Use the current prayer to determine day or night
            switch currentPrayer {
            case "Fajr", "Dhuhr", "Asr":
                return true
            case "Maghrib", "Isha":
                return false
            default:
                return true // Default to daytime if unknown
            }
        }

    // MARK: - HELPER: PARALLAX OFFSET
    func parallaxOffset(base: CGFloat, rate: CGFloat) -> CGFloat {
        base + fakeScrollOffset * rate
    }

    // MARK: - HELPER: BACKGROUND GRADIENT
    func backgroundGradient(for prayer: String) -> LinearGradient {
        switch prayer {
        case "Fajr":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.30),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "Dhuhr":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.40, green: 0.70, blue: 1.0),
                    Color(red: 0.65, green: 0.85, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Asr":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.75, blue: 0.45),
                    Color(red: 1.00, green: 0.88, blue: 0.60)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        case "Maghrib":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.40, blue: 0.45),
                    Color(red: 0.55, green: 0.27, blue: 0.67)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "Isha":
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.35),
                    Color(red: 0.02, green: 0.03, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - HELPER: PRAYER ICON
    func systemIcon(for prayer: String) -> String {
        switch prayer {
        case "Fajr":    return "sun.and.horizon.fill"
        case "Dhuhr":   return "sun.max.fill"
        case "Asr":     return "sun.max.fill"
        case "Maghrib": return "sunset.fill"
        case "Isha":    return "moon.stars.fill"
        default:        return "sun.max.fill"
        }
    }
}
