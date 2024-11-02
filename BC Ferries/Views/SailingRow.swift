import SwiftUI

struct SailingRow: View {
    let sailing: Sailing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Time and Status
            HStack {
                // Departure Time
                VStack(alignment: .leading) {
                    Text(sailing.scheduledDeparture, style: .time)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Departure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 44)
                
                Spacer()
                
                // Arrival Time
                VStack(alignment: .trailing) {
                    Text(sailing.scheduledArrival, style: .time)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("Arrival")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
            
            // Vessel and Capacity
            HStack {
                // Vessel Name
                HStack {
                    Image(systemName: "ferry")
                        .foregroundStyle(.secondary)
                    Text(sailing.vesselName)
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Capacity
                CapacityIndicator(percentageFull: sailing.percentageFull)
            }
            
            // Status Badge (if cancelled)
            if sailing.isCancelled {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("CANCELLED")
                        .fontWeight(.medium)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
} 