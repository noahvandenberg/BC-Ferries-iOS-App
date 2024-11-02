import SwiftUI

struct MainView: View {
    @State private var terminals: [Terminal] = []
    @State private var selectedDeparture: Terminal?
    @State private var selectedArrival: Terminal?
    @State private var sailings: [Sailing] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var favorites: [FavoriteRoute] = []
    @State private var showingFavorites = false
    
    var validDestinations: [Terminal] {
        guard let departure = selectedDeparture else { return [] }
        return terminals.filter { terminal in
            departure.validDestinations.contains(terminal.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Favorites Section
                    if !favorites.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Favorites", systemImage: "star.fill")
                                    .font(.headline)
                                Spacer()
                                Button {
                                    withAnimation {
                                        showingFavorites.toggle()
                                    }
                                } label: {
                                    Label(showingFavorites ? "Hide" : "Show", 
                                          systemImage: showingFavorites ? "chevron.up" : "chevron.down")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            
                            if showingFavorites {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(favorites) { favorite in
                                            FavoriteRouteButton(favorite: favorite) {
                                                if let departure = Terminal.terminals[favorite.departureTerminalID],
                                                   let arrival = Terminal.terminals[favorite.arrivalTerminalID] {
                                                    selectedDeparture = departure
                                                    selectedArrival = arrival
                                                    saveRouteAndLoadSailings()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Route Selection Card
                    VStack(spacing: 12) {
                        // From Terminal
                        Menu {
                            ForEach(terminals) { terminal in
                                Button(terminal.name) {
                                    if selectedDeparture != terminal {
                                        selectedDeparture = terminal
                                        handleDepartureSelection(terminal)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let departure = selectedDeparture {
                                        Text(departure.name)
                                            .font(.title3)
                                    } else {
                                        Text("Select Departure")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // To Terminal
                        Menu {
                            if !validDestinations.isEmpty {
                                ForEach(validDestinations) { terminal in
                                    Button(terminal.name) {
                                        if selectedArrival != terminal {
                                            withAnimation {
                                                selectedArrival = terminal
                                                saveRouteAndLoadSailings()
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let arrival = selectedArrival {
                                        Text(arrival.name)
                                            .font(.title3)
                                    } else {
                                        Text("Select Arrival")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(validDestinations.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // Sailings List
                    if !sailings.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(sailings) { sailing in
                                SailingRow(sailing: sailing)
                                    .transition(.opacity)
                            }
                        }
                    } else if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 100)
                    } else if selectedDeparture != nil && selectedArrival != nil {
                        ContentUnavailableView {
                            Label("No Sailings", systemImage: "ferry")
                        } description: {
                            Text("No sailings found for this route")
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("BC Ferries")
            .toolbar {
                if let departure = selectedDeparture,
                   let arrival = selectedArrival {
                    ToolbarItem(placement: .topBarTrailing) {
                        FavoriteButton(
                            departure: departure,
                            arrival: arrival,
                            isFavorite: UserPreferences.shared.isFavorite(
                                departure: departure,
                                arrival: arrival
                            )
                        ) {
                            toggleFavorite(departure: departure, arrival: arrival)
                        }
                    }
                }
            }
            .refreshable {
                if selectedDeparture != nil && selectedArrival != nil {
                    loadSailings()
                }
            }
            .task {
                // Load terminals
                terminals = await FerryAPIClient.shared.fetchTerminals()
                
                // Restore last route if available
                if let (departure, arrival) = UserPreferences.shared.getLastRoute() {
                    selectedDeparture = departure
                    selectedArrival = arrival
                    loadSailings()
                }
                
                favorites = UserPreferences.shared.getFavorites()
            }
            .overlay {
                if let error = error {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(error.localizedDescription)
                            Spacer()
                            Button("Retry") {
                                loadSailings()
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    }
                }
            }
        }
    }
    
    private func handleDepartureSelection(_ terminal: Terminal) {
        selectedArrival = nil
        sailings = []
        
        // Get valid destinations for the selected terminal
        let destinations = terminals.filter { terminal.validDestinations.contains($0.id) }
        
        // If there's only one destination, automatically select it
        if destinations.count == 1 {
            selectedArrival = destinations[0]
            saveRouteAndLoadSailings()
        }
    }
    
    private func saveRouteAndLoadSailings() {
        guard let departure = selectedDeparture,
              let arrival = selectedArrival else {
            return
        }
        
        // Save the route
        UserPreferences.shared.saveLastRoute(departure: departure, arrival: arrival)
        
        // Load sailings
        loadSailings()
    }
    
    private func loadSailings() {
        guard let departure = selectedDeparture,
              let arrival = selectedArrival else {
            return
        }
        
        Task {
            do {
                isLoading = true
                error = nil
                let newSailings = try await FerryAPIClient.shared.fetchSailings(
                    from: departure,
                    to: arrival
                )
                withAnimation {
                    sailings = newSailings
                }
            } catch {
                withAnimation {
                    self.error = error
                }
            }
            isLoading = false
        }
    }
    
    private func toggleFavorite(departure: Terminal, arrival: Terminal) {
        if UserPreferences.shared.isFavorite(departure: departure, arrival: arrival) {
            if let favorite = favorites.first(where: { 
                $0.departureTerminalID == departure.id && 
                $0.arrivalTerminalID == arrival.id 
            }) {
                UserPreferences.shared.removeFavorite(favorite)
            }
        } else {
            let favorite = FavoriteRoute(departure: departure, arrival: arrival)
            UserPreferences.shared.saveFavorite(favorite)
        }
        
        withAnimation {
            favorites = UserPreferences.shared.getFavorites()
        }
    }
}

struct FavoriteButton: View {
    let departure: Terminal
    let arrival: Terminal
    let isFavorite: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Favorite", systemImage: isFavorite ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundStyle(isFavorite ? .yellow : .gray)
        }
        .buttonStyle(.plain)
    }
}

struct FavoriteRouteButton: View {
    let favorite: FavoriteRoute
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "ferry")
                    .foregroundStyle(.secondary)
                Text(favorite.name)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainView()
} 