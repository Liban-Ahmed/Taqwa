//
//  QuizView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//

import SwiftUI

struct QuizView: View {
    let questions: [QuizQuestion]
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showScore = false
    @State private var isAnswerLocked = false
    
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
            
            if showScore {
                scoreView
            } else {
                quizContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var quizContent: some View {
        VStack(spacing: 24) {
            progressHeader
            
            questionContent
            
            optionsGrid
        }
        .padding()
    }
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            // Progress indicator
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .foregroundColor(.white)
                Spacer()
                Text("Score: \(score)")
                    .foregroundColor(.white)
            }
            .font(.headline)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
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
                        .frame(width: geometry.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count), height: 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            .frame(height: 4)
        }
    }
    
    private var questionContent: some View {
        Text(questions[currentQuestionIndex].question)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical)
    }
    
    private var optionsGrid: some View {
        VStack(spacing: 16) {
            ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                Button {
                    if !isAnswerLocked {
                        selectAnswer(index)
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
                        )
                }
                .disabled(isAnswerLocked)
            }
        }
    }
    
    private var scoreView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Quiz Complete!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Your Score")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(score) out of \(questions.count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Button {
                dismiss()
            } label: {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.75, blue: 0.45),
                                Color(red: 1.00, green: 0.88, blue: 0.60)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.top, 32)
        }
        .padding()
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
        
        if index == questions[currentQuestionIndex].correctIndex {
            score += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
                isAnswerLocked = false
            } else {
                showScore = true
            }
        }
    }
}
