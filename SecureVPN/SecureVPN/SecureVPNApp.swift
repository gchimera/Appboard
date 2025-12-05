import SwiftUI

@main
struct SecureVPNApp: App {
    @StateObject private var vpnManager = VPNManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vpnManager)
                .frame(minWidth: 400, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(vpnManager)
        }
    }
}
