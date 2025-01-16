//
//  SettingsView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("calculationMethod") private var calculationMethod = "North America"
    @AppStorage("madhab") private var madhab = "Hanafi"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("hijriAdjustment") private var hijriAdjustment = 0
    @AppStorage("adhanSound") private var adhanSound = "Default"
    private let adhanSounds = ["Default", "Makkah", "Madinah", "Custom"]
    
    private let calculationMethods = [
        "North America",
        "Muslim World League",
        "Egyptian",
        "Umm Al-Qura",
        "Dubai",
        "Kuwait"
    ]
    
    
    private let madhabs = ["Hanafi", "Shafi"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.10, blue: 0.30),
                        Color(red: 0.50, green: 0.25, blue: 0.60)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack(spacing: 2) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Settings")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Prayer Settings
                        settingsGroup("Prayer Calculation") {
                            VStack(spacing: 16) {
                                // Calculation Method
                                VStack(alignment: .leading, spacing: 6) {
                                    SettingsRow(icon: "globe", iconColor: .blue) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Calculation Method")
                                                    .font(.system(size: 17, weight: .semibold))
                                                Spacer()
                                                Picker("", selection: $calculationMethod) {
                                                    ForEach(calculationMethods, id: \.self) { method in
                                                        Text(method).tag(method)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                            }
                                            
                                            Text("Choose your regional method for accurate prayer times")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                // Madhab Selection
                                VStack(alignment: .leading, spacing: 6) {
                                    SettingsRow(icon: "building.columns.fill", iconColor: .green) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Madhab")
                                                    .font(.system(size: 17, weight: .semibold))
                                                Spacer()
                                                Picker("", selection: $madhab) {
                                                    ForEach(madhabs, id: \.self) { madhab in
                                                        Text(madhab).tag(madhab)
                                                    }
                                                }
                                                .pickerStyle(.menu)
                                            }
                                            
                                            Text("Select your preferred Islamic jurisprudence")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Notifications
                            settingsGroup("Notifications") {
                                SettingsRow(icon: "bell.fill", iconColor: .orange) {
                                    Toggle("Prayer Time Alerts", isOn: $notificationsEnabled)
                                        .tint(.blue)
                                }
                            }
                            
                            // About Section
                            settingsGroup("About") {
                                SettingsRow(icon: "info.circle.fill", iconColor: .blue) {
                                    HStack {
                                        Text("Version")
                                        Spacer()
                                        Text("1.0.0")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                SettingsRow(icon: "envelope.fill", iconColor: .green) {
                                    Button(action: {
                                        if let url = URL(string: "mailto:feedback@example.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Text("Send Feedback")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                SettingsRow(icon: "lock.fill", iconColor: .purple) {
                                    Link(destination: URL(string: "https://example.com/privacy")!) {
                                        HStack {
                                            Text("Privacy Policy")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header with improved visibility
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 4)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .offset(y: 24)
                        .foregroundColor(.white.opacity(0.1))
                )
            
            // Content Container
            VStack(spacing: 2) {
                content()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 15,
                        x: 0,
                        y: 5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.bottom, 8)
    }
    
    // Enhanced settings row with better touch feedback
    struct SettingsRow<Content: View>: View {
        let icon: String
        let iconColor: Color
        let content: Content
        @State private var isPressed = false
        
        init(icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
            self.icon = icon
            self.iconColor = iconColor
            self.content = content()
        }
        
        var body: some View {
            HStack(spacing: 16) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                content
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isPressed)
            // Gesture handling for visual feedback
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isPressed = false
                    }
                }
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}
