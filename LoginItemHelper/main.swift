import Cocoa
import Foundation

// Main entry point for LoginItem helper
let mainBundleID = "com.appboard.mac"

// Check if main app is already running
let runningApps = NSWorkspace.shared.runningApplications
let isMainAppRunning = runningApps.contains { app in
    app.bundleIdentifier == mainBundleID
}

// Only launch if not already running
if !isMainAppRunning {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainBundleID) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                NSLog("LoginItem: Failed to launch main app: \(error.localizedDescription)")
            }
            // Exit immediately after launching (or attempting to launch)
            exit(0)
        }
        
        // Wait a moment for the async call to complete
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
    }
}

// Exit
exit(0)
