# Multilingual Support Implementation

## Overview
This document describes the implementation of multilingual support for AppBoard, supporting both English and Italian languages.

## Implementation Date
October 6, 2025

## Supported Languages
- **English (en)** - Default for non-Italian systems
- **Italian (it)** - Default for Italian systems

## Architecture

### 1. LocalizationManager (`LocalizationManager.swift`)
A singleton class that manages the current language and provides localized strings throughout the app.

**Key Features:**
- Automatically detects system language on first launch
- Stores user's language preference in UserDefaults
- Provides `.localized()` extension for String type
- Uses `@Published` property to trigger UI updates when language changes

**Usage:**
```swift
Text("settings".localized())
```

### 2. Localization Files
Located in:
- `/AppBoard/en.lproj/Localizable.strings` - English translations
- `/AppBoard/it.lproj/Localizable.strings` - Italian translations

**Total Localized Strings:** 162 keys

### 3. Language Selection
Added to Settings view with:
- Dropdown picker for language selection
- Automatic app UI update when language changes
- No app restart required

## Modified Files

### Core Files
1. **LocalizationManager.swift** - NEW
   - Manages localization logic
   - Provides `localized()` extension

### Localization Files
2. **en.lproj/Localizable.strings** - NEW
   - English translations
   
3. **it.lproj/Localizable.strings** - NEW
   - Italian translations

### Updated Views
4. **Settings.swift**
   - Added language picker
   - Updated all strings to use localization
   - Added LocalizationManager observer

5. **ContentView.swift**
   - Updated all UI strings
   - Made icon size labels dynamic
   - Updated SortOption enum to use displayName property
   - Translated "Tutte" category display (keeping internal "Tutte" for logic)

6. **HeaderView.swift**
   - Updated search placeholder
   - Updated all tooltips and labels

7. **CategoryManagementView.swift**
   - Updated all strings including alerts

8. **AddWebLinkView.swift**
   - Updated form labels and placeholders

9. **FooterView.swift**
   - Updated app count messages

10. **AppDetailView.swift**
    - Updated labels and buttons
    - Added locale-aware date formatting

11. **WebLinkDetailView.swift**
    - Updated all form fields and buttons

12. **CategoryCreationView.swift**
    - Updated UI labels

13. **CategorySelectorView.swift**
    - Updated category selection interface

## Localization Categories

### General UI Elements
- Common buttons: close, cancel, save, confirm, delete, edit, add, create, done
- Navigation and actions

### Settings
- Interface settings (icon sizes)
- AI/OpenAI configuration
- Auto-start instructions
- Category management

### Categories
- Category management
- Category operations (rename, delete, reorder)
- Category types (custom vs. default)

### App Management
- App details
- App actions (open, show in Finder, copy path)
- Sorting options

### Web Links
- WebLink creation and editing
- URL validation
- AI description generation

### List Views
- Column headers
- Filter information

## Special Considerations

### Category "Tutte" / "All"
The category "Tutte" is kept as an internal identifier throughout the codebase for consistency. Only its display is translated to "All" in English. This prevents breaking existing logic that checks for `category == "Tutte"`.

### Dynamic Icon Size Labels
Icon size labels are computed dynamically based on the current language, ensuring they update immediately when the language changes.

### Date Formatting
Date formatting in AppDetailView uses locale-aware formatting based on the selected language (it_IT or en_US).

### Sort Options
Sort option display names are provided through a computed property `displayName` rather than using raw values, allowing proper localization.

## Testing Checklist

- [x] Language switching in Settings
- [x] All UI strings translated
- [x] No hardcoded Italian strings remaining
- [ ] Test app restart with different languages
- [ ] Test all dialogs and alerts
- [ ] Verify category display "Tutte" shows as "All" in English
- [ ] Verify date formatting changes with language
- [ ] Test all tooltips and help text

## Future Enhancements

1. **Additional Languages**
   - Framework supports easy addition of more languages
   - Simply create new `.lproj` folders and translations

2. **Dynamic Content Translation**
   - Default category names could be translated
   - User-created categories remain in original language

3. **Right-to-Left Support**
   - If adding Arabic/Hebrew, ensure layout adapts

4. **Pluralization Rules**
   - Implement proper plural handling for different languages

## How to Add a New Language

1. Create new language folder (e.g., `es.lproj/` for Spanish)
2. Copy `Localizable.strings` from `en.lproj/`
3. Translate all values (keep keys unchanged)
4. Update `LocalizationManager` to add new language option
5. Update Settings picker to include new language
6. Test thoroughly

## Notes for Developers

- Always use `.localized()` extension for user-facing strings
- Use `String(format: "key".localized(), args...)` for formatted strings
- Keep localization keys descriptive and grouped logically
- Update both `en.lproj` and `it.lproj` when adding new strings
- Test language switching to ensure all strings update properly

## Conclusion

The AppBoard application now fully supports English and Italian with seamless language switching. All user-facing strings have been externalized and the architecture supports easy addition of more languages in the future.
