import SwiftUI
import AppKit

struct AppGridItem: View {
    let app: AppInfo
    let iconSize: CGFloat
    let onShowDetails: (AppInfo) -> Void
    
    var body: some View {
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
        .frame(width: max(iconSize + 32, 100), height: iconSize + 60)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onTapGesture {
            openApp()
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
