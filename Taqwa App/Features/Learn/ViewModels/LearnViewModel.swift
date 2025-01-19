//
//  LearnViewModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import Foundation

class LearnViewModel: ObservableObject {
    @Published var modules: [Module] = []
    
    func loadModules() {
        modules = LearningDataManager.shared.loadModules()
    }
    func getCompletedLessonsCount(for module: Module) -> Int {
           // Return the actual completed lesson count, e.g., 0 for now
           return 0
       }
}
