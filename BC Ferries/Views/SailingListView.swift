import SwiftUI

struct SailingListView: View {
    let departure: Terminal
    let arrival: Terminal
    
    @State private var sailings: [Sailing] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading sailings...")
            } else if let error = error {
                VStack(spacing: 16) {
                    Text("Error loading sailings")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadSailings()
                    }
                    .buttonStyle(.bordered)
                }
            } else if sailings.isEmpty {
                Text("No sailings found")
            } else {
                List(sailings) { sailing in
                    SailingRow(sailing: sailing)
                }
            }
        }
        .navigationTitle("\(departure.name) to \(arrival.name)")
        .task {
            loadSailings()
        }
    }
    
    private func loadSailings() {
        Task {
            isLoading = true
            do {
                sailings = try await FerryAPIClient.shared.fetchSailings(
                    from: departure,
                    to: arrival
                )
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
} 