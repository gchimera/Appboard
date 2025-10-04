import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @State private var searchText = ""
    @State private var selectedCategory = "Tutte"
    @State private var viewMode: ViewMode = .grid
    @State private var sortOption: SortOption = .name
    @State private var selectedApp: AppInfo? = nil
    @State private var iconSize: CGFloat = 64 // Dimensione icone variabile

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
        
        if selectedCategory != "Tutte" {
            apps = apps.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
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
                    // Azione per creare categoria (da implementare)
                }
                .padding()
            }
        } detail: {
            VStack(spacing: 0) {
                // Header con ricerca e ordinamento
                headerView
                
                // Slider per modificare la dimensione icone
                iconSizeSlider
                
                // Contenuto app
                ScrollView {
                    if viewMode == .grid {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                            ForEach(filteredApps) { app in
                                AppGridItem(app: app, iconSize: iconSize, onShowDetails: { selected in
                                    selectedApp = selected
                                })
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 1) {
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
                                    AppListItem(app: app) { selected in
                                        selectedApp = selected
                                    }
                                }
                            }
                        }
                    }
                }
                FooterView(totalApps: appManager.apps.count, filteredCount: filteredApps.count)
            }
        }
        .sheet(item: $selectedApp) { app in
            AppDetailView(app: app)
        }
        .onAppear {
            appManager.loadInstalledApps()
        }
    }
    
    private var headerView: some View {
        HStack {
            TextField("Cerca applicazioni...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
            
            Spacer()
            
            Text("💡 Click per aprire • Click destro per opzioni")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Picker("Ordina per", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .frame(width: 150)
            
            Picker("Vista", selection: $viewMode) {
                Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
                Image(systemName: "list.bullet").tag(ViewMode.list)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var iconSizeSlider: some View {
        HStack {
            Text("Dimensione icone:")
            Slider(value: $iconSize, in: 32...128, step: 8)
                .frame(width: 150)
            Text("\(Int(iconSize)) pt")
                .frame(width: 50)
        }
        .padding(.horizontal)
    }
}

