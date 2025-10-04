import Foundation
import AppKit

struct AppInfo: Identifiable {
    let id: UUID
    let name: String
    let bundleIdentifier: String
    let version: String
    let path: String
    var category: String
    let size: String
    let sizeInBytes: Int64
    let lastUsed: Date
    
    // Computed property per l'icona - non stored property
    var iconImage: NSImage {
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    // Developer info derivata dal bundle ID
    var developer: String {
        if bundleIdentifier.contains("apple") {
            return "Apple Inc."
        } else if bundleIdentifier.contains("microsoft") {
            return "Microsoft Corporation"
        } else if bundleIdentifier.contains("adobe") {
            return "Adobe Inc."
        } else {
            return "Sconosciuto"
        }
    }
    
    init(id: UUID, name: String, bundleIdentifier: String, version: String, path: String, category: String, size: String, sizeInBytes: Int64, lastUsed: Date) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.path = path
        self.category = category
        self.size = size
        self.sizeInBytes = sizeInBytes
        self.lastUsed = lastUsed
    }
}

// Estensione per conformità Hashable se necessaria
extension AppInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
}
