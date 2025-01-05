//
//  LearnView.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LearnViewModel()
    
    var body: some View {
        NavigationView {
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
                
                List(viewModel.modules) { module in
                    NavigationLink(destination: ModuleDetailView(module: module)) {
                        ModuleRowView(module: module)
                    }
                }
                .navigationTitle("Learn")
                .scrollContentBackground(.hidden)
            }
            .onAppear {
                viewModel.loadModules()
            }
        }
    }
}

struct ModuleRowView: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(module.title)
                .font(.headline)
                .foregroundColor(.white)
            Text(module.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
    }
}
