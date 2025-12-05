import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var showServerSelection = false

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) {
                HeaderView()

                Spacer()

                ConnectionStatusView()
                    .environmentObject(vpnManager)

                Spacer()

                ServerSelectionButton(showServerSelection: $showServerSelection)
                    .environmentObject(vpnManager)

                ConnectButton()
                    .environmentObject(vpnManager)
                    .padding(.bottom, 20)

                SecurityStatusView()
                    .environmentObject(vpnManager)
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showServerSelection) {
            ServerSelectionView(isPresented: $showServerSelection)
                .environmentObject(vpnManager)
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.2, blue: 0.4),
                Color(red: 0.05, green: 0.1, blue: 0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 24))
                .foregroundColor(.white)

            Text("SecureVPN")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button(action: {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
}

struct ConnectionStatusView: View {
    @EnvironmentObject var vpnManager: VPNManager

    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(statusColor)
                    .frame(width: 100, height: 100)
                    .shadow(color: statusColor.opacity(0.5), radius: 20, x: 0, y: 10)

                Image(systemName: statusIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .animation(.easeInOut(duration: 0.3), value: vpnManager.connectionStatus)

            Text(vpnManager.connectionStatus.rawValue)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)

            if vpnManager.connectionStatus == .connected {
                VStack(spacing: 5) {
                    if let ip = vpnManager.connectedIP {
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text("IP: \(ip)")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text(vpnManager.formatConnectionTime(vpnManager.connectionTime))
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 5)
            }
        }
    }

    private var statusColor: Color {
        switch vpnManager.connectionStatus {
        case .connected:
            return Color.green
        case .connecting, .disconnecting:
            return Color.orange
        case .disconnected:
            return Color.gray
        case .error:
            return Color.red
        }
    }

    private var statusIcon: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "checkmark.shield.fill"
        case .connecting, .disconnecting:
            return "arrow.triangle.2.circlepath"
        case .disconnected:
            return "shield.slash.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
}

struct ServerSelectionButton: View {
    @EnvironmentObject var vpnManager: VPNManager
    @Binding var showServerSelection: Bool

    var body: some View {
        Button(action: {
            showServerSelection = true
        }) {
            HStack {
                Text(vpnManager.currentServer?.flagEmoji ?? "🌍")
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(vpnManager.currentServer?.name ?? "Select Server")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    if let latency = vpnManager.currentServer?.latency {
                        Text("\(latency)ms")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
}

struct ConnectButton: View {
    @EnvironmentObject var vpnManager: VPNManager

    var body: some View {
        Button(action: {
            vpnManager.toggleConnection()
        }) {
            Text(buttonTitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonColor)
                .cornerRadius(12)
                .shadow(color: buttonColor.opacity(0.5), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 30)
        .disabled(vpnManager.connectionStatus == .connecting || vpnManager.connectionStatus == .disconnecting)
    }

    private var buttonTitle: String {
        switch vpnManager.connectionStatus {
        case .connected:
            return "Disconnect"
        case .connecting:
            return "Connecting..."
        case .disconnecting:
            return "Disconnecting..."
        case .disconnected, .error:
            return "Connect"
        }
    }

    private var buttonColor: Color {
        switch vpnManager.connectionStatus {
        case .connected:
            return Color.red
        case .connecting, .disconnecting:
            return Color.gray
        case .disconnected, .error:
            return Color.blue
        }
    }
}

struct SecurityStatusView: View {
    @EnvironmentObject var vpnManager: VPNManager

    var body: some View {
        VStack(spacing: 10) {
            Text("Security Features")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 20) {
                SecurityFeature(icon: "lock.shield.fill", title: "Encrypted")
                SecurityFeature(icon: "eye.slash.fill", title: "No Logs")
                SecurityFeature(icon: "network", title: "Protected")
            }
        }
    }
}

struct SecurityFeature: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.green)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(VPNManager.shared)
        .frame(width: 400, height: 500)
}
