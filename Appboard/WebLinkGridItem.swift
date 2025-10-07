import SwiftUI
import UniformTypeIdentifiers

struct WebLinkGridItem: View {
    let webLink: WebLink
    let iconSize: CGFloat
    let onShowDetails: (WebLink) -> Void
    let selectionEnabled: Bool
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let makeDragItemProvider: () -> NSItemProvider
    var onDelete: ((WebLink) -> Void)? = nil
    var onChangeCategory: ((WebLink, String) -> Void)? = nil
    var availableCategories: [String] = []
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                // Icon
                if let favicon = webLink.favicon {
                    Image(nsImage: favicon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                } else {
                    Image(systemName: "globe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize * 0.6, height: iconSize * 0.6)
                        .foregroundColor(.blue)
                        .frame(width: iconSize, height: iconSize)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Selection indicator
                if selectionEnabled {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray.opacity(0.5))
                        .font(.system(size: 20))
                        .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                        .padding(4)
                }
                
                // Link indicator badge
                if !selectionEnabled {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.blue))
                        .offset(x: -4, y: -4)
                }
            }
            
            VStack(spacing: 2) {
                Text(webLink.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
                
                Text(webLink.displayURL)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: iconSize + 20)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            if selectionEnabled {
                onToggleSelection()
            } else {
                // Open URL in default browser
                if let url = URL(string: webLink.url) {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .onTapGesture(count: 2) {
            if !selectionEnabled {
                // Double click to show details
                onShowDetails(webLink)
            }
        }
        .onDrag {
            makeDragItemProvider()
        }
        .contextMenu {
            Button("Apri") {
                if let url = URL(string: webLink.url) {
                    NSWorkspace.shared.open(url)
                }
            }
            
            Button("Copia URL") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(webLink.url, forType: .string)
            }
            
            Divider()
            
            Button("Mostra Dettagli") {
                onShowDetails(webLink)
            }
            
            Divider()
            
            // Submenu per cambiare categoria
            if !availableCategories.isEmpty, let onChangeCategory = onChangeCategory {
                Menu("Sposta in Categoria") {
                    ForEach(availableCategories.filter { $0 != "Tutte" }, id: \.self) { category in
                        Button(category) {
                            onChangeCategory(webLink, category)
                        }
                    }
                }
            }
            
            Divider()
            
            Button("Elimina", role: .destructive) {
                onDelete?(webLink)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue.opacity(0.1)
        } else if isHovered {
            return Color.gray.opacity(0.05)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        isSelected ? .blue : .clear
    }
}
