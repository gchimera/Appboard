import SwiftUI
import AppKit

struct AppGridItem: View {
    let app: AppInfo
    let onShowDetails: (AppInfo) -> Void
    
    var body: some View {
        VStack {
            Image(nsImage: app.iconImage)
                .resizable()
                .frame(width: 64, height: 64)
            
            Text(app.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 100)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onTapGesture {
            // Singolo click = apri app
            openApp()
        }
        .onTapGesture(count: 2) {
            // Doppio click = mostra dettagli (opzionale)
            onShowDetails(app)
        }
        .contextMenu {
            Button("Apri") {
                onShowDetails(app) // Passa l'app selezionata
            }
            
            Button("Mostra Dettagli") {
                onShowDetails(app)
            }
            
            Divider()
            
            Button("Mostra nel Finder") {
                NSWorkspace.shared.selectFile(app.path, inFileViewerRootedAtPath: "")
            }
            
            Button("Ottieni Informazioni") {
                showGetInfo()
            }
        }
        .help(app.name) // Tooltip
    }
    
    private func openApp() {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error = error {
                print("Errore nell'aprire \(app.name): \(error.localizedDescription)")
                // Potresti mostrare un alert qui
            } else {
                print("Aperta app: \(app.name)")
            }
        }
    }
    
    private func showGetInfo() {
        // Mostra le informazioni dell'app usando Finder
        NSWorkspace.shared.openFile(app.path, withApplication: "Finder")
    }
}
