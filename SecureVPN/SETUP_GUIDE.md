# SecureVPN Setup Guide

This guide will walk you through setting up SecureVPN for development and deployment.

## Prerequisites

Before you begin, ensure you have:
- A Mac running macOS 12.0 or later
- Xcode 14.0 or later installed
- An Apple Developer Account (required for NetworkExtension entitlements)
- Basic familiarity with Xcode and Swift

## Step 1: Project Setup

### 1.1 Clone and Open Project

```bash
git clone https://github.com/yourusername/SecureVPN.git
cd SecureVPN
open SecureVPN.xcodeproj
```

### 1.2 Configure Development Team

1. Open the project in Xcode
2. Select the "SecureVPN" project in the navigator
3. Select the "SecureVPN" target
4. Go to "Signing & Capabilities" tab
5. Under "Team", select your Apple Developer Team
6. Xcode will automatically provision your app

## Step 2: Entitlements Configuration

### 2.1 Understanding NetworkExtension Entitlements

SecureVPN requires special entitlements to create VPN connections:

- `com.apple.developer.networking.networkextension`
- Packet tunnel provider capabilities

These entitlements require:
1. A paid Apple Developer Program membership ($99/year)
2. Manual entitlement request from Apple (for production)

### 2.2 Development Configuration

For development and testing:

1. The app includes necessary entitlements in `SecureVPN.entitlements`
2. Xcode will use a development provisioning profile
3. You may need to manually enable NetworkExtension in your Apple Developer account

### 2.3 Requesting Production Entitlements

For App Store distribution:

