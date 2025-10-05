import SwiftUI

struct SettingsView: View {
    @Binding var iconSize: CGFloat
    let iconSizes: [CGFloat]
    let iconSizeLabels: [CGFloat: String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @State private var showResetAlert = false

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
            
            // Gestione Categorie
            VStack(alignment: .leading, spacing: 12) {
                Text("Categorie")
                    .font(.headline)
                Text("Reimposta l'elenco delle categorie rimuovendo quelle aggiunte e riassegnando le app alle categorie iniziali.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle")
                        Text("Reset Categorie")
                    }
                }
                .help("Rimuove le categorie personalizzate e riassegna le app alle categorie iniziali")
            }
            .padding(.horizontal)
            .alert("Reset Categorie", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) {}
                Button("Conferma", role: .destructive) {
                    appManager.resetCategoriesToDefaults()
                }
            } message: {
                Text("Questa azione rimuoverà tutte le categorie aggiunte e riassegnerà le relative app alle categorie iniziali. L'operazione non può essere annullata.")
            }
            
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
        .frame(width: 500, height: 520)
        .padding()
    }
}
