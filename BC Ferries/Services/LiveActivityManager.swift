import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private init() {}
    
    func startSailingActivity(for sailing: Sailing) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not supported")
            return
        }
        
        let initialContentState = SailingActivityAttributes.SailingStatus(
            percentageFull: sailing.percentageFull,
            isCancelled: sailing.isCancelled,
            currentStatus: "Scheduled"
        )
        
        let activityAttributes = SailingActivityAttributes(
            departureTerminal: Terminal.terminals[sailing.departureTerminal]?.name ?? sailing.departureTerminal,
            arrivalTerminal: Terminal.terminals[sailing.arrivalTerminal]?.name ?? sailing.arrivalTerminal,
            vesselName: sailing.vesselName,
            scheduledDeparture: sailing.scheduledDeparture,
            scheduledArrival: sailing.scheduledArrival
        )
        
        do {
            let activity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState,
                pushType: nil
            )
            print("Requested Live Activity \(activity.id)")
        } catch {
            print("Error requesting Live Activity \(error.localizedDescription)")
        }
    }
    
    func updateSailingActivity(for sailing: Sailing) {
        Task {
            let activityState = SailingActivityAttributes.SailingStatus(
                percentageFull: sailing.percentageFull,
                isCancelled: sailing.isCancelled,
                currentStatus: determineStatus(for: sailing)
            )
            
            for activity in Activity<SailingActivityAttributes>.activities {
                await activity.update(using: activityState)
            }
        }
    }
    
    func stopSailingActivity(for sailing: Sailing) {
        Task {
            for activity in Activity<SailingActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
    
    private func determineStatus(for sailing: Sailing) -> String {
        let now = Date()
        if sailing.isCancelled {
            return "Cancelled"
        } else if now < sailing.scheduledDeparture {
            return "Scheduled"
        } else if now >= sailing.scheduledDeparture && now <= sailing.scheduledArrival {
            return "En Route"
        } else {
            return "Completed"
        }
    }
} 