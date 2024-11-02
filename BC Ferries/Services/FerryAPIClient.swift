import Foundation

enum FerryAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case networkError(Error)
    case routeNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let message):
            return "Error decoding API response: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .routeNotFound:
            return "No sailings found for this route"
        }
    }
}

class FerryAPIClient {
    static let shared = FerryAPIClient()
    private let baseURL = "https://www.bcferriesapi.ca/v2"
    
    private init() {}
    
    // V2 API structure
    private struct V2Response: Codable {
        let capacityRoutes: [V2Route]
        
        private enum CodingKeys: String, CodingKey {
            case capacityRoutes = "routes"  // API returns "routes" instead of "capacityRoutes"
        }
    }
    
    private struct V2Route: Codable {
        let routeCode: String
        let fromTerminalCode: String
        let toTerminalCode: String
        let sailingDuration: String
        let sailings: [V2Sailing]
        
        private enum CodingKeys: String, CodingKey {
            case routeCode = "routeCode"
            case fromTerminalCode = "fromTerminalCode"
            case toTerminalCode = "toTerminalCode"
            case sailingDuration = "sailingDuration"
            case sailings = "sailings"
        }
    }
    
    private struct V2Sailing: Codable {
        let time: String
        let arrivalTime: String?
        let sailingStatus: String?
        let fill: Int?
        let carFill: Int?
        let oversizeFill: Int?
        let vesselName: String?
        let vesselStatus: String?
        
        private enum CodingKeys: String, CodingKey {
            case time
            case arrivalTime
            case sailingStatus = "sailingStatus"
            case fill
            case carFill
            case oversizeFill
            case vesselName
            case vesselStatus
        }
    }
    
    func fetchTerminals() async -> [Terminal] {
        return Array(Terminal.terminals.values)
            .filter { terminal in
                Terminal.capacityRoutes[terminal.id] != nil
            }
            .sorted { $0.name < $1.name }
    }
    
    func fetchSailings(from: Terminal, to: Terminal) async throws -> [Sailing] {
        // Validate route
        guard let validDestinations = Terminal.capacityRoutes[from.id],
              validDestinations.contains(to.id) else {
            throw FerryAPIError.routeNotFound
        }
        
        // Create URL for capacity endpoint
        guard let url = URL(string: "\(baseURL)/capacity") else {
            throw FerryAPIError.invalidURL
        }
        
        print("Fetching sailings from URL: \(url.absoluteString)")
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.cachePolicy = .reloadIgnoringLocalCacheData
            
            // Fetch data
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(String(responseString.prefix(1000)))...")
            }
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FerryAPIError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw FerryAPIError.invalidResponse
            }
            
            // Decode response
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode(V2Response.self, from: data)
                
                // Find matching route
                let relevantRoutes = apiResponse.capacityRoutes.filter {
                    $0.fromTerminalCode == from.id && $0.toTerminalCode == to.id
                }
                
                print("Found \(relevantRoutes.count) matching routes")
                
                // Process sailings
                var sailings: [Sailing] = []
                
                for route in relevantRoutes {
                    for sailing in route.sailings {
                        // Parse time string to Date
                        guard let departureDate = parseTime(sailing.time) else {
                            print("Failed to parse departure time: \(sailing.time)")
                            continue
                        }
                        
                        let arrivalDate: Date
                        if let arrivalTimeStr = sailing.arrivalTime,
                           !arrivalTimeStr.isEmpty,
                           let parsed = parseTime(arrivalTimeStr) {
                            arrivalDate = parsed
                        } else {
                            // Use sailing duration if available
                            if let duration = parseDuration(route.sailingDuration) {
                                arrivalDate = departureDate.addingTimeInterval(duration)
                            } else {
                                // Default to 2 hours if no duration available
                                arrivalDate = departureDate.addingTimeInterval(7200)
                            }
                        }
                        
                        let newSailing = Sailing(
                            id: UUID().uuidString,
                            departureTerminal: route.fromTerminalCode,
                            arrivalTerminal: route.toTerminalCode,
                            scheduledDeparture: departureDate,
                            scheduledArrival: arrivalDate,
                            vesselName: sailing.vesselName ?? "Unknown Vessel",
                            isCancelled: sailing.sailingStatus?.lowercased().contains("cancelled") ?? false,
                            percentageFull: sailing.carFill ?? 0
                        )
                        
                        sailings.append(newSailing)
                    }
                }
                
                print("Processed \(sailings.count) sailings")
                
                // Sort sailings by departure time
                return sailings.sorted { $0.scheduledDeparture < $1.scheduledDeparture }
                
            } catch let decodingError {
                print("Decoding error: \(decodingError)")
                throw FerryAPIError.decodingError(decodingError.localizedDescription)
            }
            
        } catch let networkError as FerryAPIError {
            print("Ferry API error: \(networkError.localizedDescription)")
            throw networkError
        } catch {
            print("Unexpected error: \(error)")
            throw FerryAPIError.networkError(error)
        }
    }
    
    // Helper function to parse time strings like "6:15 am"
    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Vancouver") // BC Ferries timezone
        
        if let date = formatter.date(from: timeString) {
            // Adjust to today's date
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: now)
            return calendar.date(bySettingHour: calendar.component(.hour, from: date),
                               minute: calendar.component(.minute, from: date),
                               second: 0,
                               of: calendar.date(from: components) ?? now)
        }
        return nil
    }
    
    // Helper function to parse duration strings like "1h 40m"
    private func parseDuration(_ durationString: String) -> TimeInterval? {
        let components = durationString.components(separatedBy: " ")
        var totalSeconds: TimeInterval = 0
        
        for component in components {
            if component.hasSuffix("h") {
                if let hours = Double(component.dropLast()) {
                    totalSeconds += hours * 3600
                }
            } else if component.hasSuffix("m") {
                if let minutes = Double(component.dropLast()) {
                    totalSeconds += minutes * 60
                }
            }
        }
        
        return totalSeconds > 0 ? totalSeconds : nil
    }
} 