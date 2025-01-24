//
//  LearnViewModel.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import Foundation

class LearnViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var syncStatus: SyncStatus = .upToDate
    private let progressManager = LearningProgressManager.shared
    
    enum SyncStatus {
        case upToDate
        case syncing
        case offline
        case error(String)
    }
    func loadModules() {
        modules = LearningDataManager.shared.loadModules()
    }
    private func syncProgress() {
        syncStatus = .syncing
        
        progressManager.saveAndSync { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.syncStatus = .error(error.localizedDescription)
                } else {
                    self?.syncStatus = .upToDate
                }
            }
        }
    }
    
    func getCompletedLessonsCount(for module: Module) -> Int {
        let completed = UserDefaults.standard.array(forKey: "completedLessons") as? [String] ?? []
        return completed.filter { $0.starts(with: "\(module.id)_") }.count
    }
    
    func isLessonCompleted(moduleId: Int, lessonId: Int) -> Bool {
        let completed = UserDefaults.standard.array(forKey: "completedLessons") as? [String] ?? []
        return completed.contains("\(moduleId)_\(lessonId)")
    }
    
    func getQuizScore(moduleId: Int, lessonId: Int) -> Int? {
        let scores = UserDefaults.standard.dictionary(forKey: "quizScores") as? [String: Int] ?? [:]
        return scores["\(moduleId)_\(lessonId)"]
    }
}
