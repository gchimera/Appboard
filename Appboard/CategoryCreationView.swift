import SwiftUI

struct CategoryCreationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "📁"
    
    let appManager: AppManager
    let onSave: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("new_category".localized())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("cancel".localized()) {
                    dismiss()
                }
            }
            
            // Nome categoria
            VStack(alignment: .leading, spacing: 8) {
                Text("category_name".localized())
                    .font(.headline)
                
                TextField("enter_category_name".localized(), text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            saveCategory()
                        }
                    }
            }
            
            // Selezione icona
            VStack(alignment: .leading, spacing: 8) {
                Text("icon".localized())
                    .font(.headline)
                
                CategoryIconPicker(selectedIcon: $selectedIcon)
                    .frame(height: 350)
            }
            
            // Anteprima
            VStack(alignment: .leading, spacing: 8) {
                Text("preview".localized())
                    .font(.headline)
                
                HStack {
                    if selectedIcon.isEmpty {
                        CategoryIconView(category: categoryName.isEmpty ? "category_name".localized() : categoryName, size: 18, appManager: appManager)
                    } else {
                        Text(selectedIcon)
                            .font(.system(size: 18))
                    }
                    Text(categoryName.isEmpty ? "category_name".localized() : categoryName)
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
                
                Button("cancel".localized()) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("create_new_category".localized()) {
                    saveCategory()
                }
                .buttonStyle(.borderedProminent)
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 550, height: 720)
    }
    
    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            // Salva l'associazione icona-categoria se è stata selezionata un'icona personalizzata
            if !selectedIcon.isEmpty && selectedIcon != "📁" {
                appManager.setCustomCategoryIcon(category: trimmedName, iconName: selectedIcon)
            }
            onSave(trimmedName)
            dismiss()
        }
    }
}

// Preview per sviluppo
#Preview {
    CategoryCreationView(appManager: AppManager()) { categoryName in
        print("Nuova categoria: \(categoryName)")
    }
}
