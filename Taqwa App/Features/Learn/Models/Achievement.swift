//
//  Achievement.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/21/25.
//
import SwiftUI

public struct Achievement: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let points: Int
    public let icon: String
    public let type: AchievementType
    public let requirement: Int
    public var isUnlocked: Bool
    public var unlockedAt: Date?
    
    public enum AchievementType: String, Codable {
        case lessonCompletion
        case quizMastery
        case streak
        case totalPoints
        case perfectQuiz
    }
    public static func == (lhs: Achievement, rhs: Achievement) -> Bool {
            return lhs.id == rhs.id
        }
}

struct AchievementNotification: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked!")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(achievement.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("+\(achievement.points) points")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
