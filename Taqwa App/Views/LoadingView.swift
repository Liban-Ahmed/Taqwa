//
//  LoadingView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/1/25.
//

import SwiftUI

struct LoadingView<Content: View>: View {
    @State private var isLoading = true
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0
    let content: Content
    
    private let gradientColors = [
        Color(red: 0.05, green: 0.05, blue: 0.15),
        Color(red: 0.1, green: 0.1, blue: 0.2)
    ]
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
            
            if isLoading {
                ZStack {
                    // Enhanced gradient background
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Loading elements
                    VStack(spacing: 24) {
                        // Enhanced crescent moon
                        ZStack {
                            // Outer glow layer
                            ForEach(0..<3) { i in
                                Image(systemName: "moon.stars.fill")
                                    .resizable()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.white)
                                    .opacity(0.15)
                                    .blur(radius: CGFloat(i + 1) * 5)
                                    .opacity(glowOpacity)
                            }
                            
                            // Main crescent
                            Image(systemName: "moon.stars.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(rotation))
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .shadow(color: .white.opacity(0.5), radius: 10)
                        }
                        
                        
                    }
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            startAnimations()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Taqwa App")
    }
    
    private func startAnimations() {
        // Fade in
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1
            glowOpacity = 1
        }
        
        // Continuous rotation
        withAnimation(
            .linear(duration: 8)
            .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
        
        // Breathing effect
        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            scale = 1.1
        }
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                isLoading = false
            }
        }
    }
}
