//
//  FakeData.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/18/25.
//
import SwiftUI

class FakeProgressManager: ObservableObject {
    @Published var currentStreak: Int
    @Published var totalPoints: Int
    @Published var completedModules: Int
    @Published var totalModules: Int
    
    init(
        currentStreak: Int = 0,
        totalPoints: Int = 0,
        completedModules: Int = 0,
        totalModules: Int = 0
    ) {
        self.currentStreak = currentStreak
        self.totalPoints = totalPoints
        self.completedModules = completedModules
        self.totalModules = totalModules
    }
}
