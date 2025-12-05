import Foundation

struct VPNServer: Identifiable, Codable {
    let id: UUID
    let name: String
    let country: String
    let city: String
    let serverAddress: String
    let flagEmoji: String
    var latency: Int? // in milliseconds

    init(id: UUID = UUID(), name: String, country: String, city: String, serverAddress: String, flagEmoji: String, latency: Int? = nil) {
        self.id = id
        self.name = name
        self.country = country
        self.city = city
        self.serverAddress = serverAddress
        self.flagEmoji = flagEmoji
        self.latency = latency
    }
}

extension VPNServer {
    static let availableServers: [VPNServer] = [
        VPNServer(
            name: "United States - New York",
            country: "United States",
            city: "New York",
            serverAddress: "us-ny.securevpn.example.com",
            flagEmoji: "🇺🇸",
            latency: 45
        ),
        VPNServer(
            name: "United States - Los Angeles",
            country: "United States",
            city: "Los Angeles",
            serverAddress: "us-la.securevpn.example.com",
            flagEmoji: "🇺🇸",
            latency: 38
        ),
        VPNServer(
            name: "United Kingdom - London",
            country: "United Kingdom",
            city: "London",
            serverAddress: "uk-lon.securevpn.example.com",
            flagEmoji: "🇬🇧",
            latency: 82
        ),
        VPNServer(
            name: "Germany - Frankfurt",
            country: "Germany",
            city: "Frankfurt",
            serverAddress: "de-fra.securevpn.example.com",
            flagEmoji: "🇩🇪",
            latency: 95
        ),
        VPNServer(
            name: "Japan - Tokyo",
            country: "Japan",
            city: "Tokyo",
            serverAddress: "jp-tok.securevpn.example.com",
            flagEmoji: "🇯🇵",
            latency: 156
        ),
        VPNServer(
            name: "Singapore",
            country: "Singapore",
            city: "Singapore",
            serverAddress: "sg.securevpn.example.com",
            flagEmoji: "🇸🇬",
            latency: 189
        ),
        VPNServer(
            name: "Canada - Toronto",
            country: "Canada",
            city: "Toronto",
            serverAddress: "ca-tor.securevpn.example.com",
            flagEmoji: "🇨🇦",
            latency: 52
        ),
        VPNServer(
            name: "Australia - Sydney",
            country: "Australia",
            city: "Sydney",
            serverAddress: "au-syd.securevpn.example.com",
            flagEmoji: "🇦🇺",
            latency: 201
        )
    ]
}

enum VPNConnectionStatus: String {
    case disconnected = "Disconnected"
    case connecting = "Connecting..."
    case connected = "Connected"
    case disconnecting = "Disconnecting..."
    case error = "Connection Error"
}
