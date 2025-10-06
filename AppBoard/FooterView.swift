import SwiftUI

struct FooterView: View {
    let totalApps: Int
    let filteredCount: Int
    
    var body: some View {
        HStack {
            if filteredCount < totalApps {
                Text(String(format: "filtered_apps".localized(), filteredCount, totalApps))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(String(format: "total_apps".localized(), totalApps))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("drag_to_categories".localized())
                .font(.caption2)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
