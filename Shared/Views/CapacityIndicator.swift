import SwiftUI

struct CapacityIndicator: View {
    let percentageFull: Int
    
    private var color: Color {
        switch percentageFull {
        case 0...60: return .green
        case 61...85: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percentageFull) / 100)
                }
            }
            .frame(width: 60, height: 12)
            
            // Percentage
            Text("\(percentageFull)%")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundColor(color)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
} 