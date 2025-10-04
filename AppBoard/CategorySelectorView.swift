import SwiftUI

struct CategorySelectorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appManager: AppManager
    @State private var selectedCategory: String
    @State private var showNewCategoryField = false
    @State private var newCategoryName = ""
    
    let app: AppInfo
    let onCategoryChanged: (String) -> Void
    
    // Categorie disponibili escludendo "Tutte"
    private var availableCategories: [String] {
        appManager.categories.filter { $0 != "Tutte" }
    }
    
    init(app: AppInfo, appManager: AppManager, onCategoryChanged: @escaping (String) -> Void) {
        self.app = app
        self.appManager = appManager
        self.onCategoryChanged = onCategoryChanged
        self._selectedCategory = State(initialValue: app.category)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cambia Categoria")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Per: \(app.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Annulla") {
                    dismiss()
                }
            }
            
            Divider()
            
            // Categoria attuale
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoria Attuale")
                    .font(.headline)
                
                HStack {
                    CategoryIconView(category: app.category, size: 20)
                    Text(app.category)
                        .font(.body)
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Seleziona nuova categoria
            VStack(alignment: .leading, spacing: 12) {
                Text("Seleziona Nuova Categoria")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(availableCategories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                CategoryIconView(category: category, size: 20)
                                Text(category)
                                    .font(.body)
                                Spacer()
                                
                                if selectedCategory == category {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedCategory == category ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCategory == category ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Pulsante per nuova categoria
                    Button(action: {
                        showNewCategoryField = true
                        newCategoryName = ""
                    }) {
                        HStack {
                            Text("➕")
                            Text("Nuova Categoria")
                                .font(.body)
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Campo per nuova categoria
                if showNewCategoryField {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nome Nuova Categoria")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            TextField("Inserisci nome categoria", text: $newCategoryName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    createNewCategory()
                                }
                            
                            Button("Crea") {
                                createNewCategory()
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Button("Annulla") {
                                showNewCategoryField = false
                                newCategoryName = ""
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Pulsanti azione
            HStack {
                Spacer()
                
                Button("Annulla") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Conferma Cambio") {
                    saveCategory()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCategory == app.category)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 500, height: 600)
    }
    
    private func createNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !appManager.categories.contains(trimmedName) {
            appManager.addCustomCategory(trimmedName)
            selectedCategory = trimmedName
            showNewCategoryField = false
            newCategoryName = ""
        }
    }
    
    private func saveCategory() {
        if selectedCategory != app.category {
            onCategoryChanged(selectedCategory)
        }
        dismiss()
    }
}

// Preview per sviluppo
#Preview {
    let appManager = AppManager()
    let sampleApp = AppInfo(
        id: UUID(),
        name: "App di Esempio",
        developer: "Developer",
        bundleIdentifier: "com.example.app",
        version: "1.0",
        path: "/Applications/Example.app",
        category: "Utilità",
        size: "100 MB",
        sizeInBytes: 100000000,
        lastUsed: Date()
    )
    
    return CategorySelectorView(
        app: sampleApp,
        appManager: appManager
    ) { newCategory in
        print("Nuova categoria: \(newCategory)")
    }
}