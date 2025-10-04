import SwiftUI

struct SettingsView: View {
    @Binding var iconSize: CGFloat
    let iconSizes: [CGFloat]
    let iconSizeLabels: [CGFloat: String]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text("Impostazioni")
                .font(.title)
                .padding(.top)
            Divider()
            HStack {
                Image(systemName: "app.dashed")
                    .foregroundColor(.accentColor)
                Text("Dimensione icone")
                    .font(.headline)
                Spacer()
                Picker("Dimensione icone", selection: $iconSize) {
                    ForEach(iconSizes, id: \.self) { size in
                        Text(iconSizeLabels[size] ?? "\(Int(size)) pt").tag(size)
                    }
                }
                .frame(width: 150)
            }
            .padding(.horizontal)
            Spacer()
            Button("Chiudi") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 340, height: 200)
        .padding()
    }
}
