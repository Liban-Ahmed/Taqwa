//
//  LearningProgressManager.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/20/25.
//
import SwiftUI
import Combine
protocol LearningProgressManagerType: AnyObject {
    var totalPoints: Int { get set }
    var streak: Int { get set }
    var totalQuizAttempts: Int { get }
    var averageScore: Double { get }
    func getCompletedLessons() -> Set<String>
    func addPoints(_ points: Int)
}
class LearningProgressManager: ObservableObject, LearningProgressManagerType {
    
    static let shared: LearningProgressManager = LearningProgressManager()
    private let defaults = UserDefaults.standard
    private let cloudSync = CloudSyncManager.shared
    private var syncTask: Task<Void, Error>?
    private var offlineQueue: [() -> Void] = []
    private lazy var achievementManager = AchievementManager.shared
    // Keys for UserDefaults
    private enum Keys {
        static let completedLessons = "completedLessons"
        static let quizScores = "quizScores"
        static let totalPoints = "totalPoints"
        static let streak = "streak"
        static let lastAccessedPositions = "lastAccessedPositions"
        static let lastStudyDate = "lastStudyDate"
        static let quizProgress = "quizProgress"
        static let quizHistory = "quizHistory"
        static let totalAttempts = "totalAttempts"
        static let averageScore = "averageScore"
        static let offlineCache = "offlineCache"
        static let lastSyncTimestamp = "lastSyncTimestamp"
    }
    
    
    
    @Published var totalPoints: Int {
        didSet {
            defaults.set(totalPoints, forKey: Keys.totalPoints)
        }
    }
    
    @Published var streak: Int {
        didSet {
            defaults.set(streak, forKey: Keys.streak)
        }
    }
    @Published var currentStreak: Int {
            get { streak }
            set { streak = newValue }
        }
    
    @Published private(set) var totalQuizAttempts: Int {
        didSet {
            defaults.set(totalQuizAttempts, forKey: Keys.totalAttempts)
        }
    }
    
    @Published private(set) var averageScore: Double {
        didSet {
            defaults.set(averageScore, forKey: Keys.averageScore)
        }
    }
    
    private init() {
        // Initialize properties
        self.totalPoints = defaults.integer(forKey: Keys.totalPoints)
        self.streak = defaults.integer(forKey: Keys.streak)
        self.totalQuizAttempts = defaults.integer(forKey: Keys.totalAttempts)
        self.averageScore = defaults.double(forKey: Keys.averageScore)
        
        // If needed, set AchievementManager's progressManager after initialization
        AchievementManager.shared.progressManager = self
        
        updateStreak()
    }
    func saveQuizProgress(moduleId: Int, lessonId: Int, score: Int, wrongAnswers: [QuizProgress.WrongAnswer]) {
        // Create new progress entry
        let progress = QuizProgress(
            moduleId: moduleId,
            lessonId: lessonId,
            attempts: getAttemptCount(moduleId: moduleId, lessonId: lessonId) + 1,
            bestScore: max(score, getBestScore(moduleId: moduleId, lessonId: lessonId)),
            lastScore: score,
            completedAt: Date(),
            wrongAnswers: wrongAnswers
        )
        
        // Update storage
        var allProgress = getAllQuizProgress()
        let key = "\(moduleId)_\(lessonId)"
        allProgress[key] = progress
        defaults.set(try? JSONEncoder().encode(allProgress), forKey: Keys.quizProgress)
        
        // Update history
        appendToQuizHistory(progress)
        
        // Update analytics
        updateAnalytics(with: score)
    }
    
    func getQuizProgress(moduleId: Int, lessonId: Int) -> QuizProgress? {
        let allProgress = getAllQuizProgress()
        return allProgress["\(moduleId)_\(lessonId)"]
    }
    
    private func getAllQuizProgress() -> [String: QuizProgress] {
        guard let data = defaults.data(forKey: Keys.quizProgress),
              let progress = try? JSONDecoder().decode([String: QuizProgress].self, from: data) else {
            return [:]
        }
        return progress
    }
    
    private func getAttemptCount(moduleId: Int, lessonId: Int) -> Int {
        getQuizProgress(moduleId: moduleId, lessonId: lessonId)?.attempts ?? 0
    }
    
    private func getBestScore(moduleId: Int, lessonId: Int) -> Int {
        getQuizProgress(moduleId: moduleId, lessonId: lessonId)?.bestScore ?? 0
    }
    
    private func appendToQuizHistory(_ progress: QuizProgress) {
        var history = getQuizHistory()
        history.append(progress)
        defaults.set(try? JSONEncoder().encode(history), forKey: Keys.quizHistory)
    }
    
    private func getQuizHistory() -> [QuizProgress] {
        guard let data = defaults.data(forKey: Keys.quizHistory),
              let history = try? JSONDecoder().decode([QuizProgress].self, from: data) else {
            return []
        }
        return history
    }
    
    private func updateAnalytics(with newScore: Int) {
        totalQuizAttempts += 1
        averageScore = ((averageScore * Double(totalQuizAttempts - 1)) + Double(newScore)) / Double(totalQuizAttempts)
        
        defaults.set(totalQuizAttempts, forKey: Keys.totalAttempts)
        defaults.set(averageScore, forKey: Keys.averageScore)
    }
    
