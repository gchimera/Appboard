import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appManager: AppManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var editingCategory: String?
    @State private var newName: String = ""
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: String?
    @State private var showingCreateNew = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("category_management_title".localized())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("close".localized()) {
                    dismiss()
                }
            }
            .padding()
            
            Divider()
            
            // Pulsante per aggiungere nuova categoria (in cima)
            Button(action: {
                showingCreateNew = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("create_new_category".localized())
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Divider()
            
            // Lista categorie unificate
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Tutte le categorie (escluso "Tutte")
                    ForEach(appManager.categories.filter { $0 != "Tutte" }, id: \.self) { category in
                        categoryRow(category)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .sheet(isPresented: $showingCreateNew) {
            CategoryCreationView(appManager: appManager) { newCategoryName in
                appManager.addCustomCategory(newCategoryName)
                showingCreateNew = false
            }
        }
        .alert("delete_category".localized(), isPresented: $showingDeleteAlert) {
            Button("delete".localized(), role: .destructive) {
                if let categoryToDelete = categoryToDelete {
                    let success = appManager.deleteCategory(categoryToDelete)
                    if !success {
                        // Potresti voler mostrare un altro alert per l'errore
                        print("Errore nell'eliminazione della categoria")
                    }
                }
                self.categoryToDelete = nil
            }
            Button("cancel".localized(), role: .cancel) {
                self.categoryToDelete = nil
            }
        } message: {
            if let categoryToDelete = categoryToDelete {
                let appCount = appManager.countForCategory(categoryToDelete)
                Text(String(format: "delete_category_message".localized(), categoryToDelete, appCount))
            }
        }
    }
    
    @ViewBuilder
    private func categoryRow(_ category: String) -> some View {
        let isCustom = appManager.isCustomCategory(category)
        
        HStack {
            CategoryIconView(category: category, size: 24, appManager: appManager)
            
            if editingCategory == category {
                // Modalità editing
                VStack(alignment: .leading, spacing: 2) {
                    TextField("category_name".localized(), text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            saveEdit()
                        }
                    Text(isCustom ? "custom_category".localized() : "default_category".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                // Modalità normale
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(.body)
                        .fontWeight(.medium)
                    Text(isCustom ? "custom_category".localized() : "default_category".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Contatore app
            Text("\(appManager.countForCategory(category))")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isCustom ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(isCustom ? .blue : .secondary)
            
            // Pulsanti azione
            if editingCategory == category {
                // Pulsanti salva/annulla
                HStack(spacing: 8) {
                    Button("save".localized()) {
                        saveEdit()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("cancel".localized()) {
                        cancelEdit()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                // Pulsanti modifica/elimina (per tutte le categorie)
                HStack(spacing: 8) {
                    Button(action: {
                        startEdit(category)
                    }) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(action: {
                        categoryToDelete = category
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(isCustom ? Color.blue.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCustom ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    
    // MARK: - Actions
    
    private func startEdit(_ category: String) {
        editingCategory = category
        newName = category
    }
    
    private func saveEdit() {
        guard let currentCategory = editingCategory else { return }
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedName.isEmpty && trimmedName != currentCategory {
            let success = appManager.renameCategory(from: currentCategory, to: trimmedName)
            if success {
                editingCategory = nil
                newName = ""
            }
        } else {
            cancelEdit()
        }
    }
    
    private func cancelEdit() {
        editingCategory = nil
        newName = ""
    }
    
}

// Preview per sviluppo
#Preview {
    let appManager = AppManager()
    appManager.addCustomCategory("Categoria Test")
    appManager.addCustomCategory("Altra Categoria")
    
    return CategoryManagementView(appManager: appManager)
}