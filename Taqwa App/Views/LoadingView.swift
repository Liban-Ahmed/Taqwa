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
    @State private var opacity: Double = 0.6
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .opacity(isLoading ? 0 : 1)
            
            if isLoading {
                ZStack {
                    // Islamic-themed gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.05, blue: 0.15),
                            Color(red: 0.1, green: 0.1, blue: 0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    // Crescent moon with glow
                    ZStack {
                        // Outer glow
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white)
                            .opacity(0.3)
                            .blur(radius: 10)
                        
                        // Main crescent
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotation))
                            .scaleEffect(scale)
                            .opacity(opacity)
                    }
                    .shadow(color: .white.opacity(0.5), radius: 20)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                opacity = 1.0
                scale = 1.1
            }
            
            withAnimation(
                Animation
                    .linear(duration: 8)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isLoading = false
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Taqwa App")
    }
}
