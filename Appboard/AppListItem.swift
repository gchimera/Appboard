import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AppListItem: View {
    let app: AppInfo
    let onShowDetails: (AppInfo) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: app.iconImage)
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(app.category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
            
            Text("v\(app.version)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            
            Text(app.size)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)
            
            Text(formatRelativeDate(app.lastUsed))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        // In List, la selezione nativa gestisce il click; il doppio click è definito nel contenitore.
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
            Divider()
            Button("Copia Percorso") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(app.path, forType: .string)
            }
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func openApp() {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
}
