import SwiftUI
import UniformTypeIdentifiers

struct BackupView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var backupManager = BackupManager.shared
    @State private var showExportPanel = false
    @State private var showImportPanel = false
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    @State private var backupContent = ""
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("backup_restore".localized())
                    .font(.title)
                
                Spacer()
                
                Button("close".localized()) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            
            // Sezione Esportazione
            GroupBox(label: Label("export_backup".localized(), systemImage: "square.and.arrow.up")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("backup_description".localized())
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        Task { @MainActor in
                            isProcessing = true
                            do {
                                backupContent = try backupManager.generateBackupJson(
                                    apps: appManager.apps,
                                    webLinks: appManager.webLinks,
                                    categories: appManager.categories
                                )
                                showExportPanel = true
                            } catch {
                                alertMessage = "backup_error".localized()
                                showErrorAlert = true
                            }
                            isProcessing = false
                        }
                    }) {
                        Label("export_backup".localized(), systemImage: "arrow.up.doc")
                    }
                    .disabled(isProcessing)
                }
                .padding()
            }
            .padding(.horizontal)
            
            // Sezione Importazione
            GroupBox(label: Label("import_backup".localized(), systemImage: "square.and.arrow.down")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("backup_description".localized())
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showImportPanel = true
                    }) {
                        Label("import_backup".localized(), systemImage: "arrow.down.doc")
                    }
                    .disabled(isProcessing)
                }
                .padding()
            }
            .padding(.horizontal)
            
            Spacer()
            
            if isProcessing {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }
        }
        .frame(width: 400, height: 400)
        .disabled(isProcessing)
        .fileExporter(
            isPresented: $showExportPanel,
            document: BackupDocument(initialText: backupContent),
            contentType: .json,
            defaultFilename: "AppBoard_Backup"
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(_):
                    alertMessage = "backup_success".localized()
                    showSuccessAlert = true
                case .failure(let error):
                    alertMessage = "backup_error".localized() + ": \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
        .fileImporter(
            isPresented: $showImportPanel,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            Task { @MainActor in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    
                    isProcessing = true
                    do {
                        let backup = try await backupManager.importBackup(from: url)
                        
                        if backupManager.validateBackup(backup) {
                            // Aggiorna le categorie
                            appManager.categories = backup.categories

                            // Salva le categorie personalizzate e l'ordine
                            appManager.saveCustomCategories()
                            appManager.saveCategoryOrder()

                            // Aggiorna le app e i link
                            appManager.apps = backup.apps
                            appManager.webLinks = backup.webLinks

                            // Salva la cache delle app e dei WebLinks
                            appManager.saveAppsCache()
                            appManager.saveWebLinks()

                            alertMessage = "restore_success".localized()
                            showSuccessAlert = true
                        } else {
                            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: backupManager.lastError ?? "invalid_backup".localized()])
                        }
                    } catch {
                        alertMessage = "restore_error".localized() + ": \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                    isProcessing = false
                    
                case .failure(let error):
                    alertMessage = "restore_error".localized() + ": \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
        .alert("Errore", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Successo", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

// Documento per l'esportazione
struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var text: String
    
    init(initialText: String = "") {
        text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}