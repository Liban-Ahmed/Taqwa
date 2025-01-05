//
//  moduleDetailView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//

import SwiftUI

struct ModuleDetailView: View {
    let module: Module
    @Environment(\.colorScheme) private var colorScheme
    
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
                // Header
                moduleHeader
                
                // Lessons List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(module.lessons) { lesson in
                            NavigationLink(destination: LessonView(lesson: lesson)) {
                                LessonCard(lesson: lesson)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var moduleHeader: some View {
        VStack(spacing: 12) {
            // Module icon
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                )
            
            // Title and description
            VStack(spacing: 8) {
                Text(module.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(module.lessons.count) Lessons")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(0.4))
    }
}

struct LessonCard: View {
    let lesson: Lesson
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(lesson.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            // Preview text
           
            
            // Footer
            HStack {
                // Quiz indicator if available
                if !lesson.quizQuestions.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("Quiz Available")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                // Audio indicator if available
                if lesson.audioFileName != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "headphones")
                            .font(.system(size: 12))
                        Text("Audio")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}
