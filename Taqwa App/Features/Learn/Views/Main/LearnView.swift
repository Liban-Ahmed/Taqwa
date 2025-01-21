//
//  LearnView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import SwiftUI

struct LearnView: View {
    // Example progress manager for demonstration (replace with real logic if needed)
    @StateObject private var progressManager = FakeProgressManager()
    @StateObject private var viewModel = LearnViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.10, green: 0.20, blue: 0.40),
                        Color(red: 0.60, green: 0.30, blue: 0.70)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    progressSummaryCard
                    
                    ScrollView(showsIndicators: false) {
                        moduleGrid
                    }
                    .padding(.top, 8)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Custom Back Button
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                    NavigationLink {
                                        QuizAnalyticsView()
                                            .navigationTitle("Learning Analytics")
                                    } label: {
                                        Image(systemName: "chart.bar.fill")
                                            .foregroundColor(.white)
                                    }
                }
            }
        }
        .onAppear {
            viewModel.loadModules()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        ZStack {
            // Subtle overlay behind the text
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .overlay(
                VStack(spacing: 4) {
                    Text("Islamic Learning")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Explore and enhance your knowledge")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 20)
            )
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.ultraThinMaterial.opacity(0.3))
    }
    
    // MARK: - Progress Summary Card
    private var progressSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                // Points
                VStack(spacing: 4) {
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(progressManager.totalPoints)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                // Streak
                VStack(spacing: 4) {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(progressManager.currentStreak) days")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                // Module Completion
                VStack(spacing: 4) {
                    Text("Modules")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(progressManager.completedModules)/\(progressManager.totalModules)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            
            ProgressView(value: Double(progressManager.completedModules),
                         total: Double(progressManager.totalModules))
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .frame(height: 6)
                .clipShape(Capsule())
                .padding(.horizontal, 20)
        }
        .background(.ultraThinMaterial.opacity(0.4))
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Module Grid
    private var moduleGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {
            ForEach(viewModel.modules) { module in
                NavigationLink {
                    ModuleDetailView(module: module)
                } label: {
                    ModuleCard(
                        module: module,
                        completedLessons: viewModel.getCompletedLessonsCount(for: module),
                        totalLessons: module.lessons.count
                    )
                }
                // Removes default blue highlight, keeps your custom card design
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
    
    // MARK: - Custom Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
        }
    }
}

// MARK: - ModuleCard
struct ModuleCard: View {
    let module: Module
    @Environment(\.colorScheme) private var colorScheme
    
    // Example of lessons completed for this module
    let completedLessons: Int
    let totalLessons: Int
    
    var progress: Double {
        totalLessons == 0 ? 0 : Double(completedLessons) / Double(totalLessons)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                )
            
            // Title & Description
            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(module.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Lessons Count + progress indicator
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 12))
                Text("\(module.lessons.count) Lessons")
                    .font(.system(size: 12))
                
                Spacer()
                
                // Circular progress for lessons
                LessonProgressView(progress: progress)
                    .frame(width: 24, height: 24)
            }
            .foregroundColor(.blue)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: 8, x: 0, y: 2
                )
        )
    }
}

// MARK: - LessonProgressView
struct LessonProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .foregroundColor(.blue)
        }
    }
}
