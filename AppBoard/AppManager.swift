import Foundation
import AppKit
import Combine

@MainActor
class AppManager: ObservableObject {
    @Published var apps: [AppInfo] = []
    @Published var categories: [String] = ["Tutte", "Sistema", "Produttività", "Creatività", "Sviluppo", "Giochi", "Social", "Utilità"]
    var isLoaded = false

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
        if isLoaded {
            return
        }

        // Carica cache prima
        loadAppsCache()
        if isLoaded {
            print("Dati app caricati da cache")
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
        }
    }

    private func createAppInfo(from url: URL) async -> AppInfo? {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        
        guard FileManager.default.fileExists(atPath: infoPlistURL.path) else {
            print("Info.plist mancante: \(url.lastPathComponent)")
            return nil
        }
        
        guard let plist = NSDictionary(contentsOf: infoPlistURL) else {
            print("Errore a leggere Info.plist: \(url.lastPathComponent)")
            return nil
        }
        
        let name = (plist["CFBundleDisplayName"] as? String) ??
                   (plist["CFBundleName"] as? String) ??
                   url.deletingPathExtension().lastPathComponent
        
        let developer = (plist["CFBundleIdentifier"] as? String) ?? "Sconosciuto"
        
        let version = (plist["CFBundleShortVersionString"] as? String) ?? "Sconosciuto"
        let bundleId = (plist["CFBundleIdentifier"] as? String) ?? ""
        let categoryType = plist["LSApplicationCategoryType"] as? String
        
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
            lastUsed: lastUsed
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
            case "public.app-category.photography": return "Creatività"
            case "public.app-category.video": return "Creatività"
            case "public.app-category.music": return "Creatività"
            case "public.app-category.developer-tools": return "Sviluppo"
            case "public.app-category.games": return "Giochi"
            case "public.app-category.social-networking": return "Social"
            case "public.app-category.utilities": return "Utilità"
            case "public.app-category.business": return "Produttività"
            case "public.app-category.education": return "Produttività"
            case "public.app-category.entertainment": return "Giochi"
            default: break
            }
        }
        let lowerName = name.lowercased()
        let lowerBundle = bundleId.lowercased()
        if lowerBundle.contains("apple") || lowerBundle.hasPrefix("com.apple") {
            if lowerName.contains("safari") || lowerName.contains("finder") {
                return "Sistema"
            }
        }
        if lowerName.contains("xcode") || lowerName.contains("terminal") || lowerName.contains("visual studio") {
            return "Sviluppo"
        }
        if ["photoshop", "sketch", "final cut", "logic", "garageband", "adobe", "affinity"].contains(where: lowerName.contains) {
            return "Creatività"
        }
        if ["word", "excel", "powerpoint", "notion", "office", "pages", "numbers", "keynote"].contains(where: lowerName.contains) {
            return "Produttività"
        }
        if ["steam", "game", "minecraft"].contains(where: lowerName.contains) {
            return "Giochi"
        }
        if ["slack", "discord", "telegram", "whatsapp", "zoom", "teams"].contains(where: lowerName.contains) {
            return "Social"
        }
        return "Utilità"
    }

    func addCustomCategory(_ name: String) {
        if !categories.contains(name) {
            categories.append(name)
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
        default: return "📁"
        }
    }

    func countForCategory(_ category: String) -> Int {
        if category == "Tutte" {
            return apps.count
        }
        return apps.filter { $0.category == category }.count
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
                print("Errore nel caricamento cache app: \(error)")
            }
        }
    }
}
