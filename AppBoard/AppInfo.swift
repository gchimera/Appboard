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
    
    var iconImage: NSImage {
        return NSWorkspace.shared.icon(forFile: path)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, developer, bundleIdentifier, version, path, category, size, sizeInBytes, lastUsed
    }
}
