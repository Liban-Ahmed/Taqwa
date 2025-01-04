//
//  GridLayoutView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/3/25.
//
import SwiftUI

struct GridLayoutView: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Prayer Tracker
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .tracker
                }
            } label: {
                GridCard(
                    title: "Prayer Tracker",
                    iconName: "chart.bar.fill",
                    color: .blue,
                    description: "Track your daily prayers"
                )
            }
            
            // Learn
            GridCard(
                title: "Learn",
                iconName: "book.fill",
                color: .green,
                description: "Islamic teachings"
            )
            
            // Qibla
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .qibla
                }
            } label: {
                GridCard(
                    title: "Qibla",
                    iconName: "location.north.line.fill",
                    color: .orange,
                    description: "Find prayer direction"
                )
            }
            
            // Nearby Mosques
            GridCard(
                title: "Nearby Mosques",
                iconName: "building.2.fill",
                color: .purple,
                description: "Find local mosques"
            )
        }
        .padding(.horizontal)
    }
}

struct GridCard: View {
    let title: String
    let iconName: String
    let color: Color
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}
