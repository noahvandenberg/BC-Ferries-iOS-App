import WidgetKit
import SwiftUI
import ActivityKit

extension SailingActivityAttributes {
    var progress: Double {
        let now = Date()
        
        // Not started yet
        if now < scheduledDeparture {
            return 0
        }
        
        // Already completed
        if now > scheduledArrival {
            return 1
        }
        
        // In progress
        let totalDuration = scheduledArrival.timeIntervalSince(scheduledDeparture)
        let elapsed = now.timeIntervalSince(scheduledDeparture)
        return elapsed / totalDuration
    }
}

struct SailingActivityWidget: Widget {
    static let kind: String = "BC_FerriesWidgetExtension"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SailingActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack(spacing: 12) {
                // Header with vessel and status
                HStack(alignment: .center) {
                    HStack(spacing: 6) {
                        Image(systemName: "ferry.fill")
                            .foregroundStyle(.secondary)
                        Text(context.attributes.vesselName)
                            .font(.headline)
                    }
                    Spacer()
                    if context.state.isCancelled {
                        Text("CANCELLED")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.red.gradient)
                            .clipShape(Capsule())
                    }
                }
                
                // Route and Times
                HStack(spacing: 16) {
                    // Departure
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.departureTerminal)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(context.attributes.scheduledDeparture, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Progress Line
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 2)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .background(Color(.systemBackground))
                            .padding(.horizontal, 4)
                    }
                    
                    // Arrival
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.attributes.arrivalTerminal)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(context.attributes.scheduledArrival, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                // Status and Capacity
                HStack {
                    Label(context.state.currentStatus, systemImage: "clock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    CapacityIndicator(percentageFull: context.state.percentageFull)
                }
                
                // Progress Bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    if !context.state.isCancelled {
                        Rectangle()
                            .fill(.tint)
                            .frame(width: context.attributes.progress * 350, height: 4)
                        
                        Image(systemName: "ferry.fill")
                            .foregroundStyle(.tint)
                            .background(Color(.systemBackground))
                            .offset(x: (context.attributes.progress * 350) - 10)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(16)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "ferry.fill")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.vesselName)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(context.state.currentStatus)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    CapacityIndicator(percentageFull: context.state.percentageFull)
                        .frame(width: 80)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    HStack(spacing: 4) {
                        Text(context.attributes.departureTerminal)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.arrivalTerminal)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    
                    // Progress Bar
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 2)
                        
                        if !context.state.isCancelled {
                            Rectangle()
                                .fill(.tint)
                                .frame(width: context.attributes.progress * 200, height: 2)
                            
                            Image(systemName: "ferry.fill")
                                .font(.caption2)
                                .foregroundStyle(.tint)
                                .background(Color(.systemBackground))
                                .offset(x: (context.attributes.progress * 200) - 8)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label {
                            Text(context.attributes.scheduledDeparture, style: .time)
                        } icon: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.green)
                        }
                        
                        Spacer()
                        
                        Label {
                            Text(context.attributes.scheduledArrival, style: .time)
                        } icon: {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .font(.caption)
                }
            } compactLeading: {
                Label {
                    Text(context.state.currentStatus)
                } icon: {
                    Image(systemName: "ferry.fill")
                }
                .font(.caption2)
            } compactTrailing: {
                Text("\(context.state.percentageFull)%")
                    .font(.caption2)
                    .fontWeight(.medium)
            } minimal: {
                Image(systemName: "ferry.fill")
            }
        }
    }
} 