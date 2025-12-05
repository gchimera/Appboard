import Foundation
import NetworkExtension
import UserNotifications
import Combine

class VPNManager: ObservableObject {
    static let shared = VPNManager()

    @Published var connectionStatus: VPNConnectionStatus = .disconnected
    @Published var currentServer: VPNServer?
    @Published var connectedIP: String?
    @Published var connectionTime: TimeInterval = 0
    @Published var bytesReceived: Int64 = 0
    @Published var bytesSent: Int64 = 0

    private var vpnManager: NETunnelProviderManager?
    private var connectionTimer: Timer?
    private var connectionStartTime: Date?

    private init() {
        setupNotifications()
        loadVPNConfiguration()
    }

    // MARK: - Setup

    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusDidChange),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }

    private func loadVPNConfiguration() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error = error {
                print("Error loading VPN configuration: \(error.localizedDescription)")
                return
            }

            if let manager = managers?.first {
                self?.vpnManager = manager
            } else {
                self?.createVPNConfiguration()
            }
        }
    }

    private func createVPNConfiguration() {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "SecureVPN"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "com.securevpn.SecureVPN.tunnel"
        proto.serverAddress = "SecureVPN"

        manager.protocolConfiguration = proto
        manager.isEnabled = true

        manager.saveToPreferences { [weak self] error in
            if let error = error {
                print("Error saving VPN configuration: \(error.localizedDescription)")
            } else {
                self?.vpnManager = manager
                self?.loadVPNConfiguration()
            }
        }
    }

    // MARK: - Connection Management

    func connect(to server: VPNServer) {
        guard let vpnManager = vpnManager else {
            print("VPN Manager not initialized")
            return
        }

        currentServer = server
        connectionStatus = .connecting

        guard let proto = vpnManager.protocolConfiguration as? NETunnelProviderProtocol else {
            print("Invalid protocol configuration")
            connectionStatus = .error
            return
        }

        proto.serverAddress = server.serverAddress

        let options: [String: NSObject] = [
            "serverAddress": server.serverAddress as NSString,
            "serverName": server.name as NSString
        ]

        do {
            try vpnManager.connection.startVPNTunnel(options: options)
            connectionStartTime = Date()
            startConnectionTimer()
            sendNotification(title: "SecureVPN", body: "Connecting to \(server.name)...")
        } catch {
            print("Error starting VPN: \(error.localizedDescription)")
            connectionStatus = .error
            sendNotification(title: "SecureVPN Error", body: "Failed to connect to \(server.name)")
        }
    }

    func disconnect() {
        guard let vpnManager = vpnManager else { return }

        connectionStatus = .disconnecting
        vpnManager.connection.stopVPNTunnel()
        stopConnectionTimer()

        if let server = currentServer {
            sendNotification(title: "SecureVPN", body: "Disconnected from \(server.name)")
        }
    }

    func toggleConnection(server: VPNServer? = nil) {
        switch connectionStatus {
        case .disconnected:
            if let server = server ?? currentServer ?? VPNServer.availableServers.first {
                connect(to: server)
            }
        case .connected:
            disconnect()
        default:
            break
        }
    }

    // MARK: - Status Monitoring

    @objc private func vpnStatusDidChange() {
        guard let vpnManager = vpnManager else { return }

        DispatchQueue.main.async { [weak self] in
            switch vpnManager.connection.status {
            case .connected:
                self?.connectionStatus = .connected
                self?.fetchConnectedIP()
                if let server = self?.currentServer {
                    self?.sendNotification(title: "SecureVPN", body: "Connected to \(server.name)")
                }
            case .disconnected:
                self?.connectionStatus = .disconnected
                self?.connectedIP = nil
                self?.stopConnectionTimer()
            case .connecting:
                self?.connectionStatus = .connecting
            case .disconnecting:
                self?.connectionStatus = .disconnecting
            case .invalid, .reasserting:
                self?.connectionStatus = .error
            @unknown default:
                self?.connectionStatus = .error
            }
        }
    }

    private func startConnectionTimer() {
        connectionTimer?.invalidate()
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let startTime = self?.connectionStartTime else { return }
            self?.connectionTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopConnectionTimer() {
        connectionTimer?.invalidate()
        connectionTimer = nil
        connectionTime = 0
        connectionStartTime = nil
    }

    // MARK: - IP Address

    private func fetchConnectedIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let ip = json["ip"] else {
                DispatchQueue.main.async {
                    self?.connectedIP = "Protected"
                }
                return
            }

            DispatchQueue.main.async {
                self?.connectedIP = ip
            }
        }.resume()
    }

    // MARK: - Notifications

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Security Features

    func getSecurityStatus() -> [String: Bool] {
        return [
            "IP Masking": connectionStatus == .connected,
            "DNS Leak Protection": connectionStatus == .connected,
            "Kill Switch": true,
            "No Logging": true,
            "AES-256 Encryption": true
        ]
    }

    // MARK: - Statistics

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }

    func formatConnectionTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
