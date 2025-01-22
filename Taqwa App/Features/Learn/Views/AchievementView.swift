//
//  AchievementView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/21/25.
//
import SwiftUI

struct AchievementView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    
    var body: some View {
        List {
            ForEach(achievementManager.achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
        .navigationTitle("Achievements")
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue : Color.gray)
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Achievement Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked {
                    Text("Unlocked: +\(achievement.points) points")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            // Lock/Unlock Status
            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .foregroundColor(achievement.isUnlocked ? .green : .gray)
        }
        .padding(.vertical, 8)
    }
}
