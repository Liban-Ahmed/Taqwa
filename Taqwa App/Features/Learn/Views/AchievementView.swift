//
//  AchievementView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/21/25.
//
import SwiftUI

struct EnhancedAchievementView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var progressManager = LearningProgressManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                achievementSummaryCard
                
                // Achievement Categories
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(Achievement.AchievementType.allCases, id: \.self) { category in
                        categoryCard(for: category)
                    }
                }
                .padding()
                
                // Achievement List
                VStack(spacing: 16) {
                    ForEach(achievementManager.achievements) { achievement in
                        EnhancedAchievementRow(achievement: achievement)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .background(Color(.systemGroupedBackground))
    }
    
    private func categoryCard(for category: Achievement.AchievementType) -> some View {
        VStack {
            Text(category.rawValue.capitalized)
                .font(.headline)
            let count = achievementManager.achievements
                .filter { $0.type == category && $0.isUnlocked }
                .count
            Text("\(count) Unlocked")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var achievementSummaryCard: some View {
        VStack(spacing: 16) {
            Text("\(progressManager.totalPoints)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            Text("Total Points")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            let unlockedCount = achievementManager.achievements.filter(\.isUnlocked).count
            let totalCount = achievementManager.achievements.count
            
            CircularProgressViewOne(progress: Double(unlockedCount) / Double(totalCount))
                .frame(width: 80, height: 80)
                .overlay(
                    Text("\(unlockedCount)/\(totalCount)")
                        .font(.caption)
                )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CircularProgressViewOne: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
            )
    }
}

struct EnhancedAchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(achievement.points)")
                            .font(.caption)
                            .foregroundColor(.green)
                        if let date = achievement.unlockedAt {
                                        Text(date, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                    }
                } else {
                    ProgressView(value: calculateProgress(for: achievement))
                        .tint(.blue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func calculateProgress(for achievement: Achievement) -> Double {
            let progressManager = LearningProgressManager.shared
            
            let progress = switch achievement.type {
            case .lessonCompletion:
                Double(progressManager.getCompletedLessons().count)
            case .streak:
                Double(progressManager.streak)
            case .totalPoints:
                Double(progressManager.totalPoints)
            case .perfectQuiz, .quizMastery:
                Double(progressManager.totalQuizAttempts)
            }
            
            return min(progress / Double(achievement.requirement), 1.0)
        }
}
