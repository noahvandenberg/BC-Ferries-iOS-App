import Foundation

struct FavoriteRoute: Identifiable, Codable, Hashable {
    let id: String
    let departureTerminalID: String
    let arrivalTerminalID: String
    let name: String
    
    init(departure: Terminal, arrival: Terminal) {
        self.id = UUID().uuidString
        self.departureTerminalID = departure.id
        self.arrivalTerminalID = arrival.id
        self.name = "\(departure.name) → \(arrival.name)"
    }
} 