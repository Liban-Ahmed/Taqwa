import SwiftUI
import Combine

struct SmoothCompassView: View {
    // MARK: - External Inputs
    /// The *immediate* device heading you get from your view model.
    let deviceHeading: Double
    /// The *immediate* Qibla bearing you get from your view model.
    let qiblaBearing: Double
    /// Whether the user is currently aligned within some threshold.
    let isAligned: Bool
    
    // MARK: - Internal Smoothed States
    @State private var displayedDeviceHeading: Double = 0.0
    @State private var displayedQiblaBearing: Double = 0.0
    
    // MARK: - Timer & Smoothing
    /// We’ll drive a smooth update using a timer that fires ~60 times per second.
    @State private var smoothingTimer: Timer?
    /// Factor controlling how quickly we approach the target. 0.1 = move 10% each frame.
    private let lerpFactor = 0.9
    
    // MARK: - Configuration
    private let cardinalAngles: [Double] = [0, 90, 180, 270]
    private let secondaryAngles: [Double] = [45, 135, 225, 315]
    private let tickMarks: [Double] = Array(stride(from: 0, through: 350, by: 10))
    
    private let alignedColor = Color(red: 0.3, green: 0.8, blue: 0.4)
    private let normalColor = Color.white
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            
            ZStack {
                // Background Rings
                Circle()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: size * 0.01)
                
                Circle()
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: size * 0.005)
                    .frame(width: size * 0.85, height: size * 0.85)
                
                // Compass Ticks & Labels (rotated by smoothed displayedDeviceHeading)
                compassMarks(size: size)
                    .rotationEffect(.degrees(-displayedDeviceHeading))
                
                // Qibla Pointer (rotated by difference between displayedQiblaBearing & displayedDeviceHeading)
                qiblaPointer(size: size)
                    .rotationEffect(.degrees(displayedQiblaBearing - displayedDeviceHeading))
                
                // Center Dot
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                isAligned ? alignedColor : normalColor,
                                (isAligned ? alignedColor : normalColor).opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.05
                        )
                    )
                    .frame(width: size * 0.07, height: size * 0.07)
                    .shadow(color: isAligned ? alignedColor : normalColor, radius: size * 0.02)
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            // Initialize displayed headings
            displayedDeviceHeading = deviceHeading
            displayedQiblaBearing = qiblaBearing
            
            // Start smoothing timer
            startSmoothingTimer()
        }
        .onDisappear {
            // Stop the timer to avoid resource consumption
            stopSmoothingTimer()
        }
        .onChange(of: deviceHeading) { _ in
            // We only update the target; the timer handles smoothing
        }
        .onChange(of: qiblaBearing) { _ in
            // Same as above
        }
    }
}

// MARK: - Subviews
extension SmoothCompassView {
    private func compassMarks(size: CGFloat) -> some View {
        ZStack {
            // Tick Marks
            ForEach(tickMarks, id: \.self) { angle in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(
                        width: angle.truncatingRemainder(dividingBy: 30) == 0 ? 2 : 1,
                        height: angle.truncatingRemainder(dividingBy: 30) == 0 ? size * 0.08 : size * 0.05
                    )
                    .offset(y: -size * 0.45)
                    .rotationEffect(.degrees(angle))
                    .accessibilityHidden(true)
            }
            
            // Primary Cardinal Points
            ForEach(cardinalAngles, id: \.self) { angle in
                Text(cardinalPoint(for: angle))
                    .font(.system(size: size * 0.06, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.8))
                    .offset(y: -size * 0.45)
                    .rotationEffect(.degrees(angle))
                    .accessibilityLabel(cardinalPoint(for: angle))
            }
            
            // Secondary Directions (NE, SE, SW, NW)
            ForEach(secondaryAngles, id: \.self) { angle in
                Text(cardinalPoint(for: angle))
                    .font(.system(size: size * 0.04, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
                    .offset(y: -size * 0.45)
                    .rotationEffect(.degrees(angle))
                    .accessibilityLabel(cardinalPoint(for: angle))
            }
        }
    }
    
    private func qiblaPointer(size: CGFloat) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "location.north.line.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.1, height: size * 0.1)
                .foregroundColor(isAligned ? alignedColor : normalColor)
                .shadow(color: isAligned ? alignedColor : normalColor, radius: size * 0.01)
            
            Rectangle()
                .fill(isAligned ? alignedColor : normalColor)
                .frame(width: size * 0.007, height: size * 0.35)
        }
        .accessibilityLabel("Qibla direction")
        .accessibilityValue(isAligned ? "Aligned" : "Not aligned")
    }
}

// MARK: - Timer-based Smoothing
extension SmoothCompassView {
    /// Create and start a 60 Hz timer that updates heading values incrementally toward the target.
    private func startSmoothingTimer() {
        stopSmoothingTimer()
        
        let interval = 1.0 / 60.0  // 60 FPS
        smoothingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            updateDisplayedHeadings()
        }
    }
    
    /// Invalidate the timer when the view disappears or when no longer needed.
    private func stopSmoothingTimer() {
        smoothingTimer?.invalidate()
        smoothingTimer = nil
    }
    
    /// Each tick, move `displayedHeading` closer to `deviceHeading` by `lerpFactor`.
    private func updateDisplayedHeadings() {
        // Move device heading
        displayedDeviceHeading = lerpAngle(
            current: displayedDeviceHeading,
            target: deviceHeading,
            factor: lerpFactor
        )
        
        // Move Qibla heading
        displayedQiblaBearing = lerpAngle(
            current: displayedQiblaBearing,
            target: qiblaBearing,
            factor: lerpFactor
        )
    }
    
    /**
     Linearly interpolates angle in a minimal arc.
     - parameters:
       - current: current angle (0...360)
       - target: target angle (0...360)
       - factor: fraction [0...1] to move each step
     - returns: new smoothed angle
    */
    private func lerpAngle(current: Double, target: Double, factor: Double) -> Double {
        // 1) Find minimal difference in range [−180, 180]
        var diff = (target - current).truncatingRemainder(dividingBy: 360)
        if diff > 180  { diff -= 360 }
        if diff < -180 { diff += 360 }
        
        // 2) Move a fraction 'factor' of diff
        let newAngle = current + diff * factor
        
        // 3) Normalize [0, 360)
        var normalized = newAngle.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        
        return normalized
    }
}

// MARK: - Helpers
extension SmoothCompassView {
    private func cardinalPoint(for angle: Double) -> String {
        switch angle {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
}
