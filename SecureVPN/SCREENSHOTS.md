# SecureVPN - UI Screenshots & Descriptions

This document describes the user interface screens for documentation and screenshot purposes.

## Main Connection Screen

**File**: `Views/ContentView.swift`

### Layout Description
```
┌─────────────────────────────────────────┐
│  🛡️  SecureVPN              ⚙️          │ ← Header
│                                         │
│                                         │
│              ┌─────────┐                │
│              │         │                │
│              │    ✓    │ ← Status      │ ← Connection Status
│              │         │   Circle      │   (Animated)
│              └─────────┘                │
│                                         │
│             Connected                   │ ← Status Text
│         IP: 123.45.67.89               │ ← IP Address
│            00:05:42                     │ ← Connection Time
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ 🇺🇸  United States - New York     │ │ ← Server Selection
│  │      45ms                      >  │ │   Button
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │         DISCONNECT                │ │ ← Connect/Disconnect
│  └───────────────────────────────────┘ │   Button (Changes color)
│                                         │
│         Security Features               │
│   🔒          👁️           🌐         │ ← Security Icons
│ Encrypted   No Logs   Protected        │
│                                         │
└─────────────────────────────────────────┘
```

### Visual States

**Disconnected State**
- Background: Blue-purple gradient
- Status Circle: Gray
- Icon: Shield with slash
- Status Text: "Disconnected"
- Button: Blue "Connect"
- IP Address: Hidden
- Timer: Hidden

**Connecting State**
- Status Circle: Orange (pulsing)
- Icon: Rotating arrows
- Status Text: "Connecting..."
- Button: Gray "Connecting..." (disabled)

**Connected State**
- Status Circle: Green (with glow)
- Icon: Checkmark shield
- Status Text: "Connected"
- Button: Red "Disconnect"
- IP Address: Visible
- Timer: Active and counting

**Error State**
- Status Circle: Red
- Icon: Exclamation triangle
- Status Text: "Connection Error"
- Button: Blue "Connect"

### Color Palette
- Background Gradient: `#1A3366` → `#0D1A33`
- Status Green: `#00FF00` (with 50% opacity glow)
- Status Orange: `#FFA500`
- Status Gray: `#808080`
- Status Red: `#FF0000`
- Text White: `#FFFFFF`
- Button Blue: `#007AFF`
- Button Red: `#FF3B30`

## Server Selection Screen

**File**: `Views/ServerSelectionView.swift`

