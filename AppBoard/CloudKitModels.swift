import Foundation
import CloudKit

// MARK: - Syncable Protocol
protocol CloudKitSyncable {
    var recordID: CKRecord.ID? { get set }
    var lastModified: Date { get set }
    func toCKRecord() -> CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Self?
}

// MARK: - Syncable App Data
struct SyncableAppData: CloudKitSyncable, Identifiable, Equatable {
    var id: String
    var recordID: CKRecord.ID?
    var bundleIdentifier: String
    var assignedCategory: String
    var lastModified: Date
    var deviceName: String // Per identificare da quale dispositivo proviene
    
    init(bundleIdentifier: String, assignedCategory: String, deviceName: String = NSFullUserName()) {
        self.id = bundleIdentifier
        self.bundleIdentifier = bundleIdentifier
        self.assignedCategory = assignedCategory
        self.lastModified = Date()
        self.deviceName = deviceName
    }
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "AppAssignment", recordID: recordID ?? CKRecord.ID())
        record["bundleIdentifier"] = bundleIdentifier as CKRecordValue
        record["assignedCategory"] = assignedCategory as CKRecordValue
        record["lastModified"] = lastModified as CKRecordValue
        record["deviceName"] = deviceName as CKRecordValue
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> SyncableAppData? {
        guard let bundleIdentifier = record["bundleIdentifier"] as? String,
              let assignedCategory = record["assignedCategory"] as? String,
              let lastModified = record["lastModified"] as? Date,
              let deviceName = record["deviceName"] as? String else {
            return nil
        }
        
        var appData = SyncableAppData(bundleIdentifier: bundleIdentifier, 
                                     assignedCategory: assignedCategory, 
                                     deviceName: deviceName)
        appData.recordID = record.recordID
        appData.lastModified = lastModified
        return appData
    }
    
    static func == (lhs: SyncableAppData, rhs: SyncableAppData) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

// MARK: - SyncableAppData Codable Implementation
extension SyncableAppData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, bundleIdentifier, assignedCategory, lastModified, deviceName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
        assignedCategory = try container.decode(String.self, forKey: .assignedCategory)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        deviceName = try container.decode(String.self, forKey: .deviceName)
        recordID = nil // Non decodifichiamo recordID perché non è Codable
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(assignedCategory, forKey: .assignedCategory)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(deviceName, forKey: .deviceName)
        // Non encodiamo recordID perché non è Codable
    }
}

// MARK: - Syncable Category Data
struct SyncableCategoryData: CloudKitSyncable, Identifiable, Equatable {
    var id: String
    var recordID: CKRecord.ID?
    var name: String
    var icon: String
    var isCustom: Bool
    var lastModified: Date
    var deviceName: String
    
    init(name: String, icon: String, isCustom: Bool = true, deviceName: String = NSFullUserName()) {
        self.id = name
        self.name = name
        self.icon = icon
        self.isCustom = isCustom
        self.lastModified = Date()
        self.deviceName = deviceName
    }
    
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "CustomCategory", recordID: recordID ?? CKRecord.ID())
        record["name"] = name as CKRecordValue
        record["icon"] = icon as CKRecordValue
        record["isCustom"] = (isCustom ? 1 : 0) as CKRecordValue
        record["lastModified"] = lastModified as CKRecordValue
        record["deviceName"] = deviceName as CKRecordValue
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> SyncableCategoryData? {
        guard let name = record["name"] as? String,
              let icon = record["icon"] as? String,
              let isCustomValue = record["isCustom"] as? Int,
              let lastModified = record["lastModified"] as? Date,
              let deviceName = record["deviceName"] as? String else {
            return nil
        }
        
        var categoryData = SyncableCategoryData(name: name, 
                                               icon: icon, 
                                               isCustom: isCustomValue == 1,
                                               deviceName: deviceName)
        categoryData.recordID = record.recordID
        categoryData.lastModified = lastModified
        return categoryData
    }
    
    static func == (lhs: SyncableCategoryData, rhs: SyncableCategoryData) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - SyncableCategoryData Codable Implementation
extension SyncableCategoryData: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, icon, isCustom, lastModified, deviceName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        isCustom = try container.decode(Bool.self, forKey: .isCustom)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        deviceName = try container.decode(String.self, forKey: .deviceName)
        recordID = nil // Non decodifichiamo recordID perché non è Codable
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(isCustom, forKey: .isCustom)
        try container.encode(lastModified, forKey: .lastModified)
        try container.encode(deviceName, forKey: .deviceName)
        // Non encodiamo recordID perché non è Codable
    }
}

// MARK: - Sync Status
enum SyncStatus: String, CaseIterable {
    case idle = "idle"
    case syncing = "syncing" 
    case success = "success"
    case error = "error"
    case offline = "offline"
    
    var displayName: String {
        switch self {
        case .idle: return "Inattivo"
        case .syncing: return "Sincronizzazione..."
        case .success: return "Sincronizzato"
        case .error: return "Errore"
        case .offline: return "Offline"
        }
    }
    
    var icon: String {
        switch self {
        case .idle: return "icloud"
        case .syncing: return "icloud.and.arrow.up"
        case .success: return "icloud"
        case .error: return "icloud.slash"
        case .offline: return "wifi.slash"
        }
    }
}

// MARK: - Sync Configuration
struct SyncConfiguration {
    static let shared = SyncConfiguration()
    
    // Usando il container di default di CloudKit (basato sul Bundle ID)
    let containerIdentifier = "iCloud.com.appboard.mac" // Info: usando CKContainer.default()
    let appAssignmentRecordType = "AppAssignment"
    let customCategoryRecordType = "CustomCategory"
    
    // Intervallo di sincronizzazione automatica (in secondi)
    let autoSyncInterval: TimeInterval = 300 // 5 minuti
    
    // Timeout per le operazioni di sync
    let operationTimeout: TimeInterval = 30
    
    private init() {}
}
