import Foundation

struct Sailing: Identifiable {
    let id: String
    let departureTerminal: String
    let arrivalTerminal: String
    let scheduledDeparture: Date
    let scheduledArrival: Date
    let vesselName: String
    let isCancelled: Bool
    let percentageFull: Int
} 