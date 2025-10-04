import SwiftUI
import AppKit

struct AppListItem: View {
    let app: AppInfo
    let onShowDetails: (AppInfo) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icona app
            Image(nsImage: app.iconImage)
                .resizable()
                .frame(width: 32, height: 32)
            
            // Informazioni principali
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(app.developer)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Categoria
            Text(app.category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
            
            // Versione
            Text("v\(app.version)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            
            // Dimensione
            Text(app.size)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
            
            // Data ultimo utilizzo
            Text(formatRelativeDate(app.lastUsed))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            // Singolo click = apri app
            openApp()
        }
        .onTapGesture(count: 2) {
            // Doppio click = mostra dettagli (opzionale)
            onShowDetails(app)
        }
        .contextMenu {
            // Azione Apri: apre direttamente l'applicazione
            Button("Apri") {
                let url = URL(fileURLWithPath: app.path)
                NSWorkspace.shared.openApplication(
                    at: url,
                    configuration: NSWorkspace.OpenConfiguration(),
                    completionHandler: nil
                )
            }
            
            // Mostra Dettagli: mostra la scheda dettagliata
            Button("Mostra Dettagli") {
                onShowDetails(app)
            }
            
            Divider()
            
            Button("Mostra nel Finder") {
                NSWorkspace.shared.selectFile(app.path, inFileViewerRootedAtPath: "")
            }
            Button("Ottieni Informazioni") {
                NSWorkspace.shared.openFile(app.path, withApplication: "Finder")
            }
        }

        .help(app.name) // Tooltip
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func openApp() {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error = error {
                print("Errore nell'aprire \(app.name): \(error.localizedDescription)")
            } else {
                print("Aperta app: \(app.name)")
            }
        }
    }
    
    private func showGetInfo() {
        NSWorkspace.shared.openFile(app.path, withApplication: "Finder")
    }
}

