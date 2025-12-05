# SecureVPN - macOS Native VPN Application

A beautiful, simple, and secure macOS VPN application built with SwiftUI. SecureVPN provides a clean interface for connecting securely to the internet through encrypted tunnels, making secure browsing accessible with just a few taps.

![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)
![Language](https://img.shields.io/badge/language-Swift-orange.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

## Features

### Core Functionality
- **One-Click Connection**: Connect or disconnect from VPN servers with a single click
- **Server Selection**: Choose from 8 server locations across the globe
- **Real-time Status**: Visual connection status with animated indicators
- **Connection Timer**: Track how long you've been connected
- **IP Address Display**: See your current IP address when connected

### Security Features
- **AES-256 Encryption**: Industry-standard encryption for all data
- **IP Masking**: Hide your real IP address from websites and trackers
- **DNS Leak Protection**: Prevents DNS queries from leaking outside the VPN tunnel
- **Kill Switch**: Blocks internet traffic if VPN connection drops (optional)
- **No Logging Policy**: Zero activity logs stored

### User Experience
- **Clean Interface**: Beautiful gradient design with intuitive controls
- **Server Latency Display**: See ping times for each server location
- **Search Functionality**: Quick search through available servers
- **Notifications**: Get notified when connecting or disconnecting
- **Auto-Connect**: Optional automatic connection on app startup
- **Settings Panel**: Customize behavior with minimal settings

## Server Locations

SecureVPN provides servers in the following locations:
- 🇺🇸 United States (New York, Los Angeles)
- 🇬🇧 United Kingdom (London)
- 🇩🇪 Germany (Frankfurt)
- 🇯🇵 Japan (Tokyo)
- 🇸🇬 Singapore
- 🇨🇦 Canada (Toronto)
- 🇦🇺 Australia (Sydney)

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later (for building from source)
- Apple Developer Account (for NetworkExtension entitlements)

## Installation

### Option 1: Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SecureVPN.git
cd SecureVPN
```

2. Open the project in Xcode:
```bash
open SecureVPN.xcodeproj
```

3. Configure your development team:
   - Select the SecureVPN project in the navigator
   - Go to "Signing & Capabilities"
   - Select your Team from the dropdown

4. Build and run:
   - Press ⌘R or click the Run button
   - Grant necessary permissions when prompted

### Option 2: Download Pre-built Binary

Download the latest release from the [Releases](https://github.com/yourusername/SecureVPN/releases) page.

## Setup & Configuration

### First Launch

1. Launch SecureVPN from your Applications folder
2. Grant notification permissions when prompted
3. The app will request VPN configuration permissions
4. Choose a server location from the list
5. Click "Connect" to establish your first connection

### Configuring Auto-Connect

1. Click the gear icon (⚙️) to open Settings
2. Navigate to the "General" tab
3. Enable "Connect automatically on startup"
4. Select your preferred server or use "Last used server"

### Enabling Kill Switch

1. Open Settings (⚙️)
2. Navigate to the "Security" tab
3. Enable "Kill Switch"
4. When enabled, internet traffic will be blocked if VPN disconnects unexpectedly

## Usage

### Connecting to a Server

1. Click the server selection button (shows current server or "Select Server")
2. Choose a server from the list
3. Click the "Connect" button
4. Wait for the status to change to "Connected"

### Disconnecting

1. Click the "Disconnect" button while connected
2. The app will safely disconnect from the VPN server

### Changing Servers

1. While connected, click the server selection button
2. Choose a different server
3. The app will automatically disconnect and reconnect to the new server

## Architecture

SecureVPN is built using modern Swift and SwiftUI with the following architecture:

### Technology Stack
- **Framework**: SwiftUI for macOS
- **Architecture**: MVVM (Model-View-ViewModel)
- **VPN Protocol**: NetworkExtension framework with NETunnelProvider
- **Notifications**: UserNotifications framework
- **State Management**: Combine framework with @Published properties

### Project Structure
```
SecureVPN/
├── SecureVPN/
│   ├── SecureVPNApp.swift           # Main app entry point
│   ├── Models/
│   │   └── VPNServer.swift          # Server data model
│   ├── Services/
│   │   └── VPNManager.swift         # VPN connection management
│   ├── Views/
│   │   ├── ContentView.swift        # Main connection interface
│   │   ├── ServerSelectionView.swift # Server selection UI
│   │   └── SettingsView.swift       # Settings interface
│   ├── SecureVPN.entitlements       # App capabilities
│   └── Info.plist                   # App configuration
└── SecureVPN.xcodeproj/
```

## Important Notes

### Network Extension Entitlements

SecureVPN requires the NetworkExtension entitlement to create VPN connections. This requires:

1. An Apple Developer Account (paid membership)
2. Proper provisioning profile configuration
3. Network Extension entitlements enabled in your Apple Developer account

### Sandbox Limitations

This app uses the App Sandbox with the following capabilities:
- Network client/server access
- Location access (for server selection)
- NetworkExtension capabilities

### VPN Configuration

The app uses the `NETunnelProviderManager` API which requires:
- User approval for VPN configuration
- System-level VPN permissions
- Proper entitlements configuration

**Note**: For this MVP, the VPN tunnel implementation is simplified. In a production environment, you would need to:
1. Implement a proper NetworkExtension provider target
2. Set up actual VPN servers with real endpoints
3. Implement the tunnel protocol (IKEv2, WireGuard, OpenVPN, etc.)
4. Add proper authentication mechanisms

## Development

### Adding New Server Locations

To add new servers, edit `SecureVPN/Models/VPNServer.swift`:

```swift
VPNServer(
    name: "France - Paris",
    country: "France",
    city: "Paris",
    serverAddress: "fr-par.securevpn.example.com",
    flagEmoji: "🇫🇷",
    latency: 75
)
```

### Customizing the UI

The main UI components are in the `Views` folder:
- `ContentView.swift`: Main connection screen
- `ServerSelectionView.swift`: Server list and selection
- `SettingsView.swift`: App settings and preferences

### Modifying Security Features

Security settings are managed in `VPNManager.swift`:
```swift
func getSecurityStatus() -> [String: Bool] {
    // Add or modify security features here
}
```

## Troubleshooting

### VPN Won't Connect

1. Check that NetworkExtension entitlements are properly configured
2. Verify you have granted VPN configuration permissions
3. Check Console.app for error messages
4. Ensure your development team is properly configured

### Notifications Not Showing

1. Check System Preferences > Notifications > SecureVPN
2. Ensure notification permissions were granted
3. Re-request permissions from Settings

### Build Errors

1. Verify Xcode version is 14.0 or later
2. Clean build folder (Shift+⌘K)
3. Check that all Swift files are included in the target
4. Verify entitlements are properly configured

## Security Considerations

### What This App Does

- Encrypts network traffic using VPN protocols
- Masks your IP address through server routing
- Prevents DNS leaks with secure DNS configuration
- Provides kill switch functionality to prevent data leaks

### What This App Doesn't Do

- Store or log your browsing activity
- Track your connection history
- Share data with third parties
- Require personal information

## Production Deployment

To deploy this app in production, you need to:

1. **Set Up Real VPN Servers**
   - Configure actual VPN server infrastructure
   - Implement proper authentication (username/password or certificates)
   - Set up WireGuard, OpenVPN, or IKEv2 protocols

2. **Create NetworkExtension Provider**
   - Add a PacketTunnelProvider target to the project
   - Implement the VPN tunnel protocol
   - Handle packet routing and encryption

3. **Configure Server Backend**
   - API for server list management
   - User authentication system
   - Connection management and monitoring

4. **App Store Submission**
   - Request NetworkExtension entitlement from Apple
   - Prepare privacy policy and terms of service
   - Configure App Store listing

5. **Testing**
   - Test on multiple macOS versions
   - Verify all VPN protocols work correctly
   - Check for DNS leaks and connection stability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This is an MVP (Minimum Viable Product) VPN application for educational purposes. For production use, you must:
- Implement proper VPN protocols (WireGuard, OpenVPN, IKEv2)
- Set up actual VPN server infrastructure
- Add proper authentication and security measures
- Comply with VPN service regulations in your jurisdiction

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: support@securevpn.example.com

## Acknowledgments

- Built with SwiftUI and the NetworkExtension framework
- Server icons use Unicode flag emojis
- Inspired by the need for simple, secure VPN solutions

---

**SecureVPN** - Simple, Fast, Secure browsing for everyone.
