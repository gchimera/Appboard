# SecureVPN - Quick Start Guide

Get SecureVPN up and running in 5 minutes.

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- Apple Developer Account (free tier works for testing)

## Installation Steps

### 1. Open the Project

```bash
cd SecureVPN
open SecureVPN.xcodeproj
```

### 2. Configure Signing

1. Select "SecureVPN" project in the navigator
2. Select "SecureVPN" target
3. Go to "Signing & Capabilities"
4. Select your Team from the dropdown

### 3. Build and Run

Press **⌘R** or click the Run button.

## First Launch

### Grant Permissions

When you first launch the app, you'll be asked to grant:

1. **VPN Configuration Permission** - Required for creating VPN connections
2. **Notification Permission** - Optional, for connection status alerts

Click "Allow" on both prompts.

### Connect to VPN

1. Click the server selection button (default: "Select Server")
2. Choose a server location (e.g., "United States - New York")
3. Click the big blue "Connect" button
4. Wait for status to change to "Connected" (green)

That's it! You're now connected.

## Basic Usage

### Changing Servers

1. Click the server name button
2. Select a different server
3. If connected, the app will automatically reconnect

### Viewing Settings

1. Click the gear icon (⚙️) in the top-right
2. Configure auto-connect, notifications, and security features

### Disconnecting

Click the red "Disconnect" button.

## Keyboard Shortcuts

- **⌘,** - Open Settings
- **⌘W** - Close Window
- **⌘Q** - Quit App

## Features to Try

1. **Auto-Connect**: Settings → General → Enable "Connect automatically on startup"
2. **Kill Switch**: Settings → Security → Enable "Kill Switch"
3. **Search Servers**: In server selection, use the search bar
4. **Connection Timer**: Watch the timer when connected

## Troubleshooting

### "Cannot connect to VPN"
- Ensure you're connected to the internet
- Try a different server
- Check Console.app for error messages

### "Permission denied"
- Re-grant VPN configuration permission in System Settings
- Make sure you're signed in to your Mac with administrator privileges

### App won't build
- Clean build folder: Shift+⌘K
- Restart Xcode
- Check that your signing configuration is correct

## What's Next?

- Read the full [README.md](README.md) for detailed features
- Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for production deployment
- Review [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) for architecture details

## Important Notes

⚠️ **This is an MVP**: The current version demonstrates the UI and architecture. For production use, you need to:

1. Implement actual VPN protocols (WireGuard/OpenVPN)
2. Set up real VPN servers
3. Request NetworkExtension entitlement from Apple
4. Add authentication system

See SETUP_GUIDE.md for full production requirements.

## Quick Reference

| Action | How To |
|--------|--------|
| Connect | Click blue "Connect" button |
| Disconnect | Click red "Disconnect" button |
| Change Server | Click server name, select new server |
| Settings | Click gear icon or press ⌘, |
| Check IP | Displayed when connected |
| Enable Auto-Connect | Settings → General |
| Enable Kill Switch | Settings → Security |

## Support

- **Documentation**: See README.md
- **Issues**: GitHub Issues
- **Email**: support@securevpn.example.com

---

Enjoy secure browsing with SecureVPN!
