//
//  LearningModels.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import Foundation

struct Module: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let lessons: [Lesson]
}

struct Lesson: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String
    let audioFileName: String?
    let quizQuestions: [QuizQuestion]
}

struct QuizQuestion: Identifiable, Codable {
    let id: Int
    let question: String
    let options: [String]
    let correctIndex: Int
}
