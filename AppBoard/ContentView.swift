import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @State private var searchText = ""
    @State private var selectedCategory = "Tutte"
    @State private var viewMode: ViewMode = .grid
    @State private var sortOption: SortOption = .name
    @State private var selectedApp: AppInfo? = nil
    @State private var selectedAppIDs: Set<UUID> = []
    @AppStorage("iconSizePreference") private var iconSizePreference: Double = 64
    @State private var showSettings = false
    @State private var showCategoryManagement = false
    @State private var isGridSelectionMode = false
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
                        isSelected: category == selectedCategory,
                        onSelect: { selectedCategory = category }
                    )
                }
                .listStyle(SidebarListStyle())

                VStack(spacing: 8) {
                    Button("Gestisci Categorie") {
                        showCategoryManagement = true
                    }
                    .buttonStyle(.bordered)

                    HStack(spacing: 4) {
                        Text("developed by")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Link("chimeradev.app", destination: URL(string: "https://chimeradev.app")!)
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
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
                        isGridSelectionMode: $isGridSelectionMode,
                        onReload: reloadApps
                    )
                    .environmentObject(appManager)

                    if viewMode == .grid {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                                ForEach(filteredApps) { app in
                                    let isSelected = selectedAppIDs.contains(app.id)
                                    AppGridItem(
                                        app: app,
                                        iconSize: CGFloat(iconSizePreference),
                                        onShowDetails: { selected in selectedApp = selected },
                                        selectionEnabled: isGridSelectionMode,
                                        isSelected: isSelected,
                                        onToggleSelection: {
                                            if isSelected {
                                                selectedAppIDs.remove(app.id)
                                            } else {
                                                selectedAppIDs.insert(app.id)
                                            }
                                        },
                                        makeDragItemProvider: {
                                            // Costruisci payload in base alla selezione attiva
                                            let selected: [AppInfo]
                                            if isGridSelectionMode && selectedAppIDs.contains(app.id) && selectedAppIDs.count > 1 {
                                                let set = selectedAppIDs
                                                selected = filteredApps.filter { set.contains($0.id) }
                                            } else {
                                                selected = [app]
                                            }
                                            let provider = NSItemProvider()
                                            if selected.count == 1, let data = try? JSONEncoder().encode(selected[0]) {
                                                provider.registerDataRepresentation(forTypeIdentifier: "com.appboard.app-info", visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                                provider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                            } else if let data = try? JSONEncoder().encode(selected) {
                                                provider.registerDataRepresentation(forTypeIdentifier: "com.appboard.app-info-list", visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                                provider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                            }
                                            return provider
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 0) {
                            // Header
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

                            // Multi-selectable list of apps
                            List(selection: $selectedAppIDs) {
                                ForEach(filteredApps) { app in
                                    AppListItem(app: app) { selected in
                                        selectedApp = selected
                                    }
                                    .tag(app.id)
                                    .onTapGesture(count: 2) {
                                        // Apri app al doppio click
                                        let url = URL(fileURLWithPath: app.path)
                                        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
                                    }
                                    .onDrag {
                                        // Se l'app è selezionata e ci sono più selezioni, trascina tutte le selezionate
                                        let selected: [AppInfo]
                                        if selectedAppIDs.contains(app.id) && selectedAppIDs.count > 1 {
                                            let selectedSet = selectedAppIDs
                                            selected = filteredApps.filter { selectedSet.contains($0.id) }
                                        } else {
                                            selected = [app]
                                        }

                                        // Encoda payload singolo o multiplo
                                        let itemProvider = NSItemProvider()
                                        if selected.count == 1, let data = try? JSONEncoder().encode(selected[0]) {
                                            itemProvider.registerDataRepresentation(forTypeIdentifier: "com.appboard.app-info", visibility: .all) { completion in
                                                completion(data, nil)
                                                return nil
                                            }
                                            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                                                completion(data, nil)
                                                return nil
                                            }
                                        } else if let data = try? JSONEncoder().encode(selected) {
                                            itemProvider.registerDataRepresentation(forTypeIdentifier: "com.appboard.app-info-list", visibility: .all) { completion in
                                                completion(data, nil)
                                                return nil
                                            }
                                            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                                                completion(data, nil)
                                                return nil
                                            }
                                        }
                                        return itemProvider
                                    }
                                }
                            }
                            .listStyle(.inset)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                iconSize: Binding(
                    get: { CGFloat(iconSizePreference) },
                    set: { iconSizePreference = Double($0) }
                ),
                iconSizes: iconSizes,
                iconSizeLabels: iconSizeLabels
            )
            .environmentObject(appManager)
        }
        .sheet(isPresented: $showCategoryManagement) {
            CategoryManagementView(appManager: appManager)
        }
        .onAppear {
            // Carica app (la dimensione icone è persistita via @AppStorage)
            appManager.loadInstalledApps()

            cancellable = notificationCenter.publisher(for: NSApplication.willBecomeActiveNotification)
                .sink { _ in
                    // Keep icon size preference in sync when the app becomes active
                    if let saved = UserDefaults.standard.object(forKey: "iconSizePreference") as? Double {
                        iconSizePreference = saved
                    }
                    // Reload apps if needed
                    if !appManager.isLoaded {
                        appManager.loadInstalledApps()
                    }
                }
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .onChange(of: isGridSelectionMode) { isOn in
            if !isOn { selectedAppIDs.removeAll() }
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
    var onSelect: (() -> Void)? = nil
    
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
        .onTapGesture {
            onSelect?()
        }
        .onDrop(of: ["com.appboard.app-info", "com.appboard.app-info-list", UTType.json.identifier], isTargeted: $isDropTargeted) { providers in
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
        
        // Tenta prima il payload multiplo
        provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.app-info-list") { listData, _ in
            if let listData = listData, let apps = try? JSONDecoder().decode([AppInfo].self, from: listData) {
                handleDecodedArray(apps)
                return
            }
            // Poi il payload singolo custom
            provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.app-info") { data, _ in
                if let data = data, let app = try? JSONDecoder().decode(AppInfo.self, from: data) {
                    handleDecoded(app)
                    return
                }
                // Fallback JSON generico
                provider.loadDataRepresentation(forTypeIdentifier: UTType.json.identifier) { jsonData, _ in
                    if let jsonData = jsonData {
                        if let apps = try? JSONDecoder().decode([AppInfo].self, from: jsonData) {
                            handleDecodedArray(apps)
                        } else if let app = try? JSONDecoder().decode(AppInfo.self, from: jsonData) {
                            handleDecoded(app)
                        } else {
                            handleDecoded(nil)
                        }
                    } else {
                        handleDecoded(nil)
                    }
                }
            }
        }
        
        return true
    }
    
    private func handleDecoded(_ appInfo: AppInfo?) {
        guard let appInfo = appInfo else {
            print("Impossibile decodificare i dati dell'app durante drop")
            return
        }
        DispatchQueue.main.async {
            guard appInfo.category != category else { return }
            appManager.assignAppToCategory(app: appInfo, newCategory: category)
            print("App \\(appInfo.name) assegnata alla categoria \\(category) tramite drag-drop")
        }
    }

    private func handleDecodedArray(_ apps: [AppInfo]?) {
        guard let apps = apps, !apps.isEmpty else {
            print("Impossibile decodificare la lista di app durante drop")
            return
        }
        DispatchQueue.main.async {
            let uniqueApps = Dictionary(grouping: apps, by: { $0.bundleIdentifier }).compactMap { $0.value.first }
            for app in uniqueApps where app.category != category {
                appManager.assignAppToCategory(app: app, newCategory: category)
            }
            print("Assegnate \(uniqueApps.count) app alla categoria \(category) tramite drag-drop multiplo")
        }
    }
    
}
