import SwiftUI

struct TerminalSelectionView: View {
    @State private var terminals: [Terminal] = []
    @State private var selectedDeparture: Terminal?
    @State private var selectedArrival: Terminal?
    @State private var isLoading = true
    
    var validDestinations: [Terminal] {
        guard let departure = selectedDeparture else { return [] }
        return terminals.filter { terminal in
            departure.validDestinations.contains(terminal.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Departure Terminal Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("From")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(terminals) { terminal in
                                            TerminalButton(
                                                name: terminal.name,
                                                isSelected: selectedDeparture == terminal
                                            ) {
                                                selectedDeparture = terminal
                                                selectedArrival = nil
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Arrival Terminal Section
                            if let _ = selectedDeparture {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("To")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(validDestinations) { terminal in
                                                TerminalButton(
                                                    name: terminal.name,
                                                    isSelected: selectedArrival == terminal
                                                ) {
                                                    selectedArrival = terminal
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // View Sailings Button
                            if let departure = selectedDeparture,
                               let arrival = selectedArrival {
                                NavigationLink {
                                    SailingListView(
                                        departure: departure,
                                        arrival: arrival
                                    )
                                } label: {
                                    HStack {
                                        Text("View Sailings")
                                        Image(systemName: "arrow.right")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("BC Ferries")
            .task {
                isLoading = true
                terminals = await FerryAPIClient.shared.fetchTerminals()
                isLoading = false
            }
        }
    }
}

struct TerminalButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
    }
}

#Preview {
    TerminalSelectionView()
} 