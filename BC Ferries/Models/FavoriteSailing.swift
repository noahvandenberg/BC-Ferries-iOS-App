import Foundation

struct FavoriteSailing: Identifiable, Codable, Hashable {
    let id: String
    let departureTerminalID: String
    let arrivalTerminalID: String
    let scheduledDepartureTime: String // Store as "HH:mm" format
    let vesselName: String
    
    init(sailing: Sailing) {
        self.id = UUID().uuidString
        self.departureTerminalID = sailing.departureTerminal
        self.arrivalTerminalID = sailing.arrivalTerminal
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.scheduledDepartureTime = formatter.string(from: sailing.scheduledDeparture)
        
        self.vesselName = sailing.vesselName
    }
    
    // Helper to match against actual sailings
    func matches(_ sailing: Sailing) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let sailingTime = formatter.string(from: sailing.scheduledDeparture)
        
        return departureTerminalID == sailing.departureTerminal &&
               arrivalTerminalID == sailing.arrivalTerminal &&
               scheduledDepartureTime == sailingTime &&
               vesselName == sailing.vesselName
    }
} 