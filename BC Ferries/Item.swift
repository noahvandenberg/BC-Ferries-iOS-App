//
//  Item.swift
//  BC Ferries
//
//  Created by Noah Vandenberg on 2024-11-02.
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
