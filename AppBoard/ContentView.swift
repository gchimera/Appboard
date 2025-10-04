import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @State private var searchText = ""
    @State private var selectedCategory = "Tutte"
    @State private var viewMode: ViewMode = .grid
    @State private var sortOption: SortOption = .name
    @State private var selectedApp: AppInfo? = nil
    @State private var showingCategoryCreation = false
    
    enum ViewMode {
        case grid, list
    }
    
    enum SortOption: String, CaseIterable {
        case name = "Nome"
        case category = "Categoria"
        case size = "Dimensione"
        case lastUsed = "Ultimo utilizzo"
    }
    
    var filteredApps: [AppInfo] {
        var apps = appManager.apps
        
        // Filtra per categoria
        if selectedCategory != "Tutte" {
            apps = apps.filter { $0.category == selectedCategory }
        }
        
        // Filtra per ricerca
        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Ordina
        switch sortOption {
        case .name:
            apps.sort { $0.name < $1.name }
        case .category:
            apps.sort { $0.category < $1.category }
        case .size:
            apps.sort { $0.sizeInBytes > $1.sizeInBytes }
        case .lastUsed:
            apps.sort { $0.lastUsed > $1.lastUsed }
        }
        
        return apps
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Categorie
            VStack(alignment: .leading, spacing: 0) {
                Text("Categorie")
                    .font(.headline)
                    .padding()
                
                List(appManager.categories, id: \.self, selection: $selectedCategory) { category in
                    HStack {
                        Text(appManager.iconForCategory(category))
                        Text(category)
                        Spacer()
                        Text("\(appManager.countForCategory(category))")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(SidebarListStyle())
                
                Button("Nuova Categoria") {
                    showingCategoryCreation = true
                }
                .padding()
            }
        } detail: {
            // Area principale
            VStack(spacing: 0) {
                // Header con ricerca e controlli
                HeaderView(
                    searchText: $searchText,
                    viewMode: $viewMode,
                    sortOption: $sortOption
                )
                
                // Contenuto principale
                // Nel body di ContentView.swift, sostituisci la sezione ScrollView con:

                ScrollView {
                    if viewMode == .grid {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                            ForEach(filteredApps) { app in
                                AppGridItem(app: app) { selected in
                                    selectedApp = selected
                                }
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 1) {
                            // Header della lista
                            HStack(spacing: 12) {
                                Text("Nome")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 200, alignment: .leading)
                                
                                Spacer()
                                
                                Text("Categoria")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 100, alignment: .trailing)
                                
                                Text("Versione")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 60, alignment: .trailing)
                                
                                Text("Dimensione")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 80, alignment: .trailing)
                                
                                Text("Ultimo Uso")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 100, alignment: .trailing)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            
                            LazyVStack(spacing: 0) {
                                ForEach(filteredApps) { app in
                                    AppGridItem(app: app) { selected in
                                        selectedApp = selected
                                    }
                                }
                            }
                        }
                    }
                }

                
                // Footer
                FooterView(totalApps: appManager.apps.count, filteredCount: filteredApps.count)
            }
        }
        .onAppear {
            appManager.loadInstalledApps()
        }
        // In ContentView.swift, nella parte body
        .sheet(item: $selectedApp) { app in
            AppDetailView(app: app)
        }
        .sheet(isPresented: $showingCategoryCreation) {
            CategoryCreationView { categoryName in
                appManager.addCustomCategory(categoryName)
            }
        }
    }
}
