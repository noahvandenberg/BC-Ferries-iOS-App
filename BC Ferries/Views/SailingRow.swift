import SwiftUI

struct SailingRow: View {
    let sailing: Sailing
    @State private var isFavorite: Bool
    @State private var progress: Double
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    init(sailing: Sailing) {
        self.sailing = sailing
        self._isFavorite = State(initialValue: UserPreferences.shared.isFavoriteSailing(sailing))
        self._progress = State(initialValue: sailing.progress)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Time and Status Header
            HStack(alignment: .center, spacing: 16) {
                // Departure Time
                VStack(alignment: .leading, spacing: 4) {
                    Text(sailing.scheduledDeparture, style: .time)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Departure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 80, alignment: .leading)
                
                // Progress indicator
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                        .overlay {
                            // Progress markers
                            HStack(spacing: 0) {
                                ForEach(0..<5) { i in
                                    Capsule()
                                        .fill(.gray.opacity(0.2))
                                        .frame(width: 2, height: 6)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    
                    if !sailing.isCancelled {
                        // Progress bar with gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, progress * 100), height: 6)
                            .animation(.smooth, value: progress)
                        
                        // Ferry icon with shadow and glow
                        Image(systemName: "ferry.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .padding(4)
                            )
                            .background(
                                Circle()
                                    .fill(.blue.opacity(0.2))
                                    .blur(radius: 4)
                                    .padding(2)
                            )
                            .offset(x: (progress * 100) - 10)
                            .animation(.smooth, value: progress)
                    }
                }
                .padding(.vertical, 8) // Increase touch target
                
                // Arrival Time
                VStack(alignment: .trailing, spacing: 4) {
                    Text(sailing.scheduledArrival, style: .time)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Arrival")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(minWidth: 80, alignment: .trailing)
            }
            .padding(.horizontal, 4)
            
            // Status and Controls
            HStack(spacing: 12) {
                // Status with Icon and Progress Text
                HStack(spacing: 6) {
                    Label(sailing.status, systemImage: "clock.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !sailing.isCancelled && progress > 0 && progress < 1 {
                        Text("\(Int(progress * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Notification Bell
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "bell.fill" : "bell")
                        .symbolEffect(.bounce, value: isFavorite)
                        .foregroundColor(isFavorite ? .yellow : .gray)
                        .font(.system(.body, design: .rounded))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                
                // Capacity Indicator
                CapacityIndicator(percentageFull: sailing.percentageFull)
            }
            
            // Cancellation Badge
            if sailing.isCancelled {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("CANCELLED")
                        .fontWeight(.medium)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.gradient)
                .clipShape(Capsule())
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onReceive(timer) { _ in
            progress = sailing.progress
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