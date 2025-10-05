import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @State private var searchText = ""
    @State private var selectedCategory = "Tutte"
    @State private var viewMode: ViewMode = .grid
    @State private var sortOption: SortOption = .name
    @State private var selectedApp: AppInfo? = nil
    @State private var iconSize: CGFloat = 64
    @State private var showSettings = false
    @State private var showCategoryManagement = false
    private var notificationCenter = NotificationCenter.default
    @State private var cancellable: AnyCancellable?

    let iconSizes: [CGFloat] = [32, 48, 64, 96, 128]
    let iconSizeLabels: [CGFloat: String] = [
        32: "Piccole",
        48: "Compatte",
        64: "Medie",
        96: "Grandi",
        128: "Molto grandi"
    ]

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

                List(appManager.categories, id: \.self) { category in
                    CategoryDropRow(
                        category: category,
                        appManager: appManager,
                        isSelected: category == selectedCategory
                    )
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
                .listStyle(SidebarListStyle())

                VStack(spacing: 8) {
                    Button("Gestisci Categorie") {
                        showCategoryManagement = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        } detail: {
            ZStack {
                VStack(spacing: 0) {
                    HeaderView(
                        searchText: $searchText,
                        viewMode: $viewMode,
                        sortOption: $sortOption,
                        showSettings: $showSettings,
                        onReload: reloadApps
                    )
                    .environmentObject(appManager)

                    // Questo è il blocco che ho erroneamente rimosso
                    ScrollView {
                        if viewMode == .grid {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                                ForEach(filteredApps) { app in
                                    AppGridItem(app: app, iconSize: iconSize) { selected in
                                        selectedApp = selected
                                    }
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
                .blur(radius: appManager.isLoading ? 3 : 0) // Applica un effetto blur durante il caricamento

                // Indicatore di caricamento
                if appManager.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Caricamento applicazioni installate...")
                            .padding(.top, 10)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.7))
                    .transition(.opacity)
                }
            }
            .animation(.default, value: appManager.isLoading)
        }        .sheet(item: $selectedApp) { app in
            AppDetailView(app: app)
                .environmentObject(appManager)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                iconSize: $iconSize,
                iconSizes: iconSizes,
                iconSizeLabels: iconSizeLabels
            )
            .environmentObject(appManager)
        }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView(appManager: appManager)
        }
        .onAppear {
            appManager.loadInstalledApps()

            cancellable = notificationCenter.publisher(for: NSApplication.willBecomeActiveNotification)
                .sink { _ in
                    if !appManager.isLoaded {
                        appManager.loadInstalledApps()
                    }
                }
        }
        .onDisappear {
            cancellable?.cancel()
        }
        
    }
    
    func reloadApps() {
        appManager.clearCache()
        appManager.loadInstalledApps()
    }

}

struct CategoryDropRow: View {
    let category: String
    @ObservedObject var appManager: AppManager
    let isSelected: Bool
    @State private var isDropTargeted = false
    
    var body: some View {
        HStack {
            CategoryIconView(category: category, size: 18, appManager: appManager)
            Text(category)
                .fontWeight(isSelected ? .semibold : .regular)
            Spacer()
            Text("\(appManager.countForCategory(category))")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .listRowBackground(dropBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(dropBorderColor, lineWidth: isDropTargeted ? 2 : 0)
        )
        .scaleEffect(isDropTargeted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDropTargeted)
        .onDrop(of: ["com.appboard.app-info", UTType.json.identifier], isTargeted: $isDropTargeted) { providers in
            handleAppDrop(providers: providers)
        }
    }
    
    private var dropBackgroundColor: Color {
        if isDropTargeted {
            return Color.accentColor.opacity(0.15)
        } else if isSelected {
            return Color.accentColor.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private var dropBorderColor: Color {
        return isDropTargeted ? Color.accentColor : Color.clear
    }
    
    private func handleAppDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        // Non permettere drop nella categoria "Tutte"
        guard category != "Tutte" else { return false }
        
        // Prova a leggere il nostro tipo custom, altrimenti fallback a JSON pubblico
        provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.app-info") { data, error in
            var decoded: AppInfo? = nil
            if let data = data {
                decoded = try? JSONDecoder().decode(AppInfo.self, from: data)
            } else {
                // Tentativo fallback con JSON generico
                provider.loadDataRepresentation(forTypeIdentifier: UTType.json.identifier) { jsonData, _ in
                    if let jsonData = jsonData {
                        decoded = try? JSONDecoder().decode(AppInfo.self, from: jsonData)
                    }
                    handleDecoded(decoded)
                }
                return
            }
            handleDecoded(decoded)
        }
        
        return true
    }
    
    private func handleDecoded(_ appInfo: AppInfo?) {
        guard let appInfo = appInfo else {
            print("Impossibile decodificare i dati dell'app durante drop")
            return
        }
        DispatchQueue.main.async {
            // Non fare nulla se l'app è già in questa categoria
            guard appInfo.category != category else { return }
            appManager.assignAppToCategory(app: appInfo, newCategory: category)
            print("App \\(appInfo.name) assegnata alla categoria \\(category) tramite drag-drop")
        }
    }
    
}
