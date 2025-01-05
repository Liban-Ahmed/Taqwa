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
}
