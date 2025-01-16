//
//  LessonView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentPage = 0
    @State private var progressValues: [CGFloat] = []
    @State private var showQuiz = false
    @State private var isInitialized = false
    
    // Page splitting
    private var pages: [String] {
        guard !lesson.text.isEmpty else { return ["No content available"] }
        
        let words = lesson.text.components(separatedBy: " ").filter { !$0.isEmpty }
        let wordsPerPage = 50 // Increased for better content flow
        var pages: [String] = []
        var currentPage: [String] = []
        
        for word in words {
            currentPage.append(word)
            if currentPage.count >= wordsPerPage {
                pages.append(currentPage.joined(separator: " "))
                currentPage.removeAll()
            }
        }
        
        if !currentPage.isEmpty {
            pages.append(currentPage.joined(separator: " "))
        }
        
        return pages.isEmpty ? ["No content available"] : pages
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                // Progress bars
                progressBars
                    .padding(.top, 8)
                
                // Header
                headerSection
                
                // Content
                GeometryReader { geometry in
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.indices), id: \.self) { index in
                            contentPage(pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onChange(of: currentPage) { _ in
                        updateProgress()
                    }
                }
                
                // Bottom navigation area
                bottomNavigationArea
            }
            
            // Touch areas for navigation
            navigationTouchAreas
        }
        .navigationBarHidden(true)
        .onAppear {
            setupProgressBars()
        }
        .overlay(
            Group {
                if showQuiz {
                    QuizView(questions: lesson.quizQuestions)
                        .transition(.opacity)
                }
            }
        )
    }
    
    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .overlay(
                        Capsule()
                            .fill(Color.white)
                            .frame(width: index <= currentPage ? .infinity : 0)
                    )
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.horizontal)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                    }
                
                Spacer()
                
                if let audioFileName = lesson.audioFileName {
                    audioPlayerButton(fileName: audioFileName)
                }
            }
            .padding(.horizontal)
            
            Text(lesson.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }
    
    private func contentPage(_ content: String) -> some View {
        ScrollView(showsIndicators: false) {
            Text(content)
                .font(.system(size: 18))
                .lineSpacing(8)
                .foregroundColor(.white)
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var bottomNavigationArea: some View {
        HStack {
            Text("\(currentPage + 1)/\(pages.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            // Last page - show quiz button
            if currentPage == pages.count - 1 {
                Button(action: { showQuizPrompt() }) {
                    HStack(spacing: 8) {
                        Text("Take Quiz")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    private var navigationTouchAreas: some View {
        HStack(spacing: 0) {
            // Previous page area
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if currentPage > 0 {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.3)
            
            // Next page area
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        showQuizPrompt()
                    }
                }
                .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea()
    }
    
    private func audioPlayerButton(fileName: String) -> some View {
        Button(action: {
            // Audio player action
        }) {
            Image(systemName: "headphones")
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }
    
    private var backgroundColor: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.10, blue: 0.30),
                Color(red: 0.50, green: 0.25, blue: 0.60)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    
    // MARK: - Helper Methods
    
    private func setupProgressBars() {
        progressValues = Array(repeating: 0, count: pages.count)
        currentPage = 0
        isInitialized = true
        updateProgress()
    }
    
    private func updateProgress() {
        for i in 0...currentPage {
            progressValues[i] = 1.0
        }
    }
    
    private func showQuizPrompt() {
        withAnimation {
            showQuiz = true
        }
    }
}
