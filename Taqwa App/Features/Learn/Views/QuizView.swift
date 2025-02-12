//
//  QuizView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//

import SwiftUI

struct QuizView: View {
    let moduleId: Int
    let lessonId: Int
    let questions: [QuizQuestion]
    private let progressManager = LearningProgressManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showScore = false
    @State private var isAnswerLocked = false
    @State private var wrongAnswers: [QuizProgress.WrongAnswer] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.30),
                    Color(red: 0.50, green: 0.25, blue: 0.60)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                if showScore {
                    scoreView
                } else {
                    quizContent
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Back button and progress
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back to Lesson")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                if !showScore {
                    Text("Score: \(score)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Progress bars
            if !showScore {
                progressBars
            }
        }
        .padding(.top, 16)
        .background(.ultraThinMaterial.opacity(0.3))
    }
    
    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(0..<questions.count, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .overlay(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.75, blue: 0.45),
                                        Color(red: 1.00, green: 0.88, blue: 0.60)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(index <= currentQuestionIndex ? 1 : 0)
                    )
                    .frame(height: 3)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var quizContent: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Question number
            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            // Question
            Text(questions[currentQuestionIndex].question)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Options
            VStack(spacing: 16) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button {
                        if !isAnswerLocked {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectAnswer(index)
                            }
                        }
                    } label: {
                        Text(questions[currentQuestionIndex].options[index])
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(backgroundColor(for: index))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    }
                    .scaleEffect(selectedAnswer == index ? 0.98 : 1)
                    .disabled(isAnswerLocked)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    private var scoreView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Existing score summary
                VStack(spacing: 16) {
                    Text("Quiz Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(score) out of \(questions.count) correct")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Percentage and message
                    VStack(spacing: 8) {
                        Text("\(Int((Double(score) / Double(questions.count)) * 100))%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(scoreMessage)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 32)
                
                // Review Section for wrong answers
                if !wrongAnswers.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Review Incorrect Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(wrongAnswers, id: \.questionId) { wrong in
                            if let question = questions.first(where: { $0.id == wrong.questionId }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(question.question)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                            Text("Your answer: \(question.options[wrong.selectedAnswer])")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Correct: \(question.options[wrong.correctAnswer])")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: { resetQuiz() }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(12)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Back to Lesson")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
    
    private var scoreMessage: String {
        let percentage = Double(score) / Double(questions.count)
        switch percentage {
        case 1.0:
            return "Perfect! Excellent work!"
        case 0.8..<1.0:
            return "Great job! Keep it up!"
        case 0.6..<0.8:
            return "Good effort! Room for improvement."
        default:
            return "Keep practicing! You'll get better."
        }
    }
    
    private func backgroundColor(for index: Int) -> Color {
        guard let selectedAnswer = selectedAnswer else {
            return Color.white.opacity(0.15)
        }
        
        if index == selectedAnswer {
            if index == questions[currentQuestionIndex].correctIndex {
                return Color.green.opacity(0.3)
            } else {
                return Color.red.opacity(0.3)
            }
        }
        
        if isAnswerLocked && index == questions[currentQuestionIndex].correctIndex {
            return Color.green.opacity(0.3)
        }
        
        return Color.white.opacity(0.15)
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        isAnswerLocked = true
        
        // Track wrong answers
        if index != questions[currentQuestionIndex].correctIndex {
            wrongAnswers.append(QuizProgress.WrongAnswer(
                questionId: questions[currentQuestionIndex].id,
                selectedAnswer: index,
                correctAnswer: questions[currentQuestionIndex].correctIndex,
                timestamp: Date()
            ))
        }
        
        if index == questions[currentQuestionIndex].correctIndex {
            score += 1
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestionIndex < questions.count - 1 {
                withAnimation {
                    currentQuestionIndex += 1
                    selectedAnswer = nil
                    isAnswerLocked = false
                }
            } else {
                finishQuiz()
                withAnimation {
                    showScore = true
                }
            }
        }
    }
    private func finishQuiz() {
        let percentage = Double(score) / Double(questions.count)
        progressManager.saveQuizProgress(
            moduleId: moduleId,
            lessonId: lessonId,
            score: Int(percentage * 100),
            wrongAnswers: wrongAnswers
        )
    }
    
    
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        score = 0
        isAnswerLocked = false
        showScore = false
        wrongAnswers.removeAll()
    }
    // Add review section to scoreView
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !wrongAnswers.isEmpty {
                Text("Review Incorrect Answers")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ForEach(wrongAnswers, id: \.questionId) { wrong in
                    let question = questions.first { $0.id == wrong.questionId }!
                    VStack(alignment: .leading, spacing: 8) {
                        Text(question.question)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("Your answer: \(question.options[wrong.selectedAnswer])")
                            .foregroundColor(.red.opacity(0.8))
                        
                        Text("Correct answer: \(question.options[wrong.correctAnswer])")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
    
}

