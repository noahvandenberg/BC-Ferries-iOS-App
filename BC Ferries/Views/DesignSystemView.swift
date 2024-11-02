import SwiftUI

struct DesignSystemView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Section("Sailing States") {
                        // Regular sailing
                        SailingRow(sailing: .mockScheduled)
                        
                        // En route sailing
                        SailingRow(sailing: .mockEnRoute)
                        
                        // Almost complete sailing
                        SailingRow(sailing: .mockNearlyComplete)
                        
                        // Completed sailing
                        SailingRow(sailing: .mockCompleted)
                        
                        // Cancelled sailing
                        SailingRow(sailing: .mockCancelled)
                        
                        // Full capacity sailing
                        SailingRow(sailing: .mockFullCapacity)
                        
                        // Low capacity sailing
                        SailingRow(sailing: .mockLowCapacity)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// Mock data for design system
extension Sailing {
    static let mockScheduled = Sailing(
        id: "1",
        departureTerminal: "TSA",
        arrivalTerminal: "SWB",
        scheduledDeparture: Date().addingTimeInterval(3600),
        scheduledArrival: Date().addingTimeInterval(7200),
        vesselName: "Spirit of Vancouver Island",
        isCancelled: false,
        percentageFull: 45
    )
    
    static let mockEnRoute = Sailing(
        id: "2",
        departureTerminal: "HSB",
        arrivalTerminal: "NAN",
        scheduledDeparture: Date().addingTimeInterval(-1800),
        scheduledArrival: Date().addingTimeInterval(3600),
        vesselName: "Queen of Oak Bay",
        isCancelled: false,
        percentageFull: 75
    )
    
    static let mockNearlyComplete = Sailing(
        id: "3",
        departureTerminal: "TSA",
        arrivalTerminal: "DUK",
        scheduledDeparture: Date().addingTimeInterval(-5400),
        scheduledArrival: Date().addingTimeInterval(600),
        vesselName: "Coastal Inspiration",
        isCancelled: false,
        percentageFull: 85
    )
    
    static let mockCompleted = Sailing(
        id: "4",
        departureTerminal: "LNG",
        arrivalTerminal: "HSB",
        scheduledDeparture: Date().addingTimeInterval(-7200),
        scheduledArrival: Date().addingTimeInterval(-3600),
        vesselName: "Queen of Surrey",
        isCancelled: false,
        percentageFull: 60
    )
    
    static let mockCancelled = Sailing(
        id: "5",
        departureTerminal: "SWB",
        arrivalTerminal: "TSA",
        scheduledDeparture: Date().addingTimeInterval(1800),
        scheduledArrival: Date().addingTimeInterval(5400),
        vesselName: "Spirit of British Columbia",
        isCancelled: true,
        percentageFull: 0
    )
    
    static let mockFullCapacity = Sailing(
        id: "6",
        departureTerminal: "HSB",
        arrivalTerminal: "NAN",
        scheduledDeparture: Date().addingTimeInterval(7200),
        scheduledArrival: Date().addingTimeInterval(10800),
        vesselName: "Queen of Cowichan",
        isCancelled: false,
        percentageFull: 100
    )
    
    static let mockLowCapacity = Sailing(
        id: "7",
        departureTerminal: "TSA",
        arrivalTerminal: "DUK",
        scheduledDeparture: Date().addingTimeInterval(10800),
        scheduledArrival: Date().addingTimeInterval(14400),
        vesselName: "Queen of Alberni",
        isCancelled: false,
        percentageFull: 15
    )
}

#Preview {
    DesignSystemView()
} 