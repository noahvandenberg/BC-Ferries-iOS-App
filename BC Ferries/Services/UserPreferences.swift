import Foundation

class UserPreferences {
    static let shared = UserPreferences()
    
    private let defaults = UserDefaults.standard
    
    private let lastDepartureKey = "lastDepartureTerminalID"
    private let lastArrivalKey = "lastArrivalTerminalID"
    private let favoritesKey = "favoriteRoutes"
    private let favoriteSailingsKey = "favoriteSailings"
    
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
    
    func getFavorites() -> [FavoriteRoute] {
        guard let data = defaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([FavoriteRoute].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func saveFavorite(_ favorite: FavoriteRoute) {
        var favorites = getFavorites()
        favorites.append(favorite)
        if let encoded = try? JSONEncoder().encode(favorites) {
            defaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func removeFavorite(_ favorite: FavoriteRoute) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == favorite.id }
        if let encoded = try? JSONEncoder().encode(favorites) {
            defaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func isFavorite(departure: Terminal, arrival: Terminal) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { 
            $0.departureTerminalID == departure.id && 
            $0.arrivalTerminalID == arrival.id 
        }
    }
    
    func getFavoriteSailings() -> [FavoriteSailing] {
        guard let data = defaults.data(forKey: favoriteSailingsKey),
              let favorites = try? JSONDecoder().decode([FavoriteSailing].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func saveFavoriteSailing(_ sailing: Sailing) {
        var favorites = getFavoriteSailings()
        let favoriteSailing = FavoriteSailing(sailing: sailing)
        favorites.append(favoriteSailing)
        if let encoded = try? JSONEncoder().encode(favorites) {
            defaults.set(encoded, forKey: favoriteSailingsKey)
        }
    }
    
    func removeFavoriteSailing(_ sailing: Sailing) {
        var favorites = getFavoriteSailings()
        favorites.removeAll { $0.matches(sailing) }
        if let encoded = try? JSONEncoder().encode(favorites) {
            defaults.set(encoded, forKey: favoriteSailingsKey)
        }
    }
    
    func isFavoriteSailing(_ sailing: Sailing) -> Bool {
        let favorites = getFavoriteSailings()
        return favorites.contains { $0.matches(sailing) }
    }
} 