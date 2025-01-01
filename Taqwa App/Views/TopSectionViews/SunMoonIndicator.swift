//
//  SunMoonIndicator.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/31/24.
//

import SwiftUI
import CoreLocation
// MARK: - SUN / MOON INDICATOR (Colored Faded Rings)
struct SunMoonIndicator: View {
    let isDaytime: Bool

    var body: some View {
        ZStack {
            // Outer ring 3
            Circle()
                .fill((isDaytime ? Color.yellow : Color.white).opacity(0.1))
                .frame(width: 160, height: 160)
                .animation(nil, value: isDaytime)

            // Outer ring 2
            Circle()
                .fill((isDaytime ? Color.yellow : Color.white).opacity(0.2))
                .frame(width: 130, height: 130)
                .animation(nil, value: isDaytime)

            // Outer ring 1
            Circle()
                .fill((isDaytime ? Color.yellow : Color.white).opacity(0.3))
                .frame(width: 100, height: 100)
                .animation(nil, value: isDaytime)

            // Inner glowing circle
            Circle()
                .fill(isDaytime ? Color.yellow : Color.white)
                .frame(width: 70, height: 70)
                .shadow(
                    color: (isDaytime ? Color.yellow : Color.white).opacity(0.6),
                    radius: 10
                )
                .animation(nil, value: isDaytime)
        }
    }
}