### Layout Description
```
┌─────────────────────────────────────────┐
│  Select Server Location         ✕      │ ← Header with close
├─────────────────────────────────────────┤
│  🔍  Search locations...                │ ← Search bar
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐   │
│  │ 🇺🇸  United States - New York   │   │ ← Server Row
│  │      🟢 45ms                  ✓  │   │   (Selected)
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🇺🇸  United States - LA         │   │
│  │      🟢 38ms                  >  │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🇬🇧  United Kingdom - London    │   │
│  │      🟡 82ms                  >  │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🇩🇪  Germany - Frankfurt        │   │
│  │      🟡 95ms                  >  │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 🇯🇵  Japan - Tokyo              │   │
│  │      🟠 156ms                 >  │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Server List Features
- **8 Locations**: US (2), UK, Germany, Japan, Singapore, Canada, Australia
- **Flag Emojis**: Visual country identification
- **Latency Indicator**: Color-coded dots
  - 🟢 Green: <50ms (Excellent)
  - 🟡 Yellow: 50-100ms (Good)
  - 🟠 Orange: >100ms (Fair)
- **Selected State**: Blue highlight with checkmark
- **Search**: Real-time filtering by name, country, or city
- **Scrollable**: Smooth scrolling for server list

### Interaction
- Tap server row to select
- Search bar filters in real-time
- Close button or click outside to dismiss
- Selected server shows checkmark icon

## Settings Window

**File**: `Views/SettingsView.swift`

### General Tab
```
┌─────────────────────────────────────────┐
│  General │ Security │ About             │ ← Tabs
├─────────────────────────────────────────┤
│  Connection                             │
│                                         │
│  ☑️ Connect automatically on startup    │ ← Toggle
│                                         │
│  Auto-connect server:                   │
│  [ Last used server        ▼ ]         │ ← Dropdown
│                                         │
│  ☑️ Show connection notifications       │ ← Toggle
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  System                                 │
│                                         │
│  Launch at login:                       │
│  [ Configure in System Settings ]      │ ← Button
│                                         │
└─────────────────────────────────────────┘
```

### Security Tab
```
┌─────────────────────────────────────────┐
│  General │ Security │ About             │
├─────────────────────────────────────────┤
│  Network Protection                     │
│                                         │
│  ☑️ Enable Kill Switch                  │ ← Toggle
│                                         │
│  When enabled, your internet connection │
│  will be blocked if the VPN disconnects │
│  unexpectedly, preventing data leaks.   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Security Status                        │
│                                         │
│  🔒  AES-256 Encryption       Active    │
│  👁️  No Activity Logs         Guaranteed│
│  🛡️  DNS Leak Protection      Enabled   │
│  📍  IP Masking               Active    │
│                                         │
└─────────────────────────────────────────┘
```

### About Tab
```
┌─────────────────────────────────────────┐
│  General │ Security │ About             │
├─────────────────────────────────────────┤
│                                         │
│              🛡️                          │ ← Large icon
│                                         │
│           SecureVPN                     │ ← App name
│                                         │
│          Version 1.0.0                  │ ← Version
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│      Fast, Secure, Private              │
│                                         │
│  SecureVPN provides a simple way to     │
│  connect securely to the internet       │
│  through encrypted tunnels. Your        │
│  privacy is our priority.               │
│                                         │
│                                         │
│           Privacy Policy                │ ← Links
│          Terms of Service               │
│              Support                    │
│                                         │
│  © 2025 SecureVPN. All rights reserved. │
│                                         │
└─────────────────────────────────────────┘
```

## Notification Examples

### Connection Notifications

**Connecting**
```
┌─────────────────────────────────┐
│ SecureVPN              [Close]  │
│ Connecting to United States -   │
│ New York...                     │
└─────────────────────────────────┘
```

**Connected**
```
┌─────────────────────────────────┐
│ SecureVPN              [Close]  │
│ Connected to United States -    │
│ New York                        │
└─────────────────────────────────┘
```

**Disconnected**
```
┌─────────────────────────────────┐
│ SecureVPN              [Close]  │
│ Disconnected from United States │
│ - New York                      │
└─────────────────────────────────┘
```

**Error**
```
┌─────────────────────────────────┐
│ SecureVPN Error        [Close]  │
│ Failed to connect to United     │
│ States - New York               │
└─────────────────────────────────┘
```

## Window Specifications

### Main Window
- **Size**: 400x500 pixels (fixed)
- **Style**: Hidden title bar
- **Resizable**: No
- **Background**: Gradient (non-translucent)
- **Appearance**: Follows system (light/dark mode)

### Server Selection Modal
- **Size**: 500x600 pixels
- **Type**: Sheet modal
- **Background**: System window background
- **Dismissible**: Yes (close button or outside click)

### Settings Window
- **Size**: 500x400 pixels
- **Type**: Standard window
- **Tabs**: 3 (General, Security, About)
- **Background**: System window background
- **Shortcut**: ⌘, (Command-Comma)

## Animation Details

### Connection Status
- **Transition**: 0.3s ease-in-out
- **Circle Pulse**: When connecting (orange)
- **Glow Effect**: When connected (green with shadow)
- **Icon Rotation**: Connecting state (arrows spinning)

### Button States
- **Hover**: Subtle brightness increase
- **Press**: Slight scale down (0.95)
- **Disabled**: 50% opacity, no interaction
- **Color Transition**: 0.2s ease

### Modal Animations
- **Sheet Slide**: Smooth slide up from bottom
- **Dismiss**: Slide down animation
- **Background Dim**: 30% black overlay

### Search Results
- **Filter**: Instant (no animation)
- **Scroll**: Native smooth scrolling
- **Highlight**: Blue background on hover

## Typography

### Main Screen
- **App Title**: 28pt, Bold, White
- **Status Text**: 24pt, Semibold, White
- **IP/Timer**: 14pt, Medium, 90% White
- **Button Text**: 18pt, Bold, White
- **Security Labels**: 11pt, Regular, 70% White

### Server Selection
- **Header**: 20pt, Bold
- **Server Name**: 16pt, Semibold
- **Latency**: 13pt, Regular, Gray
- **Search Placeholder**: System default

### Settings
- **Tab Labels**: System default
- **Section Headers**: Headline style
- **Body Text**: 13pt, Regular
- **Toggle Labels**: 13pt, Regular
- **Links**: 12pt, System Blue

## Icon Reference

### System Icons (SF Symbols)
- **Shield (connected)**: `checkmark.shield.fill`
- **Shield (disconnected)**: `shield.slash.fill`
- **Connecting**: `arrow.triangle.2.circlepath`
- **Error**: `exclamationmark.triangle.fill`
- **Settings**: `gearshape.fill`
- **Search**: `magnifyingglass`
- **Close**: `xmark.circle.fill`
- **Checkmark**: `checkmark.circle.fill`
- **Chevron**: `chevron.right`
- **Lock**: `lock.shield.fill`
- **Eye Slash**: `eye.slash.fill`
- **Network**: `network`
- **Location**: `location.fill`
- **Clock**: `clock.fill`

### Flag Emojis
- 🇺🇸 United States
- 🇬🇧 United Kingdom
- 🇩🇪 Germany
- 🇯🇵 Japan
- 🇸🇬 Singapore
- 🇨🇦 Canada
- 🇦🇺 Australia
- 🌍 Generic/Unselected

## Accessibility Features

### VoiceOver Support
- All buttons have clear labels
- Status changes announced
- Server selection navigable
- Settings fully accessible

### Keyboard Navigation
- Tab order logical and complete
- Return/Space activates buttons
- Escape closes modals
- ⌘, opens settings
- All controls keyboard accessible

### Color Contrast
- White text on dark background (high contrast)
- Color-coded indicators also have text
- Icon + text redundancy
- Clear visual hierarchy

## Dark Mode Support

The app automatically adapts to system appearance:
- **Light Mode**: Lighter backgrounds, darker text
- **Dark Mode**: Current gradient, white text
- **Auto**: Follows system setting

All colors adjust appropriately for both modes.

---

This UI design prioritizes:
- ✅ Simplicity and clarity
- ✅ Visual feedback
- ✅ Native macOS patterns
- ✅ Accessibility
- ✅ Modern aesthetics

Perfect for screenshots, documentation, and promotional materials!
