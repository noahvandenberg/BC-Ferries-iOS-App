import Foundation

struct Terminal: Identifiable, Hashable {
    let id: String
    let name: String
    
    static let terminals: [String: Terminal] = [
        "TSA": Terminal(id: "TSA", name: "Tsawwassen"),
        "SWB": Terminal(id: "SWB", name: "Swartz Bay"),
        "HSB": Terminal(id: "HSB", name: "Horseshoe Bay"),
        "NAN": Terminal(id: "NAN", name: "Nanaimo (Departure Bay)"),
        "DUK": Terminal(id: "DUK", name: "Duke Point"),
        "LNG": Terminal(id: "LNG", name: "Langdale")
    ]
    
    static let capacityRoutes: [String: [String]] = [
        "TSA": ["SWB", "DUK"],
        "SWB": ["TSA"],
        "HSB": ["NAN", "LNG"],
        "DUK": ["TSA"],
        "LNG": ["HSB"],
        "NAN": ["HSB"]
    ]
    
    var validDestinations: [String] {
        Terminal.capacityRoutes[id] ?? []
    }
} 