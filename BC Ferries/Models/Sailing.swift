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
    
    var progress: Double {
        guard !isCancelled else { return 0 }
        let now = Date()
        
        // Not started yet
        if now < scheduledDeparture {
            return 0
        }
        
        // Already completed
        if now > scheduledArrival {
            return 1
        }
        
        // In progress
        let totalDuration = scheduledArrival.timeIntervalSince(scheduledDeparture)
        let elapsed = now.timeIntervalSince(scheduledDeparture)
        return elapsed / totalDuration
    }
    
    var status: String {
        let now = Date()
        if isCancelled {
            return "Cancelled"
        } else if now < scheduledDeparture {
            return "Scheduled"
        } else if now > scheduledArrival {
            return "Completed"
        } else {
            return "En Route"
        }
    }
} 