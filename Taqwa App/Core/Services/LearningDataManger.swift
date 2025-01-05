//
//  LearningDataManger.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/4/25.
//
import Foundation

final class LearningDataManager {
    static let shared = LearningDataManager()
    
    private init() {}
    
    func loadModules() -> [Module] {
        guard let url = Bundle.main.url(forResource: "modules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find or load modules.json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let container = try decoder.decode(ModulesContainer.self, from: data)
            return container.modules
        } catch {
            print("Error decoding modules: \(error)")
            return []
        }
    }
}

private struct ModulesContainer: Codable {
    let modules: [Module]
}
