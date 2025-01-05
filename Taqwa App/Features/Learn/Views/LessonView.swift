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
    @State private var timer: Timer?
    @State private var showQuiz = false
    @State private var isInitialized = false
    
    // Improved page splitting with better word count
    private var pages: [String] {
        guard !lesson.text.isEmpty else { return ["No content available"] }
        
        let words = lesson.text.components(separatedBy: " ").filter { !$0.isEmpty }
        let wordsPerPage = 30 // Reduced for better readability
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
                    HStack(spacing: 0) {
                        // Content pages
                        contentPages(width: geometry.size.width)
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                handleSwipe(value, width: geometry.size.width)
                            }
                    )
                }
                
                // Navigation hints
                navigationHints
            }
            
            // Touch areas for navigation
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToPrevious()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToNext()
                    }
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .onAppear {
            setupProgressBars()
            startProgressTimer()
        }
        .onDisappear {
            timer?.invalidate()
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
    
    // Fixed progress bars with proper sizing and safety checks
        private var progressBars: some View {
            let pageCount = pages.count
            
            return HStack(spacing: 4) {
                ForEach(0..<pageCount, id: \.self) { index in
                    GeometryReader { geometry in
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .fill(Color.white)
                                    .frame(
                                        width: geometry.size.width * (index < progressValues.count ? progressValues[index] : 0),
                                        height: 2
                                    )
                            )
                    }
                    .frame(height: 2)
                    .animation(.linear(duration: 0.1), value: index < progressValues.count ? progressValues[index] : 0)
                }
            }
            .padding(.horizontal)
        }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
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
    
    private func contentPages(width: CGFloat) -> some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.indices), id: \.self) { index in
                contentPage(pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private func contentPage(_ content: String) -> some View {
        ScrollView(showsIndicators: false) {
            Text(content)
                .font(.system(size: 18))
                .lineSpacing(8)
                .foregroundColor(.white)
                .padding(24)
        }
    }
    
    private var navigationHints: some View {
        HStack {
            Image(systemName: "chevron.left")
                .opacity(currentPage > 0 ? 1 : 0)
            Spacer()
            Image(systemName: "chevron.right")
                .opacity(currentPage < pages.count - 1 ? 1 : 0)
        }
        .foregroundColor(.white.opacity(0.6))
        .font(.system(size: 28, weight: .semibold))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
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
           let pageCount = pages.count
           progressValues = Array(repeating: 0, count: pageCount)
           currentPage = 0
           if pageCount > 0 {
               progressValues[0] = 0
           }
           isInitialized = true
       }
       
       private func startProgressTimer() {
           guard isInitialized,
                 currentPage >= 0,
                 currentPage < pages.count,
                 currentPage < progressValues.count else {
               return
           }
           
           timer?.invalidate()
           progressValues[currentPage] = 0
           
           timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
               guard currentPage < progressValues.count else {
                   timer?.invalidate()
                   return
               }
               
               if progressValues[currentPage] < 1.0 {
                   progressValues[currentPage] += 0.01
               } else {
                   timer?.invalidate()
                   if currentPage < pages.count - 1 {
                       navigateToNext()
                   } else {
                       showQuizPrompt()
                   }
               }
           }
       }
        
        private func navigateToPrevious() {
            guard currentPage > 0, isInitialized else { return }
            currentPage -= 1
            startProgressTimer()
        }
        
        private func navigateToNext() {
            guard currentPage < pages.count - 1, isInitialized else {
                if currentPage == pages.count - 1 {
                    showQuizPrompt()
                }
                return
            }
            currentPage += 1
            startProgressTimer()
        }
        
        private func handleSwipe(_ value: DragGesture.Value, width: CGFloat) {
            guard isInitialized else { return }
            
            if value.translation.width > 50 && currentPage > 0 {
                navigateToPrevious()
            } else if value.translation.width < -50 && currentPage < pages.count - 1 {
                navigateToNext()
            }
        }
        
        private func showQuizPrompt() {
            timer?.invalidate()
            withAnimation {
                showQuiz = true
            }
        }
    }
