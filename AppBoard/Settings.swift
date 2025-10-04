import SwiftUI

struct SettingsView: View {
    @Binding var iconSize: CGFloat
    let iconSizes: [CGFloat]
    let iconSizeLabels: [CGFloat: String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Impostazioni")
                .font(.title)
                .padding(.top)
            
            Divider()
            
            // UI Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Interfaccia")
                    .font(.headline)
                
                HStack {
                    Text("Dimensione icone:")
                    Spacer()
                    Picker("Dimensione icone", selection: $iconSize) {
                        ForEach(iconSizes, id: \.self) { size in
                            Text(iconSizeLabels[size] ?? "\(Int(size)) pt").tag(size)
                        }
                    }
                    .frame(width: 150)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Sync Settings
            SyncSettingsSection()
                .padding(.horizontal)
            
            Spacer()
            
            Button("Chiudi") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 450, height: 400)
        .padding()
    }
}
