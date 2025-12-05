import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @AppStorage("autoConnectOnStartup") private var autoConnectOnStartup = false
    @AppStorage("autoConnectServer") private var autoConnectServerID = ""
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("killSwitchEnabled") private var killSwitchEnabled = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                autoConnectOnStartup: $autoConnectOnStartup,
                autoConnectServerID: $autoConnectServerID,
                showNotifications: $showNotifications
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }

            SecuritySettingsView(killSwitchEnabled: $killSwitchEnabled)
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @Binding var autoConnectOnStartup: Bool
    @Binding var autoConnectServerID: String
    @Binding var showNotifications: Bool

    var body: some View {
        Form {
            Section {
                Toggle("Connect automatically on startup", isOn: $autoConnectOnStartup)
                    .help("Automatically connect to VPN when the app launches")

                if autoConnectOnStartup {
                    Picker("Auto-connect server:", selection: $autoConnectServerID) {
                        Text("Last used server").tag("")
                        Divider()
                        ForEach(VPNServer.availableServers) { server in
                            Text("\(server.flagEmoji) \(server.name)").tag(server.id.uuidString)
                        }
                    }
                    .help("Choose which server to connect to on startup")
                }

                Toggle("Show connection notifications", isOn: $showNotifications)
                    .help("Display notifications when connecting or disconnecting")
            } header: {
                Text("Connection")
                    .font(.headline)
            }

            Section {
                HStack {
                    Text("Launch at login:")
                    Spacer()
                    Button("Configure in System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
                .help("Configure the app to launch when you log in to your Mac")
            } header: {
                Text("System")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct SecuritySettingsView: View {
    @Binding var killSwitchEnabled: Bool
    @EnvironmentObject var vpnManager: VPNManager

    var body: some View {
        Form {
            Section {
                Toggle("Enable Kill Switch", isOn: $killSwitchEnabled)
                    .help("Blocks all internet traffic if VPN connection drops")

                Text("When enabled, your internet connection will be blocked if the VPN disconnects unexpectedly, preventing data leaks.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } header: {
                Text("Network Protection")
                    .font(.headline)
            }

            Section {
                VStack(alignment: .leading, spacing: 10) {
                    SecurityStatusRow(icon: "lock.shield.fill", title: "AES-256 Encryption", status: "Active")
                    SecurityStatusRow(icon: "eye.slash.fill", title: "No Activity Logs", status: "Guaranteed")
                    SecurityStatusRow(icon: "network.badge.shield.half.filled", title: "DNS Leak Protection", status: "Enabled")
                    SecurityStatusRow(icon: "location.fill.viewfinder", title: "IP Masking", status: vpnManager.connectionStatus == .connected ? "Active" : "Inactive")
                }
            } header: {
                Text("Security Status")
                    .font(.headline)
            }

            Section {
                Text("SecureVPN uses industry-standard AES-256 encryption to protect your data. We have a strict no-logging policy and never track your browsing activity.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct SecurityStatusRow: View {
    let icon: String
    let title: String
    let status: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)

            Text(title)
                .font(.system(size: 13))

            Spacer()

            Text(status)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(status.contains("Active") || status.contains("Enabled") || status.contains("Guaranteed") ? .green : .orange)
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("SecureVPN")
                .font(.system(size: 28, weight: .bold))

            Text("Version 1.0.0")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Divider()
                .padding(.horizontal, 40)

            VStack(spacing: 10) {
                Text("Fast, Secure, Private")
                    .font(.system(size: 16, weight: .semibold))

                Text("SecureVPN provides a simple way to connect securely to the internet through encrypted tunnels. Your privacy is our priority.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 8) {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                Link("Support", destination: URL(string: "https://example.com/support")!)
            }
            .font(.system(size: 12))

            Text("© 2025 SecureVPN. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

#Preview {
    SettingsView()
        .environmentObject(VPNManager.shared)
}
