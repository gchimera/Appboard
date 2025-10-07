import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AppGridItem: View {
    let app: AppInfo
    let iconSize: CGFloat
    let onShowDetails: (AppInfo) -> Void

    // Selezione multipla in modalità griglia
    var selectionEnabled: Bool = false
    var isSelected: Bool = false
    var onToggleSelection: (() -> Void)? = nil
    var makeDragItemProvider: (() -> NSItemProvider)? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Image(nsImage: app.iconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                
                Text(app.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            if selectionEnabled {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .padding(6)
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.6))
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
        }
        .frame(width: max(iconSize + 32, 100), height: iconSize + 60)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            if selectionEnabled {
                onToggleSelection?()
            } else {
                openApp()
            }
        }
        .onDrag {
            if let provider = makeDragItemProvider?() {
                return provider
            }
            // Crea i dati per il drag singolo
            if let appData = try? JSONEncoder().encode(app) {
                let itemProvider = NSItemProvider()
                itemProvider.registerDataRepresentation(forTypeIdentifier: "com.appboard.app-info", visibility: .all) { completion in
                    completion(appData, nil)
                    return nil
                }
                itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                    completion(appData, nil)
                    return nil
                }
                return itemProvider
            }
            return NSItemProvider()
        }
        .contextMenu {
            Button("Apri") {
                openApp()
            }
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
    }
    
    private func openApp() {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
}
