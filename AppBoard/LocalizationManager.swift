import Foundation
import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
            updateBundle()
        }
    }
    
    private var bundle: Bundle = Bundle.main
    
    private func updateBundle() {
        bundle = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
            .flatMap { Bundle(path: $0) } ?? Bundle.main
    }
    
    private init() {
        // Load saved language or use system default
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language")
        
        if let saved = savedLanguage {
            currentLanguage = saved
        } else {
            // Check system language
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.hasPrefix("it") {
                currentLanguage = "it"
            } else {
                currentLanguage = "en"
            }
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
        }
        
        // Set initial bundle
        updateBundle()
    }
    
    func localizedString(_ key: String, comment: String = "") -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

// Helper extension for easier localization in SwiftUI
extension String {
    func localized() -> String {
        return LocalizationManager.shared.localizedString(self)
    }
}
