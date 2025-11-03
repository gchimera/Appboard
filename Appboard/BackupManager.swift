import Foundation
import SwiftUI
import Combine

// Struttura che rappresenta il backup completo
struct AppBoardBackup: Codable {
    let version: String
    let createdAt: Date
    let apps: [AppInfo]
    let webLinks: [WebLink]
    let categories: [String]
    
    init(apps: [AppInfo], webLinks: [WebLink], categories: [String]) {
        self.version = "1.0"
        self.createdAt = Date()
        self.apps = apps
        self.webLinks = webLinks
        self.categories = categories
    }
    
    enum CodingKeys: String, CodingKey {
        case version
        case createdAt
        case apps
        case webLinks
        case categories
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
            // Gestisci URL sicuri (security-scoped URLs) dal fileImporter di SwiftUI
            let accessibleURL = url
            
            // Se l'URL è un security-scoped URL, inizia ad accedervi
            if url.startAccessingSecurityScopedResource() {
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                do {
                    // Verifica che il file esista e sia accessibile
                    guard fileManager.fileExists(atPath: accessibleURL.path) else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Il file non esiste o non è accessibile"])
                    }
                    
                    // Prova diversi approcci per accedere al file
                    let data: Data
                    do {
                        // Metodo 1: Leggi direttamente dal file
                        data = try Data(contentsOf: accessibleURL)
                    } catch {
                        // Metodo 2: Se fallisce, prova a copiare in posizione temporanea
                        do {
                            let tempDirectory = fileManager.temporaryDirectory
                            let tempFileName = "AppBoard_Backup_\(UUID().uuidString).json"
                            let tempURL = tempDirectory.appendingPathComponent(tempFileName)
                            
                            // Copia il file
                            try fileManager.copyItem(at: accessibleURL, to: tempURL)
                            
                            // Leggi dal file temporaneo
                            data = try Data(contentsOf: tempURL)
                            
                            // Pulisci il file temporaneo
                            try? fileManager.removeItem(at: tempURL)
                        } catch let copyError {
                            // Metodo 3: Se anche la copia fallisce, prova a leggere con FileHandle
                            if let fileHandle = try? FileHandle(forReadingFrom: accessibleURL) {
                                defer { fileHandle.closeFile() }
                                data = fileHandle.readDataToEndOfFile()
                            } else {
                                // Se tutto fallisce, rilancia l'errore originale
                                throw copyError
                            }
                        }
                    }
                    
                    // Verifica che i dati non siano vuoti
                    guard !data.isEmpty else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Il file di backup è vuoto"])
                    }
                    
                    // Decodifica il JSON
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let backup = try decoder.decode(AppBoardBackup.self, from: data)
                    
                    // Verifica che i dati del backup siano validi
                    guard !backup.apps.isEmpty || !backup.webLinks.isEmpty else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Il file di backup è vuoto o corrotto"])
                    }
                    
                    return backup
                }
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Impossibile accedere al file selezionato"])
            }
        } catch {
            // Gestisci errori specifici con messaggi più chiari
            let nsError = error as NSError
            
            // Errori specifici del sistema
            if nsError.domain == "NSCocoaErrorDomain" {
                switch nsError.code {
                case 257: // NSFileReadNoPermissionError
                    lastError = "Il file non può essere aperto perché non hai i privilegi necessari. Verificare che il file non sia protetto da password o crittografato."
                case 260: // NSFileNoSuchFileError
                    lastError = "Il file specificato non è stato trovato."
                case 261: // NSFileReadInvalidFileNameError
                    lastError = "Nome del file non valido."
                default:
                    lastError = "Errore di accesso al file: \(error.localizedDescription)"
                }
            } else if error.localizedDescription.contains("permission") || error.localizedDescription.contains("privilegi") {
                lastError = "Permessi insufficienti per accedere al file. Prova a copiare il file in una posizione accessibile."
            } else if error.localizedDescription.contains("corrupt") || error.localizedDescription.contains("invalid") {
                lastError = "Il file di backup è corrotto o in un formato non valido."
            } else if error.localizedDescription.contains("no such file or directory") {
                lastError = "Il file non esiste o è stato spostato."
            } else if error.localizedDescription.contains("not authorized") {
                lastError = "Accesso al file non autorizzato. Verificare i permessi del file."
            } else {
                lastError = "Errore durante l'importazione: \(error.localizedDescription)"
            }
            
            print("Errore dettagliato importazione backup: \(error)")
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