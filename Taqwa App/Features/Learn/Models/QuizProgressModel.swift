//
//  QuizProgressModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/20/25.
//
import SwiftUI

struct QuizProgress: Codable {
    let moduleId: Int
    let lessonId: Int
    let attempts: Int
    let bestScore: Int
    let lastScore: Int
    let completedAt: Date
    var wrongAnswers: [WrongAnswer]
    
    struct WrongAnswer: Codable {
        let questionId: Int
        let selectedAnswer: Int
        let correctAnswer: Int
        let timestamp: Date
    }
}
