//
//  BC_FerriesWidgetExtensionLiveActivity.swift
//  BC FerriesWidgetExtension
//
//  Created by Noah Vandenberg on 2024-11-02.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BC_FerriesWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SailingActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack {
                HStack {
                    Text(context.attributes.vesselName)
                        .font(.headline)
                    Spacer()
                    if context.state.isCancelled {
                        Text("CANCELLED")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.attributes.departureTerminal)
                        Text(context.attributes.scheduledDeparture, style: .time)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(context.attributes.arrivalTerminal)
                        Text(context.attributes.scheduledArrival, style: .time)
                            .font(.caption)
                    }
                }
                .padding(.vertical)
                
                HStack {
                    Text(context.state.currentStatus)
                        .font(.subheadline)
                    Spacer()
                    CapacityIndicator(percentageFull: context.state.percentageFull)
                }
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.vesselName)
                            .font(.caption)
                        Text(context.state.currentStatus)
                            .font(.caption2)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    CapacityIndicator(percentageFull: context.state.percentageFull)
                        .frame(width: 80)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text(context.attributes.departureTerminal)
                        Image(systemName: "arrow.right")
                        Text(context.attributes.arrivalTerminal)
                    }
                    .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label {
                            Text(context.attributes.scheduledDeparture, style: .time)
                        } icon: {
                            Image(systemName: "arrow.up.circle")
                        }
                        
                        Spacer()
                        
                        Label {
                            Text(context.attributes.scheduledArrival, style: .time)
                        } icon: {
                            Image(systemName: "arrow.down.circle")
                        }
                    }
                    .font(.caption)
                }
            } compactLeading: {
                // Compact leading UI
                Label {
                    Text(context.state.currentStatus)
                } icon: {
                    Image(systemName: "ferry")
                }
                .font(.caption2)
            } compactTrailing: {
                // Compact trailing UI
                Text("\(context.state.percentageFull)%")
                    .font(.caption2)
            } minimal: {
                // Minimal UI
                Image(systemName: "ferry")
            }
        }
    }
}
