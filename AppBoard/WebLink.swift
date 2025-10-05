import Foundation
import AppKit

struct WebLink: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var faviconData: Data?
    var categoryName: String?
    var description: String?
    var dateAdded: Date
    
    init(id: UUID = UUID(), name: String, url: String, faviconData: Data? = nil, categoryName: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.url = url
        self.faviconData = faviconData
        self.categoryName = categoryName
        self.description = description
        self.dateAdded = Date()
    }
    
    var favicon: NSImage? {
        guard let data = faviconData else { return nil }
        return NSImage(data: data)
    }
    
    var displayURL: String {
        // Extract domain from URL for display
        if let url = URL(string: url),
           let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WebLink, rhs: WebLink) -> Bool {
        lhs.id == rhs.id
    }
}

// Extension for CloudKit sync
extension WebLink {
    struct CloudKitData: Codable {
        let id: String
        let name: String
        let url: String
        let faviconData: Data?
        let categoryName: String?
        let description: String?
        let dateAdded: Date
    }
    
    var cloudKitData: CloudKitData {
        CloudKitData(
            id: id.uuidString,
            name: name,
            url: url,
            faviconData: faviconData,
            categoryName: categoryName,
            description: description,
            dateAdded: dateAdded
        )
    }
    
    init?(from cloudKitData: CloudKitData) {
        guard let id = UUID(uuidString: cloudKitData.id) else { return nil }
        
        self.id = id
        self.name = cloudKitData.name
        self.url = cloudKitData.url
        self.faviconData = cloudKitData.faviconData
        self.categoryName = cloudKitData.categoryName
        self.description = cloudKitData.description
        self.dateAdded = cloudKitData.dateAdded
    }
}
