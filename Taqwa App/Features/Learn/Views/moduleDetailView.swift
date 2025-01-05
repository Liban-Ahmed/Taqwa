//
//  moduleDetailView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//

import SwiftUI

struct ModuleDetailView: View {
    let module: Module
    
    var body: some View {
        List {
            ForEach(module.lessons) { lesson in
                NavigationLink(destination: LessonView(lesson: lesson)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lesson.title)
                            .font(.headline)
                        Text(lesson.text.prefix(100) + "...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(module.title)
    }
}

struct LessonView: View {
    let lesson: Lesson
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lesson.title)
                    .font(.title)
                    .padding(.bottom, 8)
                
                Text(lesson.text)
                    .font(.body)
                
                if !lesson.quizQuestions.isEmpty {
                    NavigationLink(destination: QuizView(questions: lesson.quizQuestions)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Take Quiz")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
        }
        .navigationTitle("Lesson")
    }
}

struct QuizView: View {
    let questions: [QuizQuestion]
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showScore = false
    
    var body: some View {
        VStack(spacing: 20) {
            if showScore {
                VStack(spacing: 20) {
                    Text("Quiz Complete!")
                        .font(.title)
                    Text("Score: \(score)/\(questions.count)")
                        .font(.headline)
                }
            } else {
                let question = questions[currentQuestionIndex]
                
                Text(question.question)
                    .font(.title3)
                    .padding()
                
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        selectAnswer(index)
                    }) {
                        Text(question.options[index])
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor(for: index))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Quiz")
    }
    
    private func backgroundColor(for index: Int) -> Color {
        guard let selectedAnswer = selectedAnswer else { return .blue }
        if index == selectedAnswer {
            return index == questions[currentQuestionIndex].correctIndex ? .green : .red
        }
        return .blue
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        if index == questions[currentQuestionIndex].correctIndex {
            score += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
            } else {
                showScore = true
            }
        }
    }
}
