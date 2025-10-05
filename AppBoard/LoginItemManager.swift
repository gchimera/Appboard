import Foundation
import AppKit
import ServiceManagement

enum LoginItemManager {
    // MARK: - Types
    enum Status: Equatable {
        case enabled
        case requiresApproval
        case disabled
        case notFound
    }

    // MARK: - Constants
    static let helperBundleIdentifier = "com.appboard.mac.LoginItem"

    // MARK: - Public API
    @available(macOS 13.0, *)
    static func isEnabled() -> Bool {
        let service = SMAppService.loginItem(identifier: helperBundleIdentifier)
        return service.status == .enabled
    }

    /// Try to enable/disable automatic launch and return a normalized status.
    @available(macOS 13.0, *)
    @discardableResult
    static func setEnabledReturningStatus(_ enabled: Bool) throws -> Status {
        let service = SMAppService.loginItem(identifier: helperBundleIdentifier)
        
        if enabled {
            // Try to register the login item
            do {
                try service.register()
                return service.status == .enabled ? .enabled : .requiresApproval
            } catch {
                // Check if helper exists
                let helperExists = checkHelperExists()
                if !helperExists {
                    return .notFound
                }
                // Helper exists but couldn't enable - might need approval
                return .requiresApproval
            }
        } else {
            // Unregister the login item
            do {
                try service.unregister()
                return .disabled
            } catch {
                throw error
            }
        }
    }

    @available(macOS 13.0, *)
    static func setEnabled(_ enabled: Bool) throws {
        _ = try setEnabledReturningStatus(enabled)
    }

    // MARK: - Helper check
    private static func checkHelperExists() -> Bool {
        let fm = FileManager.default
        let loginItemsURL = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Library/LoginItems", isDirectory: true)
        guard let items = try? fm.contentsOfDirectory(at: loginItemsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return false
        }
        for appURL in items where appURL.pathExtension.lowercased() == "app" {
            let infoPlistURL = appURL.appendingPathComponent("Contents/Info.plist")
            if let data = try? Data(contentsOf: infoPlistURL),
               let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
               let bid = plist["CFBundleIdentifier"] as? String,
               bid == helperBundleIdentifier {
                return true
            }
        }
        return false
    }

    // MARK: - Preferences deep links
    static func openLoginItemsPreferences() {
        // macOS 13+: preferenza Login Items
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
            return
        }
        // fallback vecchio pannello Users & Groups > Login Items
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.users?LoginItems") {
            NSWorkspace.shared.open(url)
        }
    }
}
