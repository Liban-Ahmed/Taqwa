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
        VStack(spacing: 20) {
            // Overall Stats
            VStack(spacing: 16) {
                statsCard(
                    title: "Total Attempts",
                    value: "\(progressManager.totalQuizAttempts)",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                statsCard(
                    title: "Average Score",
                    value: String(format: "%.1f%%", progressManager.averageScore),
                    icon: "percent",
                    color: .green
                )
                
                statsCard(
                    title: "Total Points",
                    value: "\(progressManager.totalPoints)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                statsCard(
                    title: "Current Streak",
                    value: "\(progressManager.streak) days",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
