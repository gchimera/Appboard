import SwiftUI

struct CategoryCreationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "📁"
    
    let onSave: (String) -> Void
    
    private let availableIcons = ["📁", "🎯", "⭐", "🔥", "💼", "🎭", "🚀", "⚡", "🎪", "🎨", "🔧", "📚", "🎵", "📊", "💎", "🎮"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Nuova Categoria")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Annulla") {
                    dismiss()
                }
            }
            
            // Nome categoria
            VStack(alignment: .leading, spacing: 8) {
                Text("Nome Categoria")
                    .font(.headline)
                
                TextField("Inserisci il nome della categoria", text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            saveCategory()
                        }
                    }
            }
            
            // Selezione icona
            VStack(alignment: .leading, spacing: 8) {
                Text("Icona")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                        }) {
                            Text(icon)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Anteprima
            VStack(alignment: .leading, spacing: 8) {
                Text("Anteprima")
                    .font(.headline)
                
                HStack {
                    Text(selectedIcon)
                    Text(categoryName.isEmpty ? "Nome Categoria" : categoryName)
                        .foregroundColor(categoryName.isEmpty ? .secondary : .primary)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Pulsanti azione
            HStack {
                Spacer()
                
                Button("Annulla") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Crea Categoria") {
                    saveCategory()
                }
                .buttonStyle(.borderedProminent)
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            onSave(trimmedName)
            dismiss()
        }
    }
}

// Preview per sviluppo
#Preview {
    CategoryCreationView { categoryName in
        print("Nuova categoria: \(categoryName)")
    }
}
