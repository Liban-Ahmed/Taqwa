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
    
    // Tracks which category is currently selected (for filter)
    @State private var selectedCategory: Achievement.AchievementType? = nil
    
    var body: some View {
        ZStack {
            // MARK: - Background
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
                    // MARK: - Top Summary Card
                    AchievementSummaryCard(
                        totalPoints: progressManager.totalPoints,
                        achievements: achievementManager.achievements
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // MARK: - Category Filter Section
                    CategoryFilterSection(
                        selectedCategory: $selectedCategory,
                        achievements: achievementManager.achievements
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Achievements List
                    AchievementsListView(
                        achievements: filteredAchievements,
                        onAchievementTap: { achievement in
                            // Optional: handle taps, show details, etc.
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Filters achievements by the selected category, if any
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.achievements.filter { $0.type == category }
        } else {
            return achievementManager.achievements
        }
    }
}

// MARK: - AchievementSummaryCard
struct AchievementSummaryCard: View {
    let totalPoints: Int
    let achievements: [Achievement]
    
    var body: some View {
        VStack(spacing: 20) {
            // 1) Total Points
            VStack(spacing: 8) {
                Text("\(totalPoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                Text("Total Points")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // 2) Achievements Progress (Unlocked / Total)
            let unlockedCount = achievements.filter(\.isUnlocked).count
            let totalCount = achievements.count
            let progressValue = Double(unlockedCount) / Double(totalCount == 0 ? 1 : totalCount)
            
            ZStack {
                CircularProgressViewOne(
                    progress: progressValue,
                    size: 100,
                    lineWidth: 10
                )
                // Show fraction inside the circle
                Text("\(unlockedCount)/\(totalCount)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - CategoryFilterSection
/// Displays categories in a horizontal scroll, allowing users to filter achievements.
/// Feel free to switch this to a LazyVGrid if you prefer a grid layout.
struct CategoryFilterSection: View {
    @Binding var selectedCategory: Achievement.AchievementType?
    let achievements: [Achievement]
    
    // Use a horizontal scroll of the known categories
    let columns = [
        GridItem(.flexible(minimum: 80), spacing: 16),
        GridItem(.flexible(minimum: 80), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // "All" category
                    CategoryCard(
                        label: "All",
                        unlockedCount: achievements.filter(\.isUnlocked).count,
                        totalCount: achievements.count,
                        isSelected: selectedCategory == nil,
                        onTap: { selectedCategory = nil }
                    )
                    
                    // For each achievement type
                    ForEach(Achievement.AchievementType.allCases, id: \.self) { category in
                        let typedAchievements = achievements.filter { $0.type == category }
                        let unlockedCount = typedAchievements.filter(\.isUnlocked).count
                        CategoryCard(
                            label: category.rawValue.capitalized,
                            unlockedCount: unlockedCount,
                            totalCount: typedAchievements.count,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - CategoryCard
struct CategoryCard: View {
    let label: String
    let unlockedCount: Int
    let totalCount: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text("\(unlockedCount)/\(totalCount)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onTapGesture {
            onTap()
        }
    }
}
// MARK: - AchievementsListView
struct AchievementsListView: View {
    let achievements: [Achievement]
    let onAchievementTap: (Achievement) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            if achievements.isEmpty {
                Text("No achievements here yet.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 20)
            } else {
                ForEach(achievements) { achievement in
                    EnhancedAchievementRow(achievement: achievement)
                        .onTapGesture {
                            onAchievementTap(achievement)
                        }
                }
            }
        }
    }
}

// MARK: - EnhancedAchievementRow
struct EnhancedAchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            achievementIcon
            
            // Title & Description
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                if achievement.isUnlocked {
                    unlockedStatus
                } else {
                    lockedProgressBar
                }
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: Icon
    private var achievementIcon: some View {
        ZStack {
            Circle()
                .fill(
                    achievement.isUnlocked
                    ? LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      )
                    : LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      )
                )
                .frame(width: 50, height: 50)
            
            Image(systemName: achievement.icon)
                .font(.system(size: 22))
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
        }
    }
    
    // MARK: Unlocked Status (Points & Date)
    private var unlockedStatus: some View {
        HStack(spacing: 12) {
            // Points awarded
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                Text("+\(achievement.points)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
            
            // Relative date unlocked
            if let date = achievement.unlockedAt {
                Text("Unlocked \(date, style: .relative)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.top, 2)
    }
    
    // MARK: Locked ProgressBar
    private var lockedProgressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            ProgressView(value: calculateProgress(for: achievement))
                .tint(.blue)
                .frame(height: 6)
                .clipShape(Capsule())
        }
    }
    
    // Calculate how far the user is from unlocking
    private func calculateProgress(for achievement: Achievement) -> Double {
        let progressManager = LearningProgressManager.shared
        
        // Adjust logic to your actual progress metrics:
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
        
        let requirement = Double(achievement.requirement)
        return min(progress / max(requirement, 1.0), 1.0)
    }
}

// MARK: - CircularProgressViewOne (unchanged)
struct CircularProgressViewOne: View {
    let progress: Double
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
