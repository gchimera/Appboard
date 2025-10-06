import Foundation
import AppKit
import Combine

@MainActor
class AppManager: ObservableObject {
    @Published var apps: [AppInfo] = []
    @Published var webLinks: [WebLink] = []
    @Published var categories: [String] = ["Tutte", "Sistema", "Produttività", "Creatività", "Sviluppo", "Giochi", "Social", "Utilità", "Educazione", "Sicurezza", "Multimedia", "Comunicazione", "Finanza", "Salute", "News"]
    @Published var isLoading = false
    var isLoaded = false
    
    // CloudKit sync integration - optional per evitare crash all'init
    private var _cloudKitManager: CloudKitManager?
    private var cloudKitManager: CloudKitManager {
        if _cloudKitManager == nil {
            _cloudKitManager = CloudKitManager.shared
        }
        return _cloudKitManager!
    }
    
    // Categorie predefinite che non possono essere eliminate o rinominate
    private let defaultCategories: Set<String> = ["Tutte", "Sistema", "Produttività", "Creatività", "Sviluppo", "Giochi", "Social", "Utilità", "Educazione", "Sicurezza", "Multimedia", "Comunicazione", "Finanza", "Salute", "News"]
    
    init() {
        loadCustomCategories()
        loadCategoryOrder()
        loadWebLinks()
        setupCloudKitNotifications()
    }

    private var appPaths: [String] {
        var paths = ["/Applications"]
        let userAppsPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        if FileManager.default.fileExists(atPath: userAppsPath) {
            paths.append(userAppsPath)
        }
        let additionalPaths = ["/System/Applications", "/Applications/Utilities", "/System/Applications/Utilities"]
        for path in additionalPaths {
            if FileManager.default.fileExists(atPath: path) {
                paths.append(path)
            }
        }
        return paths
    }

