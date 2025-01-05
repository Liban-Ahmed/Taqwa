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

