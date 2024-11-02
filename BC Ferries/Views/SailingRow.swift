import SwiftUI

struct SailingRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let sailing: Sailing
    @State private var isFavorite: Bool
    @State private var progress: Double
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    init(sailing: Sailing) {
        self.sailing = sailing
        self._isFavorite = State(initialValue: UserPreferences.shared.isFavoriteSailing(sailing))
        self._progress = State(initialValue: sailing.progress)
    }
    
    private var progressBarWidth: CGFloat {
        let maxWidth: CGFloat = 200 // Set a reasonable max width for the progress bar
        return max(4, progress * maxWidth)
    }
    
    private var progressColor: Color {
        progress == 0 ? .purple : .blue
    }
    
    var statusBadge: some View {
        HStack(spacing: 6) {
            if sailing.isCancelled {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("CANCELLED")
            } else if progress >= 1 {
                Image(systemName: "checkmark.circle.fill")
                Text("COMPLETED")
            } else if progress > 0 {
                Image(systemName: "ferry.fill")
                Text("EN ROUTE")
            } else {
                Image(systemName: "clock.fill")
                Text("SCHEDULED")
            }
        }
        .font(.caption.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            sailing.isCancelled ? Color.red.gradient :
            progress >= 1 ? Color.green.gradient :
            progress > 0 ? Color.blue.gradient :
            Color.purple.gradient
        )
        .clipShape(Capsule())
    }
    
    var body: some View {
        NavigationLink {
            SailingDetailView(sailing: sailing)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header: Times and Progress
                HStack(alignment: .center, spacing: 16) {
                    // Departure
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sailing.scheduledDeparture, style: .time)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("Departure")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 80, alignment: .leading)
                    
                    // Progress Bar
                    VStack(spacing: 4) {
                        // Progress Track
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.quaternary)
                                .frame(height: 4)
                            
                            // Progress markers
                            HStack(spacing: 0) {
                                ForEach(0..<5) { i in
                                    Capsule()
                                        .fill(.quaternary)
                                        .frame(width: 2, height: 4)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            if !sailing.isCancelled {
                                // Progress fill
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                progressColor,
                                                progressColor.opacity(0.5)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: progressBarWidth, height: 4)
                                
                                // Ferry icon
                                Image(systemName: "ferry.fill")
                                    .font(.caption2)
                                    .foregroundStyle(progressColor)
                                    .background(
                                        Circle()
                                            .fill(.background)
                                            .padding(2)
                                    )
                                    .offset(x: progressBarWidth - 8)
                            }
                        }
                        .padding(.horizontal, 2)
                        
                        // Vessel name
                        Text(sailing.vesselName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Arrival
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(sailing.scheduledArrival, style: .time)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("Arrival")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 80, alignment: .trailing)
                }
                
                // Footer: Status and Controls
                HStack(alignment: .center, spacing: 12) {
                    statusBadge
                    
                    Spacer()
                    
                    if !sailing.isCancelled {
                        if progress > 0 && progress < 1 {
                            // Progress percentage for en route
                            Text("\(Int(progress * 100))%")
                                .font(.caption.bold())
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .clipShape(Capsule())
                        } else if progress == 0 {
                            // Capacity for scheduled
                            HStack(spacing: 8) {
                                // Favorite button
                                Button {
                                    toggleFavorite()
                                } label: {
                                    Image(systemName: isFavorite ? "bell.fill" : "bell")
                                        .symbolEffect(.bounce, value: isFavorite)
                                        .foregroundStyle(isFavorite ? .yellow : .secondary)
                                        .font(.system(.body, design: .rounded))
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                                
                                // Capacity
                                CapacityIndicator(percentageFull: sailing.percentageFull)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: min(600, UIScreen.main.bounds.width - 32)) // Add max width constraint
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(
                        color: colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.05),
                        radius: 3,
                        y: 2
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05),
                                lineWidth: 0.5
                            )
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .animation(.smooth, value: progress)
            .onReceive(timer) { _ in
                progress = sailing.progress
            }
        }
    }
    
    private func toggleFavorite() {
        withAnimation(.bouncy) {
            if isFavorite {
                UserPreferences.shared.removeFavoriteSailing(sailing)
                LiveActivityManager.shared.stopSailingActivity(for: sailing)
            } else {
                UserPreferences.shared.saveFavoriteSailing(sailing)
                LiveActivityManager.shared.startSailingActivity(for: sailing)
            }
            isFavorite.toggle()
        }
    }
} 