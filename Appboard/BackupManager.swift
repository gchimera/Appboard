import Foundation
import SwiftUI
import Combine

// Struttura che rappresenta il backup completo
struct AppBoardBackup: Codable {
    let version: String = "1.0"
    let createdAt: Date
    let apps: [AppInfo]
    let webLinks: [WebLink]
    let categories: [String]
    
    init(apps: [AppInfo], webLinks: [WebLink], categories: [String]) {
        self.createdAt = Date()
        self.apps = apps
        self.webLinks = webLinks
        self.categories = categories
    }
}

@MainActor
class BackupManager: ObservableObject {
    static let shared = BackupManager()
    private let fileManager = FileManager.default
    
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var lastError: String?
    
    private init() {}
    
    // Genera il contenuto JSON del backup
    func generateBackupJson(apps: [AppInfo], webLinks: [WebLink], categories: [String]) throws -> String {
        isExporting = true
        defer { isExporting = false }
        
        do {
            let backup = AppBoardBackup(apps: apps, webLinks: webLinks, categories: categories)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(backup)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Errore nella generazione del JSON"])
            }
            return jsonString
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
    
    // Importa il backup da un file JSON
    func importBackup(from url: URL) async throws -> AppBoardBackup {
        isImporting = true
        defer { isImporting = false }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(AppBoardBackup.self, from: data)
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
    
    // Valida il file di backup
    func validateBackup(_ backup: AppBoardBackup) -> Bool {
        // Verifica la versione del backup
        guard backup.version == "1.0" else {
            lastError = "Versione del backup non compatibile"
            return false
        }
        
        // Verifica che ci siano dati validi
        guard !backup.apps.isEmpty || !backup.webLinks.isEmpty else {
            lastError = "Il backup non contiene dati validi"
            return false
        }
        
        // Verifica che ci siano le categorie necessarie
        guard !backup.categories.isEmpty else {
            lastError = "Il backup non contiene categorie"
            return false
        }
        
        return true
    }
}