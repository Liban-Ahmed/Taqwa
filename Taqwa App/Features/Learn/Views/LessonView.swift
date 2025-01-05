//
//  LessonView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @Environment(\.colorScheme) private var colorScheme
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header Section
                headerSection
                    .background(colorScheme == .dark ? Color(.systemBackground) : .white)
                
                // Content Section
                contentSection
                
                // Quiz Section
                if !lesson.quizQuestions.isEmpty {
                    quizSection
                }
            }
        }
        .background(backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(lesson.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.75, blue: 0.45),
                            Color(red: 1.00, green: 0.88, blue: 0.60)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal)
                .padding(.top, 20)
            
            if let audioFileName = lesson.audioFileName {
                audioPlayerButton(fileName: audioFileName)
            }
            
            Divider()
                .padding(.horizontal)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Main text content
            Text(lesson.text)
                .font(.system(size: 17))
                .lineSpacing(8)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(
                            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            
            // Additional visual elements
            HStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.vertical, 10)
        }
        .padding()
    }
    
    private var quizSection: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: QuizView(questions: lesson.quizQuestions)) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .symbolEffect(.bounce)
                    
                    Text("Take Quiz")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .opacity(0.7)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
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
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
    }
    
    private func audioPlayerButton(fileName: String) -> some View {
        Button(action: {
            // Audio player action
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .symbolEffect(.bounce)
                Text("Listen to Lesson")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
    
    private var backgroundColor: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.95)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
