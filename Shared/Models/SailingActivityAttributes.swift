import ActivityKit
import Foundation

struct SailingActivityAttributes: ActivityAttributes {
    public typealias SailingStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var percentageFull: Int
        var isCancelled: Bool
        var currentStatus: String
    }
    
    let departureTerminal: String
    let arrivalTerminal: String
    let vesselName: String
    let scheduledDeparture: Date
    let scheduledArrival: Date
} 