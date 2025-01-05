//
//  LearnView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import SwiftUI
struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Updated gradient with a subtle blend
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
                    ScrollView(showsIndicators: false) {
                        moduleGrid
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
        }
        .onAppear {
            viewModel.loadModules()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Islamic Learning")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text("Explore and enhance your knowledge")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(0.4))
    }
    
    private var moduleGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {
            ForEach(viewModel.modules) { module in
                NavigationLink(destination: ModuleDetailView(module: module)) {
                    ModuleCard(module: module)
                }
            }
        }
        .padding(16)
    }
    
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

struct ModuleCard: View {
    let module: Module
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
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
            
            // Lessons Count
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 12))
                Text("\(module.lessons.count) Lessons")
                    .font(.system(size: 12))
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
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}
