//
//  FakeData.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/18/25.
//
import SwiftUI

class FakeProgressManager: ObservableObject {
    @Published var currentStreak = 3
    @Published var totalPoints = 120
    @Published var completedModules = 2
    @Published var totalModules = 5
}

