# AppBoard

[![Platform](https://img.shields.io/badge/platform-macOS-blue.svg)](https://developer.apple.com/macos/)
[![Language](https://img.shields.io/badge/language-Swift-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A beautiful and powerful Mac app for organizing your installed applications and web links. AppBoard helps you categorize, manage, and quickly access all your apps and favorite websites in one elegant interface.

![AppBoard](https://via.placeholder.com/800x400/007AFF/FFFFFF?text=AppBoard+Screenshot)

## ✨ Features

### 🗂️ App Organization
- **Smart Categorization**: Automatically organize apps by type (Productivity, Development, Entertainment, etc.)
- **Custom Categories**: Create your own categories with custom icons
- **Drag & Drop**: Easily move apps between categories
- **Quick Search**: Find apps instantly with powerful search functionality

### 🔗 Web Links Management
- **AI-Powered Descriptions**: Generate smart descriptions for websites using OpenAI GPT
- **Favicon Auto-Download**: Automatically fetch and display website favicons
- **Category Assignment**: Organize web links just like apps
- **One-Click Access**: Open links directly in your default browser

### ☁️ iCloud Sync
- **Cross-Device Sync**: Keep your organization consistent across all your Mac devices
- **Automatic Sync**: Changes sync every 5 minutes or manually on demand
- **Conflict Resolution**: Intelligent merging of changes from multiple devices
- **Offline Support**: Works offline with queued sync when connection returns

### 🌍 Multilingual Support
- **English & Italian**: Full localization support
- **Dynamic Language Switching**: Change language without restarting the app
- **Locale-Aware Formatting**: Dates and numbers adapt to your language

### 🛠️ Additional Features
- **Backup & Restore**: Export and import your entire organization
- **Dark Mode Support**: Respects system appearance settings
- **Keyboard Shortcuts**: Power user shortcuts for quick actions
- **Context Menus**: Right-click for quick actions on apps and links

## 🚀 Installation

### Option 1: Download from GitHub Releases (Recommended)
1. Go to [Releases](https://github.com/gchimera/AppBoard/releases)
2. Download the latest `AppBoard.dmg` file
3. Open the DMG and drag AppBoard to your Applications folder

### Option 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/gchimera/AppBoard.git
cd AppBoard

# Open in Xcode
open AppBoard.xcodeproj

# Build and run (⌘R)
```

### System Requirements
- macOS 12.0 or later
- Xcode 14.0+ (for building from source)

## 📖 Usage

### Getting Started
1. Launch AppBoard from your Applications folder
2. Grant necessary permissions for accessing app information
3. Wait for the app to scan your installed applications
4. Start organizing by creating categories or moving apps

### Adding Web Links
1. Click the "Add Website" button (🔗➕) in the toolbar
2. Enter the URL and press Enter
3. AppBoard will automatically:
   - Download the favicon
   - Generate an AI description (if OpenAI API configured)
   - Suggest a category

### Configuring AI Features
1. Go to Settings (⚙️)
2. Navigate to "Artificial Intelligence" section
3. Add your OpenAI API key (optional, fallback available)
4. Start generating smart descriptions for web links

### iCloud Sync Setup
1. Ensure you're signed into iCloud on your Mac
2. Enable iCloud Drive in System Preferences
3. AppBoard will automatically detect and configure sync
4. Your data will sync across all your devices

## 🔧 Configuration

### OpenAI Integration (Optional)
For enhanced web link descriptions:
1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Add it in AppBoard Settings
3. Enjoy AI-generated descriptions for all web links

*Note: AI features work without API key using smart fallbacks*

### Language Settings
- Switch between English and Italian in Settings
- Changes apply immediately without restart
- All UI elements and content adapt to selected language

## 📚 Documentation

For detailed documentation, see our comprehensive guides:

- [🌐 CloudKit Setup Guide](CLOUDKIT_SETUP.md) - Complete iCloud sync configuration
- [🗣️ Multilingual Implementation](MULTILINGUAL_IMPLEMENTATION.md) - Localization details
- [🤖 AI Features Guide](WEBLINK_AI_FEATURE.md) - Web link AI descriptions
- [📱 Category Management](CATEGORY_SIDEBAR_MANAGEMENT.md) - Advanced category features
- [🔧 Network Troubleshooting](NETWORK_TROUBLESHOOTING.md) - Connection issues

## 🛠️ Technical Details

- **Framework**: SwiftUI for macOS
- **Architecture**: MVVM pattern
- **Persistence**: UserDefaults + CloudKit
- **Networking**: URLSession for web operations
- **AI Integration**: OpenAI GPT-4o-mini API
- **Localization**: Native iOS/macOS localization system

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/gchimera/AppBoard.git`
3. Open `AppBoard.xcodeproj` in Xcode
4. Make your changes
5. Test thoroughly on multiple macOS versions
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using SwiftUI
- AI descriptions powered by OpenAI
- Icons from various open source collections
- Special thanks to the macOS developer community

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/gchimera/AppBoard/issues)
- **Discussions**: [GitHub Discussions](https://github.com/gchimera/AppBoard/discussions)
- **Email**: support@appboard.dev

---

**AppBoard** - Organize your digital life, beautifully.
