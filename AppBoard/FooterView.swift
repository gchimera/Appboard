import SwiftUI

struct FooterView: View {
    let totalApps: Int
    let filteredCount: Int
    
    var body: some View {
        HStack {
            if filteredCount < totalApps {
                Text("\(filteredCount) di \(totalApps) app")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("\(totalApps) app totali")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Informazioni aggiuntive opzionali
            Text("App Organizer v1.0")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
