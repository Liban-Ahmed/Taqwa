//
//  TopSectionView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import SwiftUI

struct TopSectionView: View {
    let currentPrayer: String = "Fajr"
    let timeRemaining: String
//    let progress: Double  // 0...1 representing the day's progression

    @State var fakeScrollOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 1. Sky / Background Gradient
            backgroundGradient(for: currentPrayer)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // (A) Unified Curved Timeline Section
                // MOVED PARABOLA DOWN
                timelineSection
                    .padding(.top, 60) // was .padding(.top, 20)

                // (B) Current Prayer Name & Time - top-left aligned
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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
                    .padding(.leading, 30)  // Push from left
                    Spacer()
                }
                // MOVED TEXT UP
                .padding(.top, -140)

                // (C) Mountainous Landscape + Pine Trees + Parallax
                MountainRangeView(currentPrayer: currentPrayer,
                                  scrollOffset: fakeScrollOffset)
                    .frame(height: 120)
                    .padding(.top, 20)
                    // Parallax effect
                    .offset(y: parallaxOffset(base: 0.0, rate: 0.3))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
        .cornerRadius(25)
        .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
        // Simple drag gesture for parallax
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
