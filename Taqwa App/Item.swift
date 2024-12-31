//
//  Item.swift
//  Taqwa App
//
//  Created by Liban Ahmed on 12/30/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
