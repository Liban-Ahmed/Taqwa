//
//  GridLayoutView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/3/25.
//
import SwiftUI

struct GridLayoutView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Prayer Tracker
            NavigationLink(destination: TrackerView()) {
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
            NavigationLink(destination: QiblaView()) {
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
    }
}

struct GridCard: View {
    let title: String
    let iconName: String
    let color: Color
    let description: String
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
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
            
            // Title and Description
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
    }
}