1. Go to [Apple Developer Program](https://developer.apple.com/contact/request/)
2. Request "Network Extension" entitlement
3. Provide justification for VPN functionality
4. Wait for Apple approval (can take several days)

## Step 3: Building the App

### 3.1 Development Build

1. Select your Mac as the build destination
2. Press ⌘R or click the Run button
3. Grant permissions when prompted:
   - VPN configuration access
   - Notification permissions

### 3.2 Troubleshooting Build Issues

If you encounter errors:

**"SecureVPN.app requires a provisioning profile"**
- Solution: Select your Team in Signing & Capabilities

**"NetworkExtension entitlement not found"**
- Solution: Ensure you're using a paid Apple Developer account
- For testing, you can comment out NetworkExtension code temporarily

**"Unable to install app"**
- Solution: Clean build folder (Shift+⌘K) and rebuild

## Step 4: Understanding the VPN Implementation

### 4.1 Current Implementation (MVP)

The current implementation uses:
- `NETunnelProviderManager` for VPN configuration
- Mock server addresses for demonstration
- Simulated connection states

### 4.2 What's Missing for Production

To make this production-ready, you need:

1. **VPN Server Infrastructure**
   - Set up actual VPN servers (WireGuard, OpenVPN, IKEv2)
   - Configure server endpoints
   - Implement authentication system

2. **NetworkExtension Provider Target**
   - Create a PacketTunnelProvider extension
   - Implement actual packet routing
   - Handle encryption/decryption

3. **Protocol Implementation**
   - Implement WireGuard, OpenVPN, or IKEv2
   - Handle handshakes and key exchange
   - Manage connection lifecycle

## Step 5: Adding a NetworkExtension Provider (Advanced)

For a production VPN app, you need to add a NetworkExtension provider:

### 5.1 Create Provider Target

1. In Xcode, go to File > New > Target
2. Select "Network Extension" template
3. Choose "Packet Tunnel Provider"
4. Name it "SecureVPNTunnel"

### 5.2 Implement PacketTunnelProvider

Create a `PacketTunnelProvider.swift` file:

```swift
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?) async throws {
        // Configure tunnel parameters
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "SERVER_ADDRESS")

        // Set IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        settings.ipv4Settings = ipv4Settings

        // Set DNS settings
        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        settings.dnsSettings = dnsSettings

        try await setTunnelNetworkSettings(settings)

        // Start reading packets and implement your VPN protocol
        // This is where you'd implement WireGuard/OpenVPN logic
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        // Clean up and close connections
    }

    override func handleAppMessage(_ messageData: Data) async -> Data? {
        // Handle messages from the main app
        return nil
    }
}
```

### 5.3 Update Bundle Identifier

The provider target needs its own bundle identifier:
- Main app: `com.securevpn.SecureVPN`
- Provider: `com.securevpn.SecureVPN.tunnel`

## Step 6: Server Configuration

### 6.1 Setting Up VPN Servers

For production, you need actual VPN servers:

**Option 1: WireGuard**
```bash
# Install WireGuard on your server
apt-get install wireguard

# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Configure /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

**Option 2: Use VPN Provider API**
- Use services like AWS VPN, DigitalOcean, or dedicated VPN providers
- Integrate their API for server management

### 6.2 Update Server List

Edit `VPNServer.swift` to use your real servers:

```swift
VPNServer(
    name: "United States - New York",
    country: "United States",
    city: "New York",
    serverAddress: "your-actual-server.com", // Update this
    flagEmoji: "🇺🇸",
    latency: 45
)
```

## Step 7: Testing

### 7.1 Testing in Development

1. Run the app from Xcode
2. Monitor Console.app for logs
3. Use Network Link Conditioner to test various network conditions
4. Verify IP address changes at [https://whatismyipaddress.com](https://whatismyipaddress.com)

### 7.2 Testing VPN Connection

To verify your VPN is working:

```bash
# Check current IP
curl https://api.ipify.org

# Connect to VPN in the app

# Check IP again (should be different)
curl https://api.ipify.org

# Test DNS leaks
nslookup example.com
```

### 7.3 Testing Kill Switch

1. Connect to VPN
2. Enable Kill Switch in settings
3. Force disconnect (unplug network cable or disable WiFi)
4. Verify that internet access is blocked

## Step 8: Distribution

### 8.1 Archive for Distribution

1. Select "Any Mac" as destination
2. Product > Archive
3. Wait for archive to complete
4. Organizer will open automatically

### 8.2 Export Options

**For Testing:**
- Export as Mac App
- Choose "Development" distribution
- Sign with Development certificate

**For App Store:**
- Choose "App Store Connect"
- Upload to TestFlight for beta testing
- Submit for review

**For Direct Distribution:**
- Choose "Developer ID" distribution
- Notarize with Apple
- Distribute via website or GitHub releases

### 8.3 Notarization (Required for macOS 10.15+)

```bash
# Archive app
xcodebuild -scheme SecureVPN archive -archivePath SecureVPN.xcarchive

# Export app
xcodebuild -exportArchive -archivePath SecureVPN.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist

# Create zip for notarization
ditto -c -k --keepParent SecureVPN.app SecureVPN.zip

# Submit for notarization
xcrun notarytool submit SecureVPN.zip --apple-id "your@email.com" --password "app-specific-password" --team-id "TEAM_ID"

# Check status
xcrun notarytool log <submission-id> --apple-id "your@email.com" --password "app-specific-password"

# Staple ticket to app
xcrun stapler staple SecureVPN.app
```

## Step 9: Common Issues and Solutions

### Issue: "Cannot connect to VPN"

**Solution:**
1. Check that server addresses are correct
2. Verify NetworkExtension entitlements
3. Check Console.app for error messages
4. Ensure firewall isn't blocking connections

### Issue: "App crashes on launch"

**Solution:**
1. Check that all Swift files are included in target
2. Verify Info.plist is correctly configured
3. Clean build folder and rebuild
4. Check for force unwrapping optionals

### Issue: "Notifications not showing"

**Solution:**
1. System Settings > Notifications > SecureVPN
2. Enable all notification options
3. Request notification permissions again

### Issue: "IP address not changing"

**Solution:**
1. Verify VPN connection is actually established
2. Check that server is properly routing traffic
3. Test with different servers
4. Use `curl https://api.ipify.org` to verify

## Step 10: Resources and Documentation

### Apple Documentation
- [NetworkExtension Framework](https://developer.apple.com/documentation/networkextension)
- [Packet Tunnel Provider](https://developer.apple.com/documentation/networkextension/nepackettunnelprovider)
- [VPN Configuration](https://developer.apple.com/documentation/networkextension/vpn_configuration)

### VPN Protocols
- [WireGuard Documentation](https://www.wireguard.com/quickstart/)
- [OpenVPN Documentation](https://openvpn.net/community-resources/)
- [IKEv2 RFC](https://datatracker.ietf.org/doc/html/rfc7296)

### Testing Tools
- [WhatIsMyIP](https://www.whatismyipaddress.com/)
- [DNS Leak Test](https://www.dnsleaktest.com/)
- [IP Leak](https://ipleak.net/)

## Support

For questions or issues:
- Check the [README.md](README.md) for general information
- Open an issue on GitHub
- Contact: support@securevpn.example.com

---

Good luck with your VPN app development!
