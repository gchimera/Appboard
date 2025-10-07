import Foundation
import CloudKit
import Combine
import Network

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncEnabled: Bool = true
    @Published var isOnline: Bool = true
    
    private let container: CKContainer
    private let database: CKDatabase
    private let config = SyncConfiguration.shared
    private let monitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var autoSyncTimer: Timer?
    
    // Cache per le operazioni offline
    private var pendingOperations: [CloudKitOperation] = []
    
    private init() {
        // Inizializzazione base
        container = CKContainer.default()
        database = container.privateCloudDatabase
        
        // Carica impostazioni da UserDefaults
        syncEnabled = UserDefaults.standard.object(forKey: "cloudKitSyncEnabled") as? Bool ?? true
        
        // Verifica disponibilità CloudKit prima di procedere
        Task { @MainActor in
            await checkCloudKitAvailability()
        }
    }
    
    private func checkCloudKitAvailability() async {
        let accountStatus = await checkAccountStatus()
        
        switch accountStatus {
        case .available:
            print("CloudKit disponibile, inizializzazione in corso...")
            await setupAsync()
        case .noAccount:
            print("Nessun account iCloud configurato. CloudKit disabilitato.")
            syncEnabled = false
            syncStatus = .offline
        case .restricted:
            print("Account iCloud limitato. CloudKit disabilitato.")
            syncEnabled = false
            syncStatus = .error
        case .couldNotDetermine:
            print("Impossibile determinare lo stato dell'account iCloud. CloudKit disabilitato.")
            syncEnabled = false
            syncStatus = .error
        @unknown default:
            print("Stato account iCloud sconosciuto. CloudKit disabilitato.")
            syncEnabled = false
            syncStatus = .error
        }
    }
    
    private func setupAsync() async {
        // Configurazione del monitoring di rete
        setupNetworkMonitoring()
        
        // Caricamento delle operazioni pendenti
        loadPendingOperations()
        
        // Setup auto-sync
        if syncEnabled {
            startAutoSync()
        }
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                
                if path.status == .satisfied && self?.syncEnabled == true {
                    // Se torniamo online, proviamo a sincronizzare le operazioni pendenti
                    Task {
                        await self?.processPendingOperations()
                    }
                } else if path.status != .satisfied {
                    self?.syncStatus = .offline
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    // MARK: - Auto Sync
    
    func startAutoSync() {
        guard syncEnabled else { return }
        
        autoSyncTimer?.invalidate()
        autoSyncTimer = Timer.scheduledTimer(withTimeInterval: config.autoSyncInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.syncAll()
            }
        }
    }
    
    func stopAutoSync() {
        autoSyncTimer?.invalidate()
        autoSyncTimer = nil
    }
    
    // MARK: - Sync Operations
    
    func syncAll() async {
        guard syncEnabled && isOnline else {
            syncStatus = isOnline ? .idle : .offline
            return
        }
        
        syncStatus = .syncing
        
        do {
            // Verifica account prima di sincronizzare
            let accountStatus = await checkAccountStatus()
            guard accountStatus == .available else {
                syncStatus = .error
                print("Account iCloud non disponibile per la sincronizzazione")
                return
            }
            
            // Sincronizza le categorie personalizzate prima delle assegnazioni
            try await syncCustomCategories()
            try await syncAppAssignments()
            
            syncStatus = .success
            lastSyncDate = Date()
            print("Sincronizzazione completata con successo")
            
        } catch {
            syncStatus = .error
            let errorMessage = error.localizedDescription
            print("Errore durante la sincronizzazione: \(errorMessage)")
            
            // Se è un errore di configurazione CloudKit, disabilita la sincronizzazione
            if errorMessage.contains("entitlement") || 
               errorMessage.contains("CloudKit") || 
               errorMessage.contains("container configuration") || 
               errorMessage.contains("server") {
                print("Errore di configurazione CloudKit rilevato. Disabilitazione sincronizzazione.")
                syncEnabled = false
                UserDefaults.standard.set(false, forKey: "cloudKitSyncEnabled")
            }
        }
    }
    
    func syncCustomCategories() async throws {
        // Upload categorie locali
        try await uploadLocalCategories()
        
        // Download categorie remote
        try await downloadRemoteCategories()
    }
    
    func syncAppAssignments() async throws {
        // Upload assegnazioni locali
        try await uploadLocalAppAssignments()
        
        // Download assegnazioni remote
        try await downloadRemoteAppAssignments()
    }
    
    // MARK: - Upload Operations
    
    private func uploadLocalCategories() async throws {
        let localCategories = await getLocalCustomCategories()
        
        for categoryData in localCategories {
            let record = categoryData.toCKRecord()
            try await saveRecord(record)
        }
    }
    
    private func uploadLocalAppAssignments() async throws {
        let localAssignments = await getLocalAppAssignments()
        
        for assignmentData in localAssignments {
            let record = assignmentData.toCKRecord()
            try await saveRecord(record)
        }
    }
    
    // MARK: - Download Operations
    
    private func downloadRemoteCategories() async throws {
        let query = CKQuery(recordType: config.customCategoryRecordType, predicate: NSPredicate(value: true))
        let records = try await performQuery(query)
        
        for record in records {
            if let categoryData = SyncableCategoryData.fromCKRecord(record) {
                await mergeRemoteCategory(categoryData)
            }
        }
    }
    
    private func downloadRemoteAppAssignments() async throws {
        let query = CKQuery(recordType: config.appAssignmentRecordType, predicate: NSPredicate(value: true))
        let records = try await performQuery(query)
        
        for record in records {
            if let assignmentData = SyncableAppData.fromCKRecord(record) {
                await mergeRemoteAppAssignment(assignmentData)
            }
        }
    }
    
    // MARK: - CloudKit Operations
    
    private func saveRecord(_ record: CKRecord) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            database.save(record) { savedRecord, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func performQuery(_ query: CKQuery) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            database.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: records ?? [])
                }
            }
        }
    }
    
    // MARK: - Data Merging
    
    private func mergeRemoteCategory(_ remoteCategory: SyncableCategoryData) async {
        // Verifica se abbiamo già questa categoria localmente
        let localCategories = await getLocalCustomCategories()
        
        if let localCategory = localCategories.first(where: { $0.name == remoteCategory.name }) {
            // Risoluzione conflitti: usa la versione più recente
            if remoteCategory.lastModified > localCategory.lastModified {
                await updateLocalCategory(remoteCategory)
            }
        } else {
            // Nuova categoria da aggiungere
            await addLocalCategory(remoteCategory)
        }
    }
    
    private func mergeRemoteAppAssignment(_ remoteAssignment: SyncableAppData) async {
        // Verifica se abbiamo già questa assegnazione localmente
        let localAssignments = await getLocalAppAssignments()
        
        if let localAssignment = localAssignments.first(where: { $0.bundleIdentifier == remoteAssignment.bundleIdentifier }) {
            // Risoluzione conflitti: usa la versione più recente
            if remoteAssignment.lastModified > localAssignment.lastModified {
                await updateLocalAppAssignment(remoteAssignment)
            }
        } else {
            // Nuova assegnazione da aggiungere
            await addLocalAppAssignment(remoteAssignment)
        }
    }
    
    // MARK: - Local Data Integration
    
    private func getLocalCustomCategories() async -> [SyncableCategoryData] {
        // Ottieni le categorie personalizzate dal AppManager
        let appManager = AppManager()
        return appManager.customCategories.map { categoryName in
            SyncableCategoryData(
                name: categoryName,
                icon: appManager.getCustomCategoryIcon(category: categoryName) ?? "📁",
                isCustom: true
            )
        }
    }
    
    private func getLocalAppAssignments() async -> [SyncableAppData] {
        // Ottieni le assegnazioni personalizzate dal AppManager
        let appManager = AppManager()
        return appManager.apps.compactMap { app in
            // Solo le app con categorie personalizzate
            if appManager.isCustomCategory(app.category) {
                return SyncableAppData(
                    bundleIdentifier: app.bundleIdentifier,
                    assignedCategory: app.category
                )
            }
            return nil
        }
    }
    
    private func updateLocalCategory(_ categoryData: SyncableCategoryData) async {
        // Invia notifica per aggiornare l'UI
        NotificationCenter.default.post(
            name: .categoryUpdatedFromSync,
            object: categoryData
        )
    }
    
    private func addLocalCategory(_ categoryData: SyncableCategoryData) async {
        // Invia notifica per aggiungere la categoria
        NotificationCenter.default.post(
            name: .categoryAddedFromSync,
            object: categoryData
        )
    }
    
    private func updateLocalAppAssignment(_ assignmentData: SyncableAppData) async {
        // Invia notifica per aggiornare l'assegnazione
        NotificationCenter.default.post(
            name: .appAssignmentUpdatedFromSync,
            object: assignmentData
        )
    }
    
    private func addLocalAppAssignment(_ assignmentData: SyncableAppData) async {
        // Invia notifica per aggiungere l'assegnazione
        NotificationCenter.default.post(
            name: .appAssignmentAddedFromSync,
            object: assignmentData
        )
    }
    
    // MARK: - Offline Operations
    
    private func loadPendingOperations() {
        if let data = UserDefaults.standard.data(forKey: "pendingCloudKitOperations") {
            do {
                pendingOperations = try JSONDecoder().decode([CloudKitOperation].self, from: data)
            } catch {
                print("Errore nel caricamento operazioni pendenti: \(error)")
                pendingOperations = []
            }
        }
    }
    
    private func savePendingOperations() {
        do {
            let data = try JSONEncoder().encode(pendingOperations)
            UserDefaults.standard.set(data, forKey: "pendingCloudKitOperations")
        } catch {
            print("Errore nel salvataggio operazioni pendenti: \(error)")
        }
    }
    
    func addPendingOperation(_ operation: CloudKitOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }
    
    private func processPendingOperations() async {
        guard isOnline && syncEnabled else { return }
        
        for operation in pendingOperations {
            do {
                switch operation.type {
                case .saveCategory:
                    if let categoryData = operation.categoryData {
                        let record = categoryData.toCKRecord()
                        try await saveRecord(record)
                    }
                case .saveAppAssignment:
                    if let assignmentData = operation.appData {
                        let record = assignmentData.toCKRecord()
                        try await saveRecord(record)
                    }
                }
            } catch {
                print("Errore nell'elaborazione operazione pendente: \(error)")
                continue
            }
        }
        
        // Rimuovi operazioni completate
        pendingOperations.removeAll()
        savePendingOperations()
    }
    
    // MARK: - Account Status
    
    func checkAccountStatus() async -> CKAccountStatus {
        return await withCheckedContinuation { continuation in
            container.accountStatus { status, error in
                continuation.resume(returning: status)
            }
        }
    }
    
    // MARK: - Settings
    
    func enableSync(_ enabled: Bool) {
        syncEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "cloudKitSyncEnabled")
        
        if enabled {
            startAutoSync()
            Task {
                await syncAll()
            }
        } else {
            stopAutoSync()
            syncStatus = .idle
        }
    }
}

// MARK: - CloudKit Operation
struct CloudKitOperation: Codable {
    enum OperationType: String, Codable {
        case saveCategory
        case saveAppAssignment
    }
    
    let id: UUID
    let type: OperationType
    let timestamp: Date
    let categoryData: SyncableCategoryData?
    let appData: SyncableAppData?
    
    init(type: OperationType, categoryData: SyncableCategoryData? = nil, appData: SyncableAppData? = nil) {
        self.id = UUID()
        self.type = type
        self.timestamp = Date()
        self.categoryData = categoryData
        self.appData = appData
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let categoryUpdatedFromSync = Notification.Name("categoryUpdatedFromSync")
    static let categoryAddedFromSync = Notification.Name("categoryAddedFromSync")
    static let appAssignmentUpdatedFromSync = Notification.Name("appAssignmentUpdatedFromSync")
    static let appAssignmentAddedFromSync = Notification.Name("appAssignmentAddedFromSync")
}