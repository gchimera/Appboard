import SwiftUI

struct CategoryIconPicker: View {
    @Binding var selectedIcon: String
    let availableIcons: [IconOption]
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    struct IconOption: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let displayName: String
        let isCustom: Bool
        
        init(name: String, displayName: String, isCustom: Bool = true) {
            self.name = name
            self.displayName = displayName
            self.isCustom = isCustom
        }
    }
    
    static let defaultIcons: [IconOption] = [
        // Categorie principali con emoji belle e significative
        IconOption(name: "📁", displayName: "Generale", isCustom: false),
        IconOption(name: "⚙️", displayName: "Sistema", isCustom: false),
        IconOption(name: "💼", displayName: "Produttività", isCustom: false),
        IconOption(name: "🎓", displayName: "Educazione", isCustom: false),
        IconOption(name: "🎵", displayName: "Multimedia", isCustom: false),
        IconOption(name: "🔒", displayName: "Sicurezza", isCustom: false),
        IconOption(name: "👨‍💻", displayName: "Sviluppo", isCustom: false),
        IconOption(name: "🔧", displayName: "Utilità", isCustom: false),
        IconOption(name: "🎮", displayName: "Giochi", isCustom: false),
        IconOption(name: "💬", displayName: "Social", isCustom: false),
        
        // Categorie utili aggiuntive
        IconOption(name: "💰", displayName: "Finanza", isCustom: false),
        IconOption(name: "🎨", displayName: "Design", isCustom: false),
        IconOption(name: "📸", displayName: "Foto", isCustom: false),
        IconOption(name: "🎬", displayName: "Video", isCustom: false),
        IconOption(name: "✈️", displayName: "Viaggi", isCustom: false),
        IconOption(name: "🛒", displayName: "Shopping", isCustom: false),
        IconOption(name: "🍕", displayName: "Cibo", isCustom: false),
        IconOption(name: "🏥", displayName: "Salute", isCustom: false),
        IconOption(name: "📰", displayName: "News", isCustom: false),
        IconOption(name: "☁️", displayName: "Cloud", isCustom: false),
        
        // Icone universali per personalizzazione
        IconOption(name: "⭐", displayName: "Preferiti", isCustom: false),
        IconOption(name: "🎯", displayName: "Obiettivi", isCustom: false),
        IconOption(name: "🔔", displayName: "Notifiche", isCustom: false),
        IconOption(name: "📊", displayName: "Analytics", isCustom: false),
        IconOption(name: "🔍", displayName: "Ricerca", isCustom: false),
        IconOption(name: "📝", displayName: "Note", isCustom: false),
        IconOption(name: "🚀", displayName: "Startup", isCustom: false),
        IconOption(name: "💡", displayName: "Idee", isCustom: false),
        IconOption(name: "⚡", displayName: "Veloce", isCustom: false),
        IconOption(name: "🌟", displayName: "Speciale", isCustom: false),
        IconOption(name: "✨", displayName: "Brillante", isCustom: false),
        
        // Icone divertenti e creative
        IconOption(name: "🎪", displayName: "Intrattenimento", isCustom: false),
        IconOption(name: "🧩", displayName: "Puzzle", isCustom: false),
        IconOption(name: "🎭", displayName: "Arte", isCustom: false),
        IconOption(name: "🏠", displayName: "Casa", isCustom: false),
        IconOption(name: "🌐", displayName: "Web", isCustom: false),
        IconOption(name: "📚", displayName: "Libri", isCustom: false),
        IconOption(name: "🔥", displayName: "Trending", isCustom: false),
        IconOption(name: "💎", displayName: "Premium", isCustom: false)
    ]
    
    init(selectedIcon: Binding<String>, availableIcons: [IconOption]? = nil) {
        self._selectedIcon = selectedIcon
        self.availableIcons = availableIcons ?? CategoryIconPicker.defaultIcons
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scegli un'icona")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableIcons) { icon in
                        IconSelectionButton(
                            icon: icon,
                            isSelected: selectedIcon == icon.name,
                            onSelect: {
                                selectedIcon = icon.name
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 300)
        }
    }
}

private struct IconSelectionButton: View {
    let icon: CategoryIconPicker.IconOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }
                    
                    if icon.isCustom {
                        Image(icon.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Text(icon.name)
                            .font(.system(size: 20))
                    }
                }
                
                Text(icon.displayName)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 60, height: 24)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @State var selectedIcon = "📁"
    
    return VStack {
        CategoryIconPicker(selectedIcon: $selectedIcon)
        
        Text("Icona selezionata: \(selectedIcon)")
            .padding()
    }
    .frame(width: 500, height: 450)
    .padding()
}
