//
//  TopSectionView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct TopSectionView: View {
    let currentPrayer: String
    let timeRemaining: String          
    let progress: Double

    // Example scroll offset for parallax; in a real app, pass real data
    @State private var fakeScrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 1. Sky / Background Gradient
            backgroundGradient(for: currentPrayer)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // (A) Unified Curved Timeline Section
                timelineSection
                    .padding(.top, 20)

                // (B) Current Prayer Name & Time - top-right aligned
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: systemIcon(for: currentPrayer))
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 0)
                            Text(currentPrayer)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Text(timeRemaining)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.trailing, 30)
                }
                .padding(.top, -16)

                // (C) Mountainous Landscape + Pine Trees + Parallax
                MountainRangeView(currentPrayer: currentPrayer,
                                  scrollOffset: fakeScrollOffset)
                    .frame(height: 120)
                    .padding(.top, 20)
                    // Parallax effect
                    .offset(y: parallaxOffset(base: 0.0, rate: 0.3))

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 320)
        .cornerRadius(25)
        .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        // Example drag to demonstrate parallax
        .gesture(
            DragGesture()
                .onChanged { value in
                    fakeScrollOffset = value.translation.height
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        fakeScrollOffset = 0
                    }
                }
        )
    }
}

// MARK: - UNIFIED TIMELINE SECTION (Curve + Prayer Markers + Sun/Moon Progress)
extension TopSectionView {
    private var timelineSection: some View {
        ZStack {
            // 1. Curved Path for the whole day
            CurvedDayPath()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(height: 100)

            // 2. Colored stroke overlay for "progress" portion
            CurvedDayPath()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color.white.opacity(0.6),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(height: 100)
                .animation(.easeInOut(duration: 0.8), value: progress)

            // 4. Sun/Moon indicator at left -> right
            SunMoonIndicator(progress: progress, isDaytime: isDaytime)
                // Approximate horizontal offset along the curve
                .offset(x: offsetX(progress: progress), y: offsetY(progress: progress))
                .animation(.easeInOut(duration: 1), value: progress)
        }
        .padding(.horizontal, 30)
    }

    /// Decide daytime or nighttime visually
    private var isDaytime: Bool {
        progress < 0.5
    }

    /// Very rough X offset for sun/moon (left to right)
    private func offsetX(progress: Double) -> CGFloat {
        // The curve is about 300px wide in the center
        let totalWidth: CGFloat = 300
        return (CGFloat(progress) * totalWidth) - totalWidth/2
    }

    /// Slight arc for Y offset
    private func offsetY(progress: Double) -> CGFloat {
        let arcHeight: CGFloat = 30
        // Parabolic arc peaking in the middle (progress=0.5)
        let x = progress - 0.5
        let y = -(arcHeight - (arcHeight * (x * x * 4)))  // simple parabola
        return y - 10
    }
}

// MARK: - BACKGROUND GRADIENT PER PRAYER
extension TopSectionView {
    private func backgroundGradient(for prayer: String) -> LinearGradient {
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
                gradient: Gradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private func parallaxOffset(base: CGFloat, rate: CGFloat) -> CGFloat {
        base + fakeScrollOffset * rate
    }

    private func systemIcon(for prayer: String) -> String {
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

// MARK: - CURVED SHAPE FOR THE TIMELINE
struct CurvedDayPath: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.width
            let h = rect.height
            path.move(to: CGPoint(x: 0, y: h))
            // A smooth cubic curve across the bottom
            path.addCurve(
                to: CGPoint(x: w, y: h),
                control1: CGPoint(x: w * 0.3, y: 0),
                control2: CGPoint(x: w * 0.7, y: 0)
            )
        }
    }
}

// MARK: - PRAYER MARKERS (dots + labels)
struct PrayerMarkers: View {
    let prayers: [String]
    let currentPrayer: String

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height * 0.9

