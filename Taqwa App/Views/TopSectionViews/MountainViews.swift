//
//  MountainViews.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//

import SwiftUI

struct MountainRangeView: View {
    let currentPrayer: String
    let scrollOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.clear)
                .frame(width: 567.73, height: 567.73)
                .position(x: -86.94, y: 655.78)
        }
    }
}

struct BackMountainView: View {
    let currentPrayer: String
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h * 0.8))
                    path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w, y: h * 0.1))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            mountainBaseColor(for: currentPrayer),
                            mountainPeakColor(for: currentPrayer)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                
                // Snow cap
                Path { path in
                    path.move(to: CGPoint(x: w * 0.32, y: h * 0.28))
                    path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.25))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.5))
            }
        }
    }
}

struct FrontMountainView: View {
    let currentPrayer: String
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h * 0.7))
                    path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.3))
                    path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            mountainBaseColor(for: currentPrayer).opacity(0.9),
                            mountainPeakColor(for: currentPrayer).opacity(0.9)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                
                // Ridge snow
                Path { path in
                    path.move(to: CGPoint(x: w * 0.25, y: h * 0.36))
                    path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.3))
                    path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.35))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.5))
            }
        }
    }
}

// Helpers for mountain colors
func mountainBaseColor(for prayer: String) -> Color {
    switch prayer {
    case "Fajr":
        return Color.blue.opacity(0.4)
    case "Dhuhr":
        return Color.blue.opacity(0.3)
    case "Asr":
        return Color.orange.opacity(0.3)
    case "Maghrib":
        return Color.purple.opacity(0.4)
    case "Isha":
        return Color.black.opacity(0.3)
    default:
        return Color.gray.opacity(0.3)
    }
}

func mountainPeakColor(for prayer: String) -> Color {
    switch prayer {
    case "Fajr":
        return Color.blue.opacity(0.15)
    case "Dhuhr":
        return Color.blue.opacity(0.1)
    case "Asr":
        return Color.orange.opacity(0.1)
    case "Maghrib":
        return Color.purple.opacity(0.2)
    case "Isha":
        return Color.black.opacity(0.1)
    default:
        return Color.gray.opacity(0.15)
    }
}
