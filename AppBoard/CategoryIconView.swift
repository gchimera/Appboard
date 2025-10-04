import SwiftUI

struct CategoryIconView: View {
    let category: String
    let size: CGFloat
    let useCustomIcons: Bool
    @ObservedObject private var appManager: AppManager
    
    init(category: String, size: CGFloat = 16, useCustomIcons: Bool = true, appManager: AppManager? = nil) {
        self.category = category
        self.size = size
        self.useCustomIcons = useCustomIcons
        self.appManager = appManager ?? AppManager()
    }
    
    var body: some View {
        if useCustomIcons {
            // Check for user-assigned custom icon first
            if let userCustomIcon = appManager.getCustomCategoryIcon(category: category) {
                // User custom icons are emoji strings, not image names
                Text(userCustomIcon)
                    .font(.system(size: size * 0.8))
                    .frame(width: size, height: size)
            } else if let predefinedCustomIcon = customIconName(for: category) {
                // Use predefined custom icon from Assets.xcassets
                Image(predefinedCustomIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                // Fallback to emoji
                Text(emojiIcon(for: category))
                    .font(.system(size: size * 0.8))
                    .frame(width: size, height: size)
            }
        } else {
            // Fallback to emoji
            Text(emojiIcon(for: category))
                .font(.system(size: size * 0.8))
                .frame(width: size, height: size)
        }
    }
    
    private func customIconName(for category: String) -> String? {
        switch category {
        case "Tutte":
            return "tutte-icon"  // Solo 'Tutte' mantiene l'icona personalizzata SVG
        default:
            return nil  // Tutte le altre categorie useranno le emoji
        }
    }
    
    private func emojiIcon(for category: String) -> String {
        switch category {
        case "Tutte":
            return "📱"
        case "Sistema":
            return "⚙️"
        case "Produttività":
            return "📊"
        case "Creatività":
            return "🎨"
        case "Sviluppo":
            return "💻"
        case "Giochi":
            return "🎮"
        case "Social":
            return "💬"
        case "Utilità":
            return "🔧"
        case "Educazione":
            return "🎓"
        case "Sicurezza":
            return "🔒"
        case "Multimedia":
            return "🎥"
        case "Comunicazione":
            return "📞"
        case "Finanza":
            return "💰"
        case "Salute":
            return "❤️"
        case "News":
            return "📰"
        default:
            return "📁"
        }
    }
}

// Extension to AppManager to support the new CategoryIconView
extension AppManager {
    func categoryIconView(for category: String, size: CGFloat = 16) -> CategoryIconView {
        CategoryIconView(category: category, size: size, appManager: self)
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("All Custom Icons:")
            .font(.headline)
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            ForEach(["Tutte", "Sistema", "Produttività", "Creatività", "Sviluppo", "Giochi", "Social", "Utilità", "Educazione", "Sicurezza", "Multimedia", "Comunicazione", "Finanza", "Salute", "News"], id: \.self) { category in
                VStack {
                    CategoryIconView(category: category, size: 32)
                    Text(category)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    .padding()
    .frame(width: 500)
}