    func loadInstalledApps() {
        if isLoading || isLoaded {
            return
        }
        
        // Imposta lo stato di caricamento
        self.isLoading = true

        // Carica cache prima
        loadAppsCache()
        if isLoaded {
            print("Dati app caricati da cache")
            // Termina il caricamento se i dati sono già pronti dalla cache
            self.isLoading = false
            return
        }

        Task { @MainActor in
            var loadedApps: [AppInfo] = []

            for path in appPaths {
                let url = URL(fileURLWithPath: path)
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
                    for appURL in contents where appURL.pathExtension == "app" {
                        if let appInfo = await createAppInfo(from: appURL) {
                            loadedApps.append(appInfo)
                        }
                    }
                } catch {
                    print("Errore nella scansione cartella \(path): \(error.localizedDescription)")
                }
            }

            self.apps = loadedApps.sorted { $0.name.lowercased() < $1.name.lowercased() }
            self.isLoaded = true
            saveAppsCache()
            
            // Fine caricamento
            self.isLoading = false
        }
    }

    private func createAppInfo(from url: URL) async -> AppInfo? {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        var plist: NSDictionary?

        if FileManager.default.fileExists(atPath: infoPlistURL.path) {
            plist = NSDictionary(contentsOf: infoPlistURL)
        }

        // Se il plist non esiste o non può essere letto, crea un'app con dati di fallback
        if plist == nil {
            print("Info.plist non trovato o illeggibile per \(url.lastPathComponent). Creazione app con fallback.")
            let name = url.deletingPathExtension().lastPathComponent
            let size = await getDirectorySize(url: url)
            return AppInfo(
                id: UUID(),
                name: name,
                developer: "Sconosciuto",
                bundleIdentifier: "com.unknown.\(name.filter { !$0.isWhitespace })",
                version: "N/A",
                path: url.path,
                category: "Utilità",
                size: formatBytes(size),
                sizeInBytes: size,
                lastUsed: getLastUsedDate(for: url),
                isProblematic: true // Flag per indicare che l'app ha problemi
            )
        }
        
        let name = (plist?["CFBundleDisplayName"] as? String) ??
                   (plist?["CFBundleName"] as? String) ??
                   url.deletingPathExtension().lastPathComponent
        
        let developer = (plist?["CFBundleIdentifier"] as? String) ?? "Sconosciuto"
        let version = (plist?["CFBundleShortVersionString"] as? String) ?? "Sconosciuto"
        let bundleId = (plist?["CFBundleIdentifier"] as? String) ?? "com.unknown.\(name.filter { !$0.isWhitespace })"
        let categoryType = plist?["LSApplicationCategoryType"] as? String
        
        let size = await getDirectorySize(url: url)
        let category = determineCategory(from: categoryType, bundleId: bundleId, name: name)
        let lastUsed = getLastUsedDate(for: url)
        
        return AppInfo(
            id: UUID(),
            name: name,
            developer: developer,
            bundleIdentifier: bundleId,
            version: version,
            path: url.path,
            category: category,
            size: formatBytes(size),
            sizeInBytes: size,
            lastUsed: lastUsed,
            isProblematic: false
        )
    }

    private func getLastUsedDate(for url: URL) -> Date {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.contentAccessDateKey, .contentModificationDateKey])
            return resourceValues.contentAccessDate ?? resourceValues.contentModificationDate ?? Date()
        } catch {
            return Date()
        }
    }

    private func getDirectorySize(url: URL) async -> Int64 {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                var totalSize: Int64 = 0
                if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let vals = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                            if vals.isDirectory == false {
                                totalSize += Int64(vals.fileSize ?? 0)
                            }
                        } catch { continue }
                    }
                }
                continuation.resume(returning: totalSize)
            }
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func determineCategory(from categoryType: String?, bundleId: String, name: String) -> String {
        if let categoryType = categoryType {
            switch categoryType {
            case "public.app-category.productivity": return "Produttività"
            case "public.app-category.graphics-design": return "Creatività"
            case "public.app-category.photography": return "Multimedia"
            case "public.app-category.video": return "Multimedia"
            case "public.app-category.music": return "Multimedia"
            case "public.app-category.developer-tools": return "Sviluppo"
            case "public.app-category.games": return "Giochi"
            case "public.app-category.social-networking": return "Social"
            case "public.app-category.utilities": return "Utilità"
            case "public.app-category.business": return "Finanza"
            case "public.app-category.education": return "Educazione"
            case "public.app-category.entertainment": return "Multimedia"
            case "public.app-category.medical": return "Salute"
            case "public.app-category.news": return "News"
            case "public.app-category.finance": return "Finanza"
            default: break
            }
        }
        let lowerName = name.lowercased()
        let lowerBundle = bundleId.lowercased()
        
        // Sistema
        if lowerBundle.contains("apple") || lowerBundle.hasPrefix("com.apple") {
            if lowerName.contains("safari") || lowerName.contains("finder") {
                return "Sistema"
            }
        }
        
        // Sviluppo
        if ["xcode", "terminal", "visual studio", "android studio", "intellij", "eclipse", "sublime", "atom", "vscode"].contains(where: lowerName.contains) {
            return "Sviluppo"
        }
        
        // Creatività
        if ["photoshop", "illustrator", "sketch", "final cut", "logic", "garageband", "adobe", "affinity", "blender", "maya"].contains(where: lowerName.contains) {
            return "Creatività"
        }
        
        // Multimedia
        if ["vlc", "quicktime", "itunes", "spotify", "netflix", "youtube", "plex", "kodi", "handbrake"].contains(where: lowerName.contains) {
            return "Multimedia"
        }
        
        // Produttività
        if ["word", "excel", "powerpoint", "notion", "office", "pages", "numbers", "keynote", "evernote", "onenote"].contains(where: lowerName.contains) {
            return "Produttività"
        }
        
        // Comunicazione
        if ["slack", "discord", "telegram", "whatsapp", "zoom", "teams", "skype", "facetime", "messages"].contains(where: lowerName.contains) {
            return "Comunicazione"
        }
        
        // Social
        if ["facebook", "twitter", "instagram", "linkedin", "tiktok", "snapchat", "reddit"].contains(where: lowerName.contains) {
            return "Social"
        }
        
        // Giochi
        if ["steam", "game", "minecraft", "epic games", "battle.net", "origin"].contains(where: lowerName.contains) {
            return "Giochi"
        }
        
        // Educazione
        if ["khan academy", "duolingo", "anki", "coursera", "udemy", "books", "kindle"].contains(where: lowerName.contains) {
            return "Educazione"
        }
        
        // Sicurezza
        if ["1password", "bitwarden", "keychain", "malwarebytes", "antivirus", "vpn", "nordvpn", "expressvpn"].contains(where: lowerName.contains) {
            return "Sicurezza"
        }
        
        // Finanza
        if ["banking", "paypal", "stripe", "quickbooks", "mint", "ynab", "wallet", "investing"].contains(where: lowerName.contains) {
            return "Finanza"
        }
        
        // Salute
        if ["health", "fitness", "workout", "myfitnesspal", "strava", "fitbit", "apple health"].contains(where: lowerName.contains) {
            return "Salute"
        }
        
        // News
        if ["news", "rss", "feedly", "pocket", "instapaper", "medium", "substack"].contains(where: lowerName.contains) {
            return "News"
        }
        
        return "Utilità"
    }

    func addCustomCategory(_ name: String, icon: String? = nil) {
        if !categories.contains(name) {
            categories.append(name)
            if let iconName = icon {
                setCustomCategoryIcon(category: name, iconName: iconName)
            }
            saveCustomCategories()
            saveCategoryOrder()
            
            // Sincronizza con CloudKit
            let categoryData = SyncableCategoryData(
                name: name,
                icon: icon ?? "📁",
                isCustom: true
            )
            
            // Sincronizzazione CloudKit in modo sicuro
            Task {
                await syncCategoryToCloud(categoryData)
            }
        }
    }

    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Tutte": return "📱"
        case "Sistema": return "⚙️"
        case "Produttività": return "📊"
        case "Creatività": return "🎨"
        case "Sviluppo": return "💻"
        case "Giochi": return "🎮"
        case "Social": return "💬"
        case "Utilità": return "🔧"
        case "Educazione": return "🎓"
        case "Sicurezza": return "🔒"
        case "Multimedia": return "🎥"
        case "Comunicazione": return "📞"
        case "Finanza": return "💰"
        case "Salute": return "❤️"
        case "News": return "📰"
        default: return "📁"
        }
    }

    func countForCategory(_ category: String) -> Int {
        if category == "Tutte" {
            return apps.count + webLinks.count
        }
        let appCount = apps.filter { $0.category == category }.count
        let linkCount = webLinks.filter { $0.categoryName == category }.count
        return appCount + linkCount
    }
    
    // MARK: - WebLink Management
    
    func addWebLink(_ webLink: WebLink) {
        webLinks.append(webLink)
        saveWebLinks()
        
        // Sync with CloudKit if enabled
        if let categoryName = webLink.categoryName, !categories.contains(categoryName) {
            addCustomCategory(categoryName)
        }
        
        // TODO: Add CloudKit sync for weblinks when ready
        print("WebLink aggiunto: \(webLink.name)")
    }
    
    func updateWebLink(_ webLink: WebLink) {
        guard let index = webLinks.firstIndex(where: { $0.id == webLink.id }) else {
            print("WebLink non trovato per l'aggiornamento")
            return
        }
        webLinks[index] = webLink
        saveWebLinks()
        print("WebLink aggiornato: \(webLink.name)")
    }
    
    func deleteWebLink(_ webLink: WebLink) {
        webLinks.removeAll { $0.id == webLink.id }
        saveWebLinks()
        print("WebLink eliminato: \(webLink.name)")
    }
    
    func webLinksForCategory(_ category: String) -> [WebLink] {
        if category == "Tutte" {
            return webLinks
        }
        return webLinks.filter { $0.categoryName == category }
    }
    
    // MARK: Cache Storage
    
    func saveAppsCache() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(apps)
            UserDefaults.standard.set(data, forKey: "cachedApps")
        } catch {
            print("Errore nel salvataggio cache app: \(error)")
        }
    }
    
    func loadAppsCache() {
        if let data = UserDefaults.standard.data(forKey: "cachedApps") {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let cachedApps = try decoder.decode([AppInfo].self, from: data)
                self.apps = cachedApps
                isLoaded = true
            } catch {
                print("Errore nel caricamento cache app (probabile aggiornamento struttura): \(error)")
                // Cancella la cache corrotta e ricarica le app
                clearCache()
            }
        }
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: "cachedApps")
        isLoaded = false
    }
    
    private func saveWebLinks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(webLinks)
            UserDefaults.standard.set(data, forKey: "savedWebLinks")
            print("WebLinks salvati: \(webLinks.count)")
        } catch {
            print("Errore nel salvataggio WebLinks: \(error)")
        }
    }
    
    private func loadWebLinks() {
        if let data = UserDefaults.standard.data(forKey: "savedWebLinks") {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let loadedLinks = try decoder.decode([WebLink].self, from: data)
                self.webLinks = loadedLinks
                print("WebLinks caricati: \(loadedLinks.count)")
            } catch {
                print("Errore nel caricamento WebLinks: \(error)")
            }
        }
    }
    
    // MARK: Category Management
    
    func updateAppCategory(appId: UUID, newCategory: String) {
        guard let index = apps.firstIndex(where: { $0.id == appId }) else {
            print("App non trovata per l'aggiornamento categoria")
            return
        }
        
        // Usa il nuovo metodo withUpdatedCategory per gestire i metadati di sync
        apps[index] = apps[index].withUpdatedCategory(newCategory)
        
        // Aggiungi la categoria se non esiste già
        if !categories.contains(newCategory) && newCategory != "Tutte" {
            addCustomCategory(newCategory)
        }
        
        // Salva la cache aggiornata
        saveAppsCache()
        
        // Sincronizza con CloudKit se è una categoria personalizzata
        if isCustomCategory(newCategory) {
            let assignmentData = SyncableAppData(
                bundleIdentifier: apps[index].bundleIdentifier,
                assignedCategory: newCategory
            )
            
            // Sincronizzazione CloudKit in modo sicuro
            Task {
                await syncAppAssignmentToCloud(assignmentData)
            }
        }
        
        print("Categoria aggiornata per \(apps[index].name): \(newCategory)")
    }
    
    // MARK: Advanced Category Management
    
    func isCustomCategory(_ category: String) -> Bool {
        return !defaultCategories.contains(category)
    }
    
    var customCategories: [String] {
        return categories.filter { !defaultCategories.contains($0) }
    }
    
    func renameCategory(from oldName: String, to newName: String) -> Bool {
        // Non permettere di rinominare la categoria "Tutte"
        guard oldName != "Tutte" else {
            print("Impossibile rinominare la categoria speciale: Tutte")
            return false
        }
        
        // Controlla che il nuovo nome non esista già
        guard !categories.contains(newName) else {
            print("La categoria \(newName) esiste già")
            return false
        }
        
        // Rinomina nella lista delle categorie
        if let index = categories.firstIndex(of: oldName) {
            categories[index] = newName
        }
        
        // Aggiorna tutte le app che usano questa categoria
        for i in apps.indices {
            if apps[i].category == oldName {
                apps[i] = AppInfo(
                    id: apps[i].id,
                    name: apps[i].name,
                    developer: apps[i].developer,
                    bundleIdentifier: apps[i].bundleIdentifier,
                    version: apps[i].version,
                    path: apps[i].path,
                    category: newName,
                    size: apps[i].size,
                    sizeInBytes: apps[i].sizeInBytes,
                    lastUsed: apps[i].lastUsed
                )
            }
        }
        
        // Salva le modifiche
        saveCustomCategories()
        saveCategoryOrder()
        saveAppsCache()
        
        print("Categoria rinominata da \(oldName) a \(newName)")
        return true
    }
    
    func assignAppToCategory(app: AppInfo, newCategory: String) {
        // Trova l'app nell'array e aggiorna la sua categoria
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index] = apps[index].withUpdatedCategory(newCategory)
            saveAppsCache()
            
            // Crea operazione CloudKit pendente per la sincronizzazione
            if cloudKitManager.syncEnabled {
                let appData = SyncableAppData(
                    bundleIdentifier: app.bundleIdentifier,
                    assignedCategory: newCategory
                )
                let operation = CloudKitOperation(type: .saveAppAssignment, appData: appData)
                cloudKitManager.addPendingOperation(operation)
            }
            
            print("App \(app.name) assegnata alla categoria \(newCategory)")
        }
    }
    
    func resetCategoriesToDefaults() -> Int {
        // Rimuove tutte le categorie personalizzate e riassegnate le app alle categorie iniziali
        // Mantieni solo le categorie predefinite, preservando l'ordine corrente
        categories = categories.filter { defaultCategories.contains($0) }

        // Mantieni solo le icone personalizzate associate alle categorie predefinite
        customCategoryIcons = customCategoryIcons.filter { defaultCategories.contains($0.key) }

        var reassigned = 0
        // Riassegna tutte le app alla categoria iniziale calcolata
        for app in apps {
            let newCat = defaultCategoryForApp(app)
            if app.category != newCat {
                assignAppToCategory(app: app, newCategory: newCat)
                reassigned += 1
            }
        }

        // Salva stato aggiornato
        saveCustomCategories()
        saveCustomCategoryIcons()
        saveAppsCache()
        print("Reset categorie completato. App riassegnate: \(reassigned)")
        return reassigned
    }

    private func defaultCategoryForApp(_ app: AppInfo) -> String {
        // Caso speciale: app di sistema nella cartella /System/Applications -> "Sistema"
        if app.path.hasPrefix("/System/Applications/") {
            return "Sistema"
        }
        // Calcola la categoria "iniziale" in base all'Info.plist o ricade su Heuristica
        let infoPlistURL = URL(fileURLWithPath: app.path).appendingPathComponent("Contents/Info.plist")
        var categoryType: String? = nil
        if FileManager.default.fileExists(atPath: infoPlistURL.path), let plist = NSDictionary(contentsOf: infoPlistURL) {
            categoryType = plist["LSApplicationCategoryType"] as? String
        }
        let mapped = determineCategory(from: categoryType, bundleId: app.bundleIdentifier, name: app.name)
        // Se mapped non è una categoria predefinita, ricadi su Utilità
        return defaultCategories.contains(mapped) ? mapped : "Utilità"
    }

    func deleteCategory(_ categoryName: String) -> Bool {
        // Non permettere di eliminare la categoria "Tutte"
        guard categoryName != "Tutte" else {
            print("Impossibile eliminare la categoria speciale: Tutte")
            return false
        }
        
        // Rimuovi dalla lista delle categorie
        categories.removeAll { $0 == categoryName }
        
        // Riassegna tutte le app di questa categoria a "Utilità"
        let defaultCategory = "Utilità"
        for i in apps.indices {
            if apps[i].category == categoryName {
                apps[i] = AppInfo(
                    id: apps[i].id,
                    name: apps[i].name,
                    developer: apps[i].developer,
                    bundleIdentifier: apps[i].bundleIdentifier,
                    version: apps[i].version,
                    path: apps[i].path,
                    category: defaultCategory,
                    size: apps[i].size,
                    sizeInBytes: apps[i].sizeInBytes,
                    lastUsed: apps[i].lastUsed
                )
            }
        }
        
        // Salva le modifiche
        saveCustomCategories()
        saveCategoryOrder()
        saveAppsCache()
        
        print("Categoria \(categoryName) eliminata, app riassegnate a \(defaultCategory)")
        return true
    }
    
    // MARK: Custom Category Icons
    
    private var customCategoryIcons: [String: String] = [:]
    
    func setCustomCategoryIcon(category: String, iconName: String) {
        customCategoryIcons[category] = iconName
        saveCustomCategoryIcons()
    }
    
    func getCustomCategoryIcon(category: String) -> String? {
        return customCategoryIcons[category]
    }
    
    func removeCustomCategoryIcon(category: String) {
        customCategoryIcons.removeValue(forKey: category)
        saveCustomCategoryIcons()
    }
    
    // MARK: Custom Categories Storage
    
    private func saveCustomCategories() {
        let customCats = customCategories
        UserDefaults.standard.set(customCats, forKey: "customCategories")
        print("Categorie personalizzate salvate: \(customCats)")
    }
    
    private func loadCustomCategories() {
        if let saved = UserDefaults.standard.array(forKey: "customCategories") as? [String] {
            // Aggiungi le categorie personalizzate a quelle predefinite
            for customCategory in saved {
                if !categories.contains(customCategory) {
                    categories.append(customCategory)
                }
            }
            print("Categorie personalizzate caricate: \(saved)")
        }
        loadCustomCategoryIcons()
    }
    
    private func saveCustomCategoryIcons() {
        UserDefaults.standard.set(customCategoryIcons, forKey: "customCategoryIcons")
    }
    
    private func loadCustomCategoryIcons() {
        if let saved = UserDefaults.standard.dictionary(forKey: "customCategoryIcons") as? [String: String] {
            customCategoryIcons = saved
        }
    }
    
    // MARK: Category Order Management
    
    // Sposta una categoria in su di una posizione
    func moveCategoryUp(at index: Int) {
        // Verifica che l'indice sia valido
        guard index > 1 && index < categories.count else {
            print("Impossibile spostare categoria: indice non valido o categoria 'Tutte'")
            return
        }
        
        // Scambia con la categoria precedente
        categories.swapAt(index, index - 1)
        saveCategoryOrder()
        print("Categoria \(categories[index]) spostata in su")
    }
    
    // Sposta una categoria in giù di una posizione
    func moveCategoryDown(at index: Int) {
        // Verifica che l'indice sia valido
        guard index >= 1 && index < categories.count - 1 else {
            print("Impossibile spostare categoria: indice non valido o categoria 'Tutte'")
            return
        }
        
        // Scambia con la categoria successiva
        categories.swapAt(index, index + 1)
        saveCategoryOrder()
        print("Categoria \(categories[index]) spostata in giù")
    }
    
    func moveCategoryItem(from source: IndexSet, to destination: Int) {
        // Non permettere di spostare "Tutte" (sempre prima posizione)
        guard let sourceIndex = source.first, sourceIndex != 0 else {
            print("Impossibile spostare la categoria 'Tutte'")
            return
        }
        
        // Calcola la nuova posizione tenendo conto di "Tutte"
        var adjustedDestination = destination
        
        // Non permettere di spostare prima di "Tutte"
        if adjustedDestination == 0 {
            adjustedDestination = 1
        }
        
        // Esegui lo spostamento manualmente
        var newCategories = categories
        let movedItems = source.map { categories[$0] }
        
        // Rimuovi gli elementi dalle posizioni originali (in ordine inverso per mantenere gli indici)
        for index in source.sorted(by: >) {
            newCategories.remove(at: index)
        }
        
        // Calcola la posizione di inserimento corretta
        var insertIndex = adjustedDestination
        if sourceIndex < adjustedDestination {
            insertIndex -= source.count
        }
        
        // Inserisci gli elementi nella nuova posizione
        for (offset, item) in movedItems.enumerated() {
            newCategories.insert(item, at: insertIndex + offset)
        }
        
        categories = newCategories
        saveCategoryOrder()
        print("Ordine categorie aggiornato")
    }
    
    private func saveCategoryOrder() {
        // Salva l'ordine completo delle categorie
        UserDefaults.standard.set(categories, forKey: "categoryOrder")
        print("Ordine categorie salvato: \(categories)")
    }
    
    private func loadCategoryOrder() {
        if let savedOrder = UserDefaults.standard.array(forKey: "categoryOrder") as? [String] {
            // Verifica che "Tutte" sia sempre prima
            var orderedCategories = savedOrder.filter { $0 != "Tutte" }
            orderedCategories.insert("Tutte", at: 0)
            
            // Aggiungi eventuali nuove categorie predefinite che non sono nell'ordine salvato
            for defaultCategory in defaultCategories {
                if !orderedCategories.contains(defaultCategory) {
                    orderedCategories.append(defaultCategory)
                }
            }
            
            categories = orderedCategories
            print("Ordine categorie caricato: \(categories.count) categorie")
        }
    }
    
    // MARK: - CloudKit Integration
    
    private func setupCloudKitNotifications() {
        NotificationCenter.default.addObserver(
            forName: .categoryAddedFromSync,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let categoryData = notification.object as? SyncableCategoryData {
                self?.handleSyncedCategory(categoryData)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .categoryUpdatedFromSync,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let categoryData = notification.object as? SyncableCategoryData {
                self?.handleSyncedCategory(categoryData)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .appAssignmentAddedFromSync,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let assignmentData = notification.object as? SyncableAppData {
                self?.handleSyncedAppAssignment(assignmentData)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .appAssignmentUpdatedFromSync,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let assignmentData = notification.object as? SyncableAppData {
                self?.handleSyncedAppAssignment(assignmentData)
            }
        }
    }
    
    private func handleSyncedCategory(_ categoryData: SyncableCategoryData) {
        // Aggiungi o aggiorna la categoria locale
        if !categories.contains(categoryData.name) {
            categories.append(categoryData.name)
        }
        
        // Imposta l'icona personalizzata se presente
        if !categoryData.icon.isEmpty {
            setCustomCategoryIcon(category: categoryData.name, iconName: categoryData.icon)
        }
        
        saveCustomCategories()
        print("Categoria sincronizzata da iCloud: \(categoryData.name)")
    }
    
    private func handleSyncedAppAssignment(_ assignmentData: SyncableAppData) {
        // Trova l'app corrispondente e aggiorna la categoria
        if let index = apps.firstIndex(where: { $0.bundleIdentifier == assignmentData.bundleIdentifier }) {
            apps[index] = apps[index].withUpdatedCategory(assignmentData.assignedCategory).markAsSynced()
            
            // Assicurati che la categoria esista
            if !categories.contains(assignmentData.assignedCategory) {
                categories.append(assignmentData.assignedCategory)
            }
            
            saveAppsCache()
            print("Assegnazione app sincronizzata da iCloud: \(assignmentData.bundleIdentifier) -> \(assignmentData.assignedCategory)")
        }
    }
    
    // Metodo pubblico per attivare la sincronizzazione manuale
    func syncWithiCloud() async {
        guard let _ = _cloudKitManager else {
            print("CloudKit non inizializzato")
            return
        }
        await cloudKitManager.syncAll()
    }
    
    // Metodo per ottenere lo stato di sincronizzazione
    var syncStatus: SyncStatus {
        guard let _ = _cloudKitManager else { return .idle }
        return cloudKitManager.syncStatus
    }
    
    // Metodo per verificare se la sincronizzazione è abilitata
    var isSyncEnabled: Bool {
        guard let _ = _cloudKitManager else { return false }
        return cloudKitManager.syncEnabled
    }
    
    // Metodo per abilitare/disabilitare la sincronizzazione
    func setSyncEnabled(_ enabled: Bool) {
        guard let _ = _cloudKitManager else { return }
        cloudKitManager.enableSync(enabled)
    }
    
    // MARK: - Safe CloudKit Access Helpers
    
    private func syncCategoryToCloud(_ categoryData: SyncableCategoryData) async {
        guard let _ = _cloudKitManager else {
            // CloudKit non ancora inizializzato, salta la sincronizzazione
            print("CloudKit non inizializzato, saltando sincronizzazione categoria")
            return
        }
        
        do {
            if cloudKitManager.isOnline {
                try await cloudKitManager.syncCustomCategories()
            } else {
                let operation = CloudKitOperation(type: .saveCategory, categoryData: categoryData)
                cloudKitManager.addPendingOperation(operation)
            }
        } catch {
            print("Errore sincronizzazione categoria: \(error)")
            let operation = CloudKitOperation(type: .saveCategory, categoryData: categoryData)
            cloudKitManager.addPendingOperation(operation)
        }
    }
    
    private func syncAppAssignmentToCloud(_ assignmentData: SyncableAppData) async {
        guard let _ = _cloudKitManager else {
            // CloudKit non ancora inizializzato, salta la sincronizzazione
            print("CloudKit non inizializzato, saltando sincronizzazione app assignment")
            return
        }
        
        do {
            if cloudKitManager.isOnline {
                try await cloudKitManager.syncAppAssignments()
            } else {
                let operation = CloudKitOperation(type: .saveAppAssignment, appData: assignmentData)
                cloudKitManager.addPendingOperation(operation)
            }
        } catch {
            print("Errore sincronizzazione app assignment: \(error)")
            let operation = CloudKitOperation(type: .saveAppAssignment, appData: assignmentData)
            cloudKitManager.addPendingOperation(operation)
        }
    }

}
