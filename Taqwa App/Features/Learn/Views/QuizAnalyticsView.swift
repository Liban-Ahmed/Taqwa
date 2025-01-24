//
//  QuizAnalyticsView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/20/25.
//

// QuizAnalyticsView.swift
import SwiftUI

struct QuizAnalyticsView: View {
    @ObservedObject private var progressManager = LearningProgressManager.shared
    
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.30),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    Text("Quiz Analytics")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 16)
                    
                    // MARK: - Average Score Ring
                    averageScoreRing
                        .padding(.horizontal)
                    
                    // MARK: - Stats Grid
                    statsGrid
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Average Score Ring
    /// A ring chart that visually displays the user's average quiz score.
    private var averageScoreRing: some View {
        let scoreFraction = progressManager.averageScore / 100.0
        
        return VStack(spacing: 12) {
            Text("Average Score")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ZStack {
                CircularProgressViewOne(
                    progress: scoreFraction,
                    size: 120,
                    lineWidth: 10
                )
                // Shows the numeric average in the center
                Text("\(String(format: "%.1f%%", progressManager.averageScore))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Stats Grid
    /// Displays total attempts, total points, streak, etc. in a 2-column grid.
    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
        ) {
            StatsCard(
                title: "Total Attempts",
                value: "\(progressManager.totalQuizAttempts)",
                icon: "chart.bar.fill",
                iconColor: .blue
            )
            
            StatsCard(
                title: "Total Points",
                value: "\(progressManager.totalPoints)",
                icon: "star.fill",
                iconColor: .yellow
            )
            
            StatsCard(
                title: "Current Streak",
                value: "\(progressManager.streak) days",
                icon: "flame.fill",
                iconColor: .orange
            )
            
            // Add additional stats if needed:
            // e.g. top quiz topic, best streak, etc.
        }
        .padding(.horizontal)
    }
}

// MARK: - StatsCard
/// A reusable card for displaying a small piece of stats data (icon + label + value).
struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - CircularProgressViewOne (reuse the same as in Achievements)
struct CircularProgressViewTwo: View {
    let progress: Double    // range 0.0 to 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}
