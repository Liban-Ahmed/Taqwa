import SwiftUI
import Combine

struct CompassView: View {
    // MARK: - External Inputs
    let deviceHeading: Double
    let qiblaBearing: Double
    let isAligned: Bool
    
    // MARK: - Internal Smoothed States
    @State private var displayedDeviceHeading: Double = 0.0
    @State private var displayedQiblaBearing: Double = 0.0
    
    // MARK: - Timer & Smoothing
    @State private var smoothingTimer: Timer?
    private let lerpFactor = 0.9 // how quickly angles move toward target each frame
    
    // MARK: - Colors
    /// Base color for the arc and diamond (green in your screenshots).
    private let baseColor = Color.green
    
    /// The partial arc thickness as a fraction of the view size.
    private let arcThicknessFactor: CGFloat = 0.07
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            
            ZStack {
                // 1) Partial Arc
                PartialArcShape(startFraction: 0.25, endFraction: 0.85)
                    .stroke(
                        baseColor,
                        style: StrokeStyle(
                            lineWidth: size * arcThicknessFactor,
                            lineCap: .round
                        )
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90)) // so arc sits “on top” like the screenshots
                
                // 2) Center Diamond
                DiamondShape()
                    .fill(baseColor)
                    .frame(width: size * 0.4, height: size * 0.4)
                    .rotationEffect(.degrees(displayedQiblaBearing - displayedDeviceHeading))
                    .shadow(
                        color: baseColor.opacity(isAligned ? 1.0 : 0.0),
                        radius: isAligned ? size * 0.07 : 0
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAligned)
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            // Initialize displayed angles
            displayedDeviceHeading = deviceHeading
            displayedQiblaBearing = qiblaBearing
            startSmoothingTimer()
        }
        .onDisappear {
            stopSmoothingTimer()
        }
        // Whenever deviceHeading or qiblaBearing change, we let the timer smooth them out
        .onChange(of: deviceHeading) { _ in }
        .onChange(of: qiblaBearing) { _ in }
    }
}

// MARK: - Partial Arc Shape
/**
 Draws an arc of a circle from `startFraction` to `endFraction` of the full 360°.
 
 - Parameters:
   - startFraction: the fraction of the circle at which to start (0.0 -> 1.0)
   - endFraction: the fraction of the circle at which to end (0.0 -> 1.0)
 */
struct PartialArcShape: Shape {
    let startFraction: CGFloat
    let endFraction: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(360 * startFraction),
            endAngle: .degrees(360 * endFraction),
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Diamond Shape
/**
 A simple diamond: basically a square rotated 45° so that it “points” upward/downward.
 */
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        
        var path = Path()
        // Move to top center
        path.move(to: CGPoint(x: w / 2, y: 0))
        // Right center
        path.addLine(to: CGPoint(x: w, y: h / 2))
        // Bottom center
        path.addLine(to: CGPoint(x: w / 2, y: h))
        // Left center
        path.addLine(to: CGPoint(x: 0, y: h / 2))
        // Close path back to top center
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Timer-based Smoothing
extension CompassView {
    private func startSmoothingTimer() {
        stopSmoothingTimer()
        
        let interval = 1.0 / 60.0  // ~60 FPS
        smoothingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            updateDisplayedHeadings()
        }
    }
    
    private func stopSmoothingTimer() {
        smoothingTimer?.invalidate()
        smoothingTimer = nil
    }
    
    private func updateDisplayedHeadings() {
        displayedDeviceHeading = lerpAngle(
            current: displayedDeviceHeading,
            target: deviceHeading,
            factor: lerpFactor
        )
        displayedQiblaBearing = lerpAngle(
            current: displayedQiblaBearing,
            target: qiblaBearing,
            factor: lerpFactor
        )
    }
    
    /// Smooth angle interpolation, preserving minimal arcs in [−180, +180].
    private func lerpAngle(current: Double, target: Double, factor: Double) -> Double {
        var diff = (target - current).truncatingRemainder(dividingBy: 360)
        if diff > 180  { diff -= 360 }
        if diff < -180 { diff += 360 }
        
        let newAngle = current + diff * factor
        
        var normalized = newAngle.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        
        return normalized
    }
}
