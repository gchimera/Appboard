import SwiftUI
import AppKit

// AppDetailView.swift
struct AppDetailView: View {
    let app: AppInfo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header con icona e info principali
                    HStack(spacing: 16) {
                        Image(nsImage: app.iconImage)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Versione \(app.version)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(app.developer)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Informazioni dettagliate
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informazioni")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        DetailRow(label: "Categoria", value: app.category, icon: "folder")
                        DetailRow(label: "Dimensione", value: app.size, icon: "externaldrive")
                        DetailRow(label: "Bundle ID", value: app.bundleIdentifier, icon: "doc.text")
                        DetailRow(label: "Percorso", value: app.path, icon: "folder.badge.gearshape")
                        DetailRow(label: "Ultimo utilizzo", value: formatDate(app.lastUsed), icon: "clock")
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Azioni
                    VStack(spacing: 12) {
                        Button(action: {
                            openApp()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Apri Applicazione")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                showInFinder()
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                    Text("Mostra nel Finder")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                getInfo()
                            }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("Ottieni Info")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dettagli App")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
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
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error = error {
                print("Errore nell'aprire l'app: \(error)")
            } else {
                dismiss()
            }
        }
    }
    
    private func showInFinder() {
        NSWorkspace.shared.selectFile(app.path, inFileViewerRootedAtPath: "")
    }
    
    private func getInfo() {
        NSWorkspace.shared.openFile(app.path, withApplication: "Finder")
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.body)
                    .lineLimit(nil)
                    .textSelection(.enabled)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