    func markLessonCompleted(moduleId: Int, lessonId: Int) {
        let key = "\(moduleId)_\(lessonId)"
        var completed = getCompletedLessons()
        completed.insert(key)
        defaults.set(Array(completed), forKey: Keys.completedLessons)
        addPoints(50) // Award points for completion
        achievementManager.checkAchievements()
    }
    
    func saveQuizScore(moduleId: Int, lessonId: Int, score: Int) {
        let key = "\(moduleId)_\(lessonId)"
        var scores = getQuizScores()
        scores[key] = score
        defaults.set(scores, forKey: Keys.quizScores)
        addPoints(score * 10) // Award points based on score
    }
    
    func saveLastPosition(moduleId: Int, lessonId: Int, page: Int) {
        let key = "\(moduleId)_\(lessonId)"
        var positions = getLastAccessedPositions()
        positions[key] = page
        defaults.set(positions, forKey: Keys.lastAccessedPositions)
    }
    
    func getCompletedLessons() -> Set<String> {
        let array = defaults.array(forKey: Keys.completedLessons) as? [String] ?? []
        return Set(array)
    }
    
    private func getQuizScores() -> [String: Int] {
        return defaults.dictionary(forKey: Keys.quizScores) as? [String: Int] ?? [:]
    }
    
    private func getLastAccessedPositions() -> [String: Int] {
        return defaults.dictionary(forKey: Keys.lastAccessedPositions) as? [String: Int] ?? [:]
    }
    
    func addPoints(_ points: Int) {
        totalPoints += points
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = defaults.object(forKey: Keys.lastStudyDate) as? Date {
            let lastStudyDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDifference > 1 {
                streak = 0
            }
        }
        
        defaults.set(today, forKey: Keys.lastStudyDate)
        achievementManager.checkAchievements()
    }
    
    func saveAndSync(completion: @escaping (Error?) -> Void) {
        // Save locally first
        let progressData = self.prepareProgressData()
        self.saveToOfflineCache(progressData)
        
        // Then attempt to sync with cloud
        syncTask = Task {
            do {
                try await cloudSync.syncProgress(progressData)
                await MainActor.run {
                    self.clearOfflineCache()
                    completion(nil)
                }
            } catch {
                await MainActor.run {
                    self.addToOfflineQueue()
                    completion(error)
                }
            }
        }
    }
    
    private func prepareProgressData() -> [String: Any] {
        return [
            "totalPoints": totalPoints,
            "streak": streak,
            "totalQuizAttempts": totalQuizAttempts,
            "averageScore": averageScore,
            "completedLessons": Array(getCompletedLessons()),
            "quizScores": getQuizScores(),
            "lastAccessed": getLastAccessedPositions(),
            "timestamp": Date().timeIntervalSince1970
        ]
    }
    
    private func saveToOfflineCache(_ data: [String: Any]) {
        defaults.set(try? JSONSerialization.data(withJSONObject: data),
                     forKey: Keys.offlineCache)
    }
    
    private func restoreFromOfflineCache() {
        guard let data = defaults.data(forKey: Keys.offlineCache),
              let cached = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        self.totalPoints = cached["totalPoints"] as? Int ?? 0
        self.streak = cached["streak"] as? Int ?? 0
        self.totalQuizAttempts = cached["totalQuizAttempts"] as? Int ?? 0
        self.averageScore = cached["averageScore"] as? Double ?? 0.0
    }
    
    func syncWithCloud() {
        Task {
            do {
                let cloudProgress = try await cloudSync.fetchProgress()
                await MainActor.run {
                    self.mergeProgress(cloudProgress)
                }
            } catch {
                print("Cloud sync failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func mergeProgress(_ cloudProgress: [String: Any]) {
        let localTimestamp = defaults.double(forKey: Keys.lastSyncTimestamp)
        let cloudTimestamp = cloudProgress["timestamp"] as? Double ?? 0
        
        // Use the most recent data
        if cloudTimestamp > localTimestamp {
            self.totalPoints = cloudProgress["totalPoints"] as? Int ?? self.totalPoints
            self.streak = cloudProgress["streak"] as? Int ?? self.streak
            self.totalQuizAttempts = cloudProgress["totalQuizAttempts"] as? Int ?? self.totalQuizAttempts
            self.averageScore = cloudProgress["averageScore"] as? Double ?? self.averageScore
            
            defaults.set(cloudTimestamp, forKey: Keys.lastSyncTimestamp)
        }
    }
    
    private func addToOfflineQueue() {
        offlineQueue.append { [weak self] in
            self?.syncWithCloud()
        }
    }
    
    private func processOfflineQueue() {
        guard !offlineQueue.isEmpty else { return }
        
        let operations = offlineQueue
        offlineQueue.removeAll()
        
        for operation in operations {
            operation()
        }
    }
    
    private func clearOfflineCache() {
        defaults.removeObject(forKey: Keys.offlineCache)
    }
    
    deinit {
        syncTask?.cancel()
    }
}
