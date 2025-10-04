import SwiftUI
import AppKit

struct AppDetailView: View {
    let app: AppInfo
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @State private var showCategorySelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                Image(nsImage: app.iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 74, height: 74)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.system(.title, design: .rounded).bold())
                        .lineLimit(2)
                    Text("Versione \(app.version)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding([.horizontal, .top], 24)
            .padding(.bottom, 16)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 16) {
                        Button(action: openApp) {
                            Label("Apri App", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: showInFinder) {
                            Label("Mostra nel Finder", systemImage: "folder.fill")
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: copyPath) {
                            Label("Copia percorso", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }
                    Divider()
                    categoryRow()
                    infoRow(label: "Dimensione", value: app.size, icon: "internaldrive")
                    infoRow(label: "Bundle ID", value: app.bundleIdentifier, icon: "doc.plaintext")
                    infoRow(label: "Percorso", value: app.path, icon: "signpost.right")
                    infoRow(label: "Ultimo utilizzo", value: formatDate(app.lastUsed), icon: "clock.arrow.circlepath")
                }
                .padding(24)
            }
        }
        .frame(width: 480, height: 440)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(radius: 20)
        .sheet(isPresented: $showCategorySelector) {
            CategorySelectorView(
                app: app,
                appManager: appManager
            ) { newCategory in
                appManager.updateAppCategory(appId: app.id, newCategory: newCategory)
            }
        }
    }
    
    @ViewBuilder
    func categoryRow() -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "tag.fill")
                .foregroundColor(.accentColor)
                .frame(width: 23)
            VStack(alignment: .leading, spacing: 2) {
                Text("Categoria").font(.caption).foregroundColor(.secondary)
                HStack {
                    HStack(spacing: 6) {
                        CategoryIconView(category: app.category, size: 16)
                        Text(app.category)
                            .font(.body)
                    }
                    Spacer()
                    Button("Cambia") {
                        showCategorySelector = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
    
    @ViewBuilder
    func infoRow(label: String, value: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 23)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value).font(.body).textSelection(.enabled)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    private func openApp() {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        dismiss()
    }
    
    private func showInFinder() {
        NSWorkspace.shared.selectFile(app.path, inFileViewerRootedAtPath: "")
    }
    
    private func copyPath() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(app.path, forType: .string)
    }
}
