import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    
    private let lastDepartureKey = "lastDepartureTerminalID"
    private let lastArrivalKey = "lastArrivalTerminalID"
    
    private init() {}
    
    func saveLastRoute(departure: Terminal, arrival: Terminal) {
        defaults.set(departure.id, forKey: lastDepartureKey)
        defaults.set(arrival.id, forKey: lastArrivalKey)
    }
    
    func getLastRoute() -> (departure: Terminal, arrival: Terminal)? {
        guard let departureID = defaults.string(forKey: lastDepartureKey),
              let arrivalID = defaults.string(forKey: lastArrivalKey),
              let departure = Terminal.terminals[departureID],
              let arrival = Terminal.terminals[arrivalID] else {
            return nil
        }
        
        // Verify this is still a valid route
        guard departure.validDestinations.contains(arrival.id) else {
            return nil
        }
        
        return (departure, arrival)
    }
    
    func clearLastRoute() {
        defaults.removeObject(forKey: lastDepartureKey)
        defaults.removeObject(forKey: lastArrivalKey)
    }
} 