import Foundation
import AppKit
import Combine

@MainActor
class AppManager: ObservableObject {
    @Published var apps: [AppInfo] = []
    @Published var categories: [String] = ["Tutte", "Sistema", "Produttività", "Creatività", "Sviluppo", "Giochi", "Social", "Utilità"]
    @Published var customCategories: [String] = []
    
    private var appPaths: [String] {
        var paths = ["/Applications"]
        
        // Aggiungi il percorso delle applicazioni utente solo se esiste
        let userAppsPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        if FileManager.default.fileExists(atPath: userAppsPath) {
            paths.append(userAppsPath)
        }
        
        // Percorsi aggiuntivi comuni
        let additionalPaths = [
            "/System/Applications",
            "/Applications/Utilities",
            "/System/Applications/Utilities"
        ]
        
        for path in additionalPaths {
            if FileManager.default.fileExists(atPath: path) {
                paths.append(path)
            }
        }
        
        return paths
    }
    
    init() {
        loadInstalledApps()
    }
    
    func loadInstalledApps() {
        Task { @MainActor in
            var loadedApps: [AppInfo] = []
            
            print("Cercando app nei seguenti percorsi:")
            for path in appPaths {
                print("- \(path)")
            }
            
            for path in appPaths {
                let url = URL(fileURLWithPath: path)
                
                // Controlla se il percorso esiste
                guard FileManager.default.fileExists(atPath: path) else {
                    print("Percorso non trovato: \(path)")
                    continue
                }
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isDirectoryKey, .isApplicationKey],
                        options: [.skipsHiddenFiles]
                    )
                    
                    let appURLs = contents.filter { $0.pathExtension == "app" }
                    print("Trovate \(appURLs.count) applicazioni in \(path)")
                    
                    for appURL in appURLs {
                        if let appInfo = await createAppInfo(from: appURL) {
                            loadedApps.append(appInfo)
                        }
                    }
                } catch {
                    print("Errore nel leggere la cartella \(path): \(error.localizedDescription)")
                    continue
                }
            }
            
            print("Caricate \(loadedApps.count) applicazioni totali")
            self.apps = loadedApps.sorted { $0.name < $1.name }
        }
    }
    
    private func createAppInfo(from url: URL) async -> AppInfo? {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        
        // Controlla se il file Info.plist exists
        guard FileManager.default.fileExists(atPath: infoPlistURL.path) else {
            print("Info.plist non trovato per: \(url.lastPathComponent)")
            return nil
        }
        
        guard let plist = NSDictionary(contentsOf: infoPlistURL) else {
            print("Impossibile leggere Info.plist per: \(url.lastPathComponent)")
            return nil
        }
        
        let name = plist["CFBundleDisplayName"] as? String ??
                  plist["CFBundleName"] as? String ??
                  url.deletingPathExtension().lastPathComponent
        let version = plist["CFBundleShortVersionString"] as? String ??
                     plist["CFBundleVersion"] as? String ??
                     "Sconosciuto"
        let bundleId = plist["CFBundleIdentifier"] as? String ?? ""
        let categoryType = plist["LSApplicationCategoryType"] as? String
        
        // Ottieni dimensione in modo sicuro
        let size = await getDirectorySize(url: url)
        
        // Determina categoria
        let category = determineCategory(from: categoryType, bundleId: bundleId, name: name)
        
        // Data ultimo utilizzo
        let lastUsed = getLastUsedDate(for: url)
        
        return AppInfo(
            id: UUID(),
            name: name,
            bundleIdentifier: bundleId,
            version: version,
            path: url.path,
            category: category,
            size: formatBytes(size),
            sizeInBytes: size,
            lastUsed: lastUsed
        )
    }
    
    private func getLastUsedDate(for url: URL) -> Date {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey, .contentAccessDateKey])
            return resourceValues.contentAccessDate ?? resourceValues.contentModificationDate ?? Date()
        } catch {
            return Date()
        }
    }
    
    private func getDirectorySize(url: URL) async -> Int64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                guard let enumerator = FileManager.default.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                    options: [.skipsHiddenFiles, .skipsPackageDescendants],
                    errorHandler: { _, error in
                        print("Errore nella lettura file: \(error)")
                        return true // Continua l'enumerazione
                    }
                ) else {
                    continuation.resume(returning: 0)
                    return
                }
                
                var totalSize: Int64 = 0
                for case let fileURL as URL in enumerator {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                        if let isDirectory = resourceValues.isDirectory, !isDirectory {
                            totalSize += Int64(resourceValues.fileSize ?? 0)
                        }
                    } catch {
                        continue
                    }
                }
                continuation.resume(returning: totalSize)
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func determineCategory(from categoryType: String?, bundleId: String, name: String) -> String {
        // Prima controlla il tipo di categoria Apple
        if let categoryType = categoryType {
            switch categoryType {
            case "public.app-category.productivity":
                return "Produttività"
            case "public.app-category.graphics-design":
                return "Creatività"
            case "public.app-category.photography":
                return "Creatività"
            case "public.app-category.video":
                return "Creatività"
            case "public.app-category.music":
                return "Creatività"
            case "public.app-category.developer-tools":
                return "Sviluppo"
            case "public.app-category.games":
                return "Giochi"
            case "public.app-category.social-networking":
                return "Social"
            case "public.app-category.utilities":
                return "Utilità"
            case "public.app-category.business":
                return "Produttività"
            case "public.app-category.education":
                return "Produttività"
            case "public.app-category.entertainment":
                return "Giochi"
            default:
                break
            }
        }
        
        // Fallback basato su bundle ID o nome
        let lowerName = name.lowercased()
        let lowerBundle = bundleId.lowercased()
        
        // App di sistema Apple
        if lowerBundle.contains("apple") || lowerBundle.hasPrefix("com.apple") {
            if lowerName.contains("safari") || lowerName.contains("finder") ||
               lowerName.contains("system preferences") || lowerName.contains("activity monitor") {
                return "Sistema"
            }
        }
        
        // Sviluppo
        if lowerName.contains("xcode") || lowerName.contains("terminal") ||
           lowerName.contains("simulator") || lowerBundle.contains("developer") ||
           lowerName.contains("visual studio") || lowerName.contains("git") {
            return "Sviluppo"
        }
        
        // Creatività
        if lowerName.contains("photoshop") || lowerName.contains("sketch") ||
           lowerName.contains("final cut") || lowerName.contains("logic") ||
           lowerName.contains("garageband") || lowerName.contains("adobe") ||
           lowerName.contains("affinity") {
            return "Creatività"
        }
        
        // Produttività
        if lowerName.contains("word") || lowerName.contains("excel") ||
           lowerName.contains("powerpoint") || lowerName.contains("notion") ||
           lowerName.contains("office") || lowerName.contains("pages") ||
           lowerName.contains("numbers") || lowerName.contains("keynote") {
            return "Produttività"
        }
        
        // Giochi
        if lowerName.contains("steam") || lowerName.contains("game") ||
           lowerBundle.contains("game") || lowerName.contains("minecraft") {
            return "Giochi"
        }
        
        // Social
        if lowerName.contains("slack") || lowerName.contains("discord") ||
           lowerName.contains("telegram") || lowerName.contains("whatsapp") ||
           lowerName.contains("zoom") || lowerName.contains("teams") {
            return "Social"
        }
        
        return "Utilità"
    }
    
    // Resto del codice rimane uguale...
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
        default: return "📁"
        }
    }
    
    func countForCategory(_ category: String) -> Int {
        if category == "Tutte" {
            return apps.count
        }
        return apps.filter { $0.category == category }.count
    }
    
    func addCustomCategory(_ name: String) {
        if !categories.contains(name) {
            categories.append(name)
            customCategories.append(name)
        }
    }
    
    func openApp(_ app: AppInfo) {
        let url = URL(fileURLWithPath: app.path)
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration(),
            completionHandler: { (app, error) in
                if let error = error {
                    print("Errore nell'aprire l'app: \(error)")
                }
            }
        )
    }
    
    func moveAppToCategory(_ app: AppInfo, newCategory: String) {
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index].category = newCategory
        }
    }
}
