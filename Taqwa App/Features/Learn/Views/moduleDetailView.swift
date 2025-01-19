//
//  moduleDetailView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//

import SwiftUI

struct ModuleDetailView: View {
    let module: Module
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
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
                    // Custom top bar
                    topBar
                    
                    // Hero Section
                    heroSection
                    
                    // Lessons List
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(module.lessons) { lesson in
                                NavigationLink {
                                    LessonView(lesson: lesson)
                                } label: {
                                    LessonCard(lesson: lesson)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: Top Bar
    private var topBar: some View {
        ZStack {
            // Frosted background
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .frame(height: 60)
                .blur(radius: 6)
                .ignoresSafeArea()
            
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(module.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
    }
    
    // MARK: Hero Section
    private var heroSection: some View {
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
            
            // Title and lesson count
            Text(module.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("\(module.lessons.count) Lessons")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
            
            // Optional: If you want to add module-level progress, uncomment below:
            /*
            ProgressView(value: moduleProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .frame(width: 150, height: 6)
                .clipShape(Capsule())
                .padding(.top, 8)
             */
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            // Subtle frosted background
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
    
    // Example module progress calculation if desired
    private var moduleProgress: Double {
        // For instance, get # of completed lessons / total lessons
        // return Double(completedLessonCount) / Double(module.lessons.count)
        return 0.3 // placeholder
    }
}

// MARK: - LessonCard
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
                .lineLimit(1)
            
            // Optional short preview text (e.g., first ~20 words):
            if !lesson.text.isEmpty {
                Text(previewText(lesson.text))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
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
        // Press scale effect (optional)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.2), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1) {
            withAnimation { isPressed = true }
        } onPressingChanged: { isPressing in
            if !isPressing { withAnimation { isPressed = false } }
        }
    }
    
    // Create a short preview by taking the first ~20 words.
    private func previewText(_ fullText: String) -> String {
        let words = fullText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let snippet = words.prefix(20).joined(separator: " ")
        return snippet + (words.count > 20 ? "..." : "")
    }
}
