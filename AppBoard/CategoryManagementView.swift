import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appManager: AppManager
    @State private var editingCategory: String?
    @State private var newName: String = ""
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: String?
    @State private var showingCreateNew = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Gestione Categorie")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Chiudi") {
                    dismiss()
                }
            }
            .padding()
            
            Divider()
            
            // Lista categorie
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Sezione categorie predefinite
                    sectionHeader("Categorie Predefinite", subtitle: "Non possono essere modificate")
                    
                    ForEach(appManager.categories.filter { !appManager.isCustomCategory($0) && $0 != "Tutte" }, id: \.self) { category in
                        defaultCategoryRow(category)
                    }
                    
                    // Sezione categorie personalizzate
                    if !appManager.customCategories.isEmpty {
                        sectionHeader("Categorie Personalizzate", subtitle: "Possono essere modificate o eliminate")
                        
                        ForEach(appManager.customCategories, id: \.self) { category in
                            customCategoryRow(category)
                        }
                    }
                    
                    // Pulsante per aggiungere nuova categoria
                    Button(action: {
                        showingCreateNew = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Aggiungi Nuova Categoria")
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
                    .padding(.top, 20)
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
        .alert("Elimina Categoria", isPresented: $showingDeleteAlert) {
            Button("Elimina", role: .destructive) {
                if let categoryToDelete = categoryToDelete {
                    let success = appManager.deleteCategory(categoryToDelete)
                    if !success {
                        // Potresti voler mostrare un altro alert per l'errore
                        print("Errore nell'eliminazione della categoria")
                    }
                }
                self.categoryToDelete = nil
            }
            Button("Annulla", role: .cancel) {
                self.categoryToDelete = nil
            }
        } message: {
            if let categoryToDelete = categoryToDelete {
                let appCount = appManager.countForCategory(categoryToDelete)
                Text("Sei sicuro di voler eliminare la categoria '\(categoryToDelete)'? \(appCount) app verranno spostate in 'Utilità'.")
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func defaultCategoryRow(_ category: String) -> some View {
        HStack {
            CategoryIconView(category: category, size: 24, appManager: appManager)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.body)
                    .fontWeight(.medium)
                Text("Categoria predefinita")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(appManager.countForCategory(category))")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func customCategoryRow(_ category: String) -> some View {
        HStack {
            CategoryIconView(category: category, size: 24, appManager: appManager)
            
            if editingCategory == category {
                // Modalità editing
                VStack(alignment: .leading, spacing: 2) {
                    TextField("Nome categoria", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            saveEdit()
                        }
                    Text("Categoria personalizzata")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                // Modalità normale
                VStack(alignment: .leading, spacing: 2) {
                    Text(category)
                        .font(.body)
                        .fontWeight(.medium)
                    Text("Categoria personalizzata")
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
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.blue)
            
            // Pulsanti azione
            if editingCategory == category {
                // Pulsanti salva/annulla
                HStack(spacing: 8) {
                    Button("Salva") {
                        saveEdit()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Annulla") {
                        cancelEdit()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                // Pulsanti modifica/elimina
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
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
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