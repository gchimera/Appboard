import Foundation
import AppKit

struct AppInfo: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let developer: String
    let bundleIdentifier: String
    let version: String
    let path: String
    var category: String
    let size: String
    let sizeInBytes: Int64
    let lastUsed: Date
    
    // Metadati di sincronizzazione CloudKit
    var lastCategoryChange: Date
    var syncedToCloud: Bool
    var isProblematic: Bool // Flag per app con Info.plist mancante
    
    var iconImage: NSImage {
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    // Inizializzatore che include i nuovi campi di sync
    init(id: UUID, name: String, developer: String, bundleIdentifier: String, 
         version: String, path: String, category: String, size: String, 
         sizeInBytes: Int64, lastUsed: Date, lastCategoryChange: Date = Date(), 
         syncedToCloud: Bool = false, isProblematic: Bool = false) {
        self.id = id
        self.name = name
        self.developer = developer
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.path = path
        self.category = category
        self.size = size
        self.sizeInBytes = sizeInBytes
        self.lastUsed = lastUsed
        self.lastCategoryChange = lastCategoryChange
        self.syncedToCloud = syncedToCloud
        self.isProblematic = isProblematic
    }
    
    // Metodo per aggiornare la categoria con timestamp
    func withUpdatedCategory(_ newCategory: String) -> AppInfo {
        AppInfo(
            id: self.id,
            name: self.name,
            developer: self.developer,
            bundleIdentifier: self.bundleIdentifier,
            version: self.version,
            path: self.path,
            category: newCategory,
            size: self.size,
            sizeInBytes: self.sizeInBytes,
            lastUsed: self.lastUsed,
            lastCategoryChange: Date(),
            syncedToCloud: false
        )
    }
    
    // Metodo per marcare come sincronizzato
    func markAsSynced() -> AppInfo {
        AppInfo(
            id: self.id,
            name: self.name,
            developer: self.developer,
            bundleIdentifier: self.bundleIdentifier,
            version: self.version,
            path: self.path,
            category: self.category,
            size: self.size,
            sizeInBytes: self.sizeInBytes,
            lastUsed: self.lastUsed,
            lastCategoryChange: self.lastCategoryChange,
            syncedToCloud: true
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, developer, bundleIdentifier, version, path, category, size, sizeInBytes, lastUsed, lastCategoryChange, syncedToCloud, isProblematic
    }
}
