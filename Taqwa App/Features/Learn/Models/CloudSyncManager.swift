//
//  CloudSyncManager.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 1/20/25.
//

import CloudKit
import Combine

class CloudSyncManager {
    static let shared = CloudSyncManager()
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    private init() {
        self.database = container.privateCloudDatabase
    }
    
    // Record Types
    private enum RecordType {
        static let progress = "LearningProgress"
    }
    
    func syncProgress(_ progress: [String: Any]) async throws {
        let record = CKRecord(recordType: RecordType.progress)
        
        // Set values on record
        for (key, value) in progress {
            if let value = value as? CKRecordValue {
                record.setValue(value, forKey: key)
            }
        }
        
        _ = try await database.save(record)
    }
    
    func fetchProgress() async throws -> [String: Any] {
           let query = CKQuery(recordType: RecordType.progress, predicate: NSPredicate(value: true))
           let result = try await database.records(matching: query)
           
           guard let record = try? result.matchResults.first?.1.get() else {
               return [:]
           }
           
           var progressData: [String: Any] = [:]
           
           // Extract all fields from the record
           for key in record.allKeys() {
               if let value = record.value(forKey: key) {
                   progressData[key] = value
               }
           }
           
           return progressData
       }
}
