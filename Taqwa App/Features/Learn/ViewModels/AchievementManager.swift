

import SwiftUI
import Combine

public class AchievementManager: ObservableObject {
    public static let shared = AchievementManager()
    private let defaults = UserDefaults.standard
    weak var progressManager: LearningProgressManagerType?
    
    @Published public private(set) var achievements: [Achievement] = []
    @Published public var recentlyUnlocked: Achievement?
    
    private enum Keys {
        static let unlockedAchievements = "unlockedAchievements"
    }
    
    private let defaultAchievements = [
        Achievement(
            id: "first_lesson",
            title: "First Steps",
            description: "Complete your first lesson",
            points: 50,
            icon: "flag.fill",
            type: .lessonCompletion,
            requirement: 1,
            isUnlocked: false,
            unlockedAt: nil
        ),
        Achievement(
            id: "perfect_quiz",
            title: "Perfect Score",
            description: "Get 100% on a quiz",
            points: 100,
            icon: "star.fill",
            type: .perfectQuiz,
            requirement: 1,
            isUnlocked: false,
            unlockedAt: nil
        ),
        Achievement(
            id: "streak_7",
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            points: 150,
            icon: "flame.fill",
            type: .streak,
            requirement: 7,
            isUnlocked: false,
            unlockedAt: nil
        ),
        Achievement(
            id: "lessons_10",
            title: "Knowledge Seeker",
            description: "Complete 10 lessons",
            points: 200,
            icon: "book.fill",
            type: .lessonCompletion,
            requirement: 10,
            isUnlocked: false,
            unlockedAt: nil
        )
    ]
    
    private init() {
        loadAchievements()
    }
    
    private func loadAchievements() {
        if let data = defaults.data(forKey: Keys.unlockedAchievements),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            achievements = defaultAchievements.map { achievement in
                var mutable = achievement
                if let unlockedDate = decoded[achievement.id] {
                    mutable.isUnlocked = true
                    mutable.unlockedAt = unlockedDate
                }
                return mutable
            }
        } else {
            achievements = defaultAchievements
        }
    }
    
    func checkAchievements() {
        // Guard against nil progressManager
        guard let manager = progressManager else { return }
        
        let completedLessons = manager.getCompletedLessons().count
        let currentStreak = manager.streak
        let totalPoints = manager.totalPoints
        
        for (index, achievement) in achievements.enumerated() where !achievement.isUnlocked {
            var shouldUnlock = false
            
            switch achievement.type {
            case .lessonCompletion:
                shouldUnlock = completedLessons >= achievement.requirement
            case .streak:
                shouldUnlock = currentStreak >= achievement.requirement
            case .totalPoints:
                shouldUnlock = totalPoints >= achievement.requirement
            case .perfectQuiz, .quizMastery:
                continue
            }
            
            if shouldUnlock {
                unlockAchievement(at: index)
            }
        }
    }
    
    func checkQuizAchievements(score: Int, total: Int) {
        if score == total {
            if let index = achievements.firstIndex(where: { $0.type == .perfectQuiz && !$0.isUnlocked }) {
                unlockAchievement(at: index)
            }
        }
    }
    
    private func unlockAchievement(at index: Int) {
        guard let manager = progressManager else { return }
        
        var achievement = achievements[index]
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        achievements[index] = achievement
        
        // Save to UserDefaults
        var unlockedAchievements = getUnlockedAchievements()
        unlockedAchievements[achievement.id] = achievement.unlockedAt
        if let encoded = try? JSONEncoder().encode(unlockedAchievements) {
            defaults.set(encoded, forKey: Keys.unlockedAchievements)
        }
        
        // Add points using safely unwrapped manager
        manager.addPoints(achievement.points)
        
        // Show notification
        recentlyUnlocked = achievement
    }
    
    private func getUnlockedAchievements() -> [String: Date] {
        guard let data = defaults.data(forKey: Keys.unlockedAchievements),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return decoded
    }
}