            ForEach(prayers.indices, id: \.self) { i in
                let prayer = prayers[i]
                // Distribute horizontally
                let xPos = w * CGFloat(i) / CGFloat(prayers.count - 1)
                // Minimal vertical offset so they follow the curve silhouette
                let yPos = h - smallArcOffset(i, total: prayers.count)

                VStack(spacing: 4) {
                    Circle()
                        .fill(prayer == currentPrayer ? Color.orange : Color.white.opacity(0.6))
                        .frame(width: prayer == currentPrayer ? 10 : 6,
                               height: prayer == currentPrayer ? 10 : 6)
                        .shadow(color: prayer == currentPrayer ? Color.orange.opacity(0.5) : .clear,
                                radius: 6, x: 0, y: 0)

                    Text(prayer)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                .position(x: xPos, y: yPos)
                .onTapGesture {
                    print("\(prayer) tapped")
                }
            }
        }
    }

    /// A small function to nudge the markers into a slight arc
    private func smallArcOffset(_ index: Int, total: Int) -> CGFloat {
        // e.g. a shallow parabola
        let mid = Double(total - 1) / 2
        let dist = Double(index) - mid
        return CGFloat(8 - dist * dist)
    }
}

// MARK: - SUN / MOON INDICATOR (Minimal Pulsation)
struct SunMoonIndicator: View {
    let progress: Double
    let isDaytime: Bool

    @State private var pulsate: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            (isDaytime ? Color.yellow : .white).opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    ),
                    lineWidth: 3
                )
                .frame(width: 34, height: 34)
                .opacity(0.4)

            Circle()
                .fill(isDaytime ? .yellow : .white)
                .frame(width: 24, height: 24)
                .scaleEffect(pulsate ? 1.03 : 0.97)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: pulsate)
        }
        .onAppear {
            pulsate = true
        }
    }
}

// MARK: - MOUNTAIN RANGE
struct MountainRangeView: View {
    let currentPrayer: String
    let scrollOffset: CGFloat

    var body: some View {
        ZStack {
            // Back mountain
            BackMountainView(currentPrayer: currentPrayer)
                .offset(x: scrollOffset * 0.15)

            // Front mountain
            FrontMountainView(currentPrayer: currentPrayer)
                .offset(y: 10)
                .offset(x: scrollOffset * 0.1)

            // Pine trees
            PineTreeGroup()
                .offset(y: 40)
                .offset(x: scrollOffset * 0.05)
        }
    }
}

// MARK: - BACK MOUNTAIN
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

// MARK: - FRONT MOUNTAIN
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

// MARK: - MOUNTAIN COLOR HELPERS
private func mountainBaseColor(for prayer: String) -> Color {
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

private func mountainPeakColor(for prayer: String) -> Color {
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

// MARK: - PINETREE GROUP
struct PineTreeGroup: View {
    var body: some View {
        HStack(spacing: 32) {
            ForEach(0..<5) { i in
                PineTreeView(scale: i.isMultiple(of: 2) ? 1.0 : 0.8)
            }
        }
    }
}

// MARK: - PINE TREE VIEW (Minimal side-to-side sway)
struct PineTreeView: View {
    let scale: CGFloat
    @State private var sway: Bool = false

    var body: some View {
        ZStack {
            // Trunk
            Rectangle()
                .fill(Color.brown)
                .frame(width: 4, height: 24)
                .offset(y: 12)

            // Pine shape: stacked triangles
            VStack(spacing: -6) {
                Triangle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: 28, height: 20)
                Triangle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: 22, height: 16)
                Triangle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: 16, height: 12)
            }
            .offset(y: -6)
        }
        .rotationEffect(.degrees(sway ? 0.5 : -0.5), anchor: .bottom)
        .scaleEffect(sway ? scale * 1.01 : scale * 0.99, anchor: .bottom)
        .onAppear {
            sway = true
        }
    }
}

// MARK: - TRIANGLE SHAPE
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
