import Foundation
import ServiceManagement

enum LoginItemManager {
    static let helperBundleIdentifier = "com.appboard.mac.LoginItem"

    static func isEnabled() -> Bool {
        if #available(macOS 13.0, *) {
            let service = SMAppService.loginItem(identifier: helperBundleIdentifier)
            return service.status == .enabled
        } else {
            // Supportato ufficialmente da macOS 13+
            return false
        }
    }

    static func setEnabled(_ enabled: Bool) throws {
        if #available(macOS 13.0, *) {
            let service = SMAppService.loginItem(identifier: helperBundleIdentifier)
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } else {
            throw NSError(domain: "LoginItemManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Funzionalità supportata su macOS 13+"])
        }
    }
}
