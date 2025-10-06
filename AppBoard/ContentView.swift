import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @StateObject private var appManager = AppManager()
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var searchText = ""
    @State private var selectedCategory = "Tutte"
    @State private var viewMode: ViewMode = .grid
    @State private var sortOption: SortOption = .name
    @State private var selectedApp: AppInfo? = nil
    @State private var selectedWebLink: WebLink? = nil
    @State private var selectedAppIDs: Set<UUID> = []
    @AppStorage("iconSizePreference") private var iconSizePreference: Double = 64
    @State private var showSettings = false
    @State private var showCategoryManagement = false
    @State private var showAddWebLink = false
    @State private var showAddCategory = false
    @State private var isGridSelectionMode = false
    @State private var isCategoryReorderMode = false
    private var notificationCenter = NotificationCenter.default
    @State private var cancellable: AnyCancellable?

    let iconSizes: [CGFloat] = [32, 48, 64, 96, 128]
    
    var iconSizeLabels: [CGFloat: String] {
        [
            32: "icon_size_small".localized(),
            48: "icon_size_compact".localized(),
            64: "icon_size_medium".localized(),
            96: "icon_size_large".localized(),
            128: "icon_size_very_large".localized()
        ]
    }

    enum ViewMode {
        case grid, list
    }

    enum SortOption: String, CaseIterable {
        case name
        case category
        case size
        case lastUsed
        
        var displayName: String {
            switch self {
            case .name: return "sort_name".localized()
            case .category: return "sort_category".localized()
            case .size: return "sort_size".localized()
            case .lastUsed: return "sort_last_used".localized()
            }
        }
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
    
    var filteredWebLinks: [WebLink] {
        var links = appManager.webLinks

        if selectedCategory != "Tutte" {
            links = links.filter { $0.categoryName == selectedCategory }
        }

        if !searchText.isEmpty {
            links = links.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // Sort by name for now (weblinks don't have size or lastUsed)
        links.sort { $0.name < $1.name }

        return links
    }

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("categories".localized())
                        .font(.headline)
                    
                    Spacer()
                    
                    // Pulsante per attivare/disattivare modalità riordino
                    Button {
                        isCategoryReorderMode.toggle()
                    } label: {
                        Image(systemName: isCategoryReorderMode ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                            .foregroundColor(isCategoryReorderMode ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                    .help(isCategoryReorderMode ? "end_reorder".localized() : "start_reorder".localized())
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)

                List {
                    ForEach(Array(appManager.categories.enumerated()), id: \.element) { index, category in
                        CategoryDropRow(
                            category: category,
                            appManager: appManager,
                            isSelected: category == selectedCategory,
                            isReorderMode: isCategoryReorderMode,
                            categoryIndex: index,
                            totalCategories: appManager.categories.count,
                            onSelect: { selectedCategory = category },
                            onMoveUp: {
                                appManager.moveCategoryUp(at: index)
                            },
                            onMoveDown: {
                                appManager.moveCategoryDown(at: index)
                            }
                        )
                    }
                }
                .listStyle(SidebarListStyle())

                VStack(spacing: 8) {
                    Button("manage_categories".localized()) {
                        showCategoryManagement = true
                    }
                    .buttonStyle(.bordered)

                    HStack(spacing: 4) {
                        Text("developed_by".localized())
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
                        showAddWebLink: $showAddWebLink,
                        onReload: reloadApps
                    )
                    .environmentObject(appManager)

                    if viewMode == .grid {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                                // Web Links
                                ForEach(filteredWebLinks) { webLink in
                                    let isSelected = selectedAppIDs.contains(webLink.id)
                                    WebLinkGridItem(
                                        webLink: webLink,
                                        iconSize: CGFloat(iconSizePreference),
                                        onShowDetails: { selected in selectedWebLink = selected },
                                        selectionEnabled: isGridSelectionMode,
                                        isSelected: isSelected,
                                        onToggleSelection: {
                                            if isSelected {
                                                selectedAppIDs.remove(webLink.id)
                                            } else {
                                                selectedAppIDs.insert(webLink.id)
                                            }
                                        },
                                        makeDragItemProvider: {
                                            let provider = NSItemProvider()
                                            // Register WebLink as JSON for drag & drop to categories
                                            if let data = try? JSONEncoder().encode(webLink) {
                                                provider.registerDataRepresentation(forTypeIdentifier: "com.appboard.weblink", visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                                provider.registerDataRepresentation(forTypeIdentifier: UTType.json.identifier, visibility: .all) { completion in
                                                    completion(data, nil)
                                                    return nil
                                                }
                                            }
                                            return provider
                                        },
                                        onDelete: { linkToDelete in
                                            appManager.deleteWebLink(linkToDelete)
                                        },
                                        onChangeCategory: { link, newCategory in
                                            let updatedLink = link.withUpdatedCategory(newCategory)
                                            appManager.updateWebLink(updatedLink)
                                        },
                                        availableCategories: appManager.categories
                                    )
                                }
                                
                                // Apps
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
                                Text("list_name".localized())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 200, alignment: .leading)
                                Spacer()
                                Text("list_category".localized())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 100, alignment: .trailing)
                                Text("list_version".localized())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 60, alignment: .trailing)
                                Text("list_size".localized())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: 80, alignment: .trailing)
                                Text("list_last_used".localized())
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
                    FooterView(
                        totalApps: appManager.apps.count + appManager.webLinks.count,
                        filteredCount: filteredApps.count + filteredWebLinks.count
                    )
                }
                .blur(radius: appManager.isLoading ? 3 : 0) // Applica un effetto blur durante il caricamento

                // Indicatore di caricamento
                if appManager.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("loading_apps".localized())
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
        .sheet(isPresented: $showAddWebLink) {
            AddWebLinkView()
                .environmentObject(appManager)
        }
        .sheet(item: $selectedWebLink) { webLink in
            WebLinkDetailView(webLink: webLink)
                .environmentObject(appManager)
        }
        .sheet(isPresented: $showAddCategory) {
            CategoryCreationView(appManager: appManager) { newCategoryName in
                appManager.addCustomCategory(newCategoryName)
                showAddCategory = false
                selectedCategory = newCategoryName // Seleziona automaticamente la nuova categoria
            }
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
    let isReorderMode: Bool
    let categoryIndex: Int
    let totalCategories: Int
    var onSelect: (() -> Void)? = nil
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    @State private var isDropTargeted = false
    @State private var showEditDialog = false
    @State private var showDeleteAlert = false
    @State private var editedName = ""
    
    // Determina se la categoria può essere spostata in su
    private var canMoveUp: Bool {
        // "Tutte" non può mai essere spostata
        guard category != "Tutte" else { return false }
        // Non può spostarsi oltre "Tutte" (indice 1 è il minimo)
        return categoryIndex > 1
    }
    
    // Determina se la categoria può essere spostata in giù
    private var canMoveDown: Bool {
        // "Tutte" non può mai essere spostata
        guard category != "Tutte" else { return false }
        // Non può spostarsi oltre l'ultima posizione
        return categoryIndex < totalCategories - 1
    }
    
    var body: some View {
        HStack {
            // Mostra frecce solo in modalità riordino
            if isReorderMode {
                VStack(spacing: 2) {
                    Button {
                        onMoveUp?()
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.caption2)
                            .foregroundColor(canMoveUp ? .blue : .gray.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canMoveUp)
                    .help(canMoveUp ? "move_up".localized() : "cannot_move".localized())
                    
                    Button {
                        onMoveDown?()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(canMoveDown ? .blue : .gray.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canMoveDown)
                    .help(canMoveDown ? "move_down".localized() : "cannot_move".localized())
                }
                .frame(width: 20)
            }
            
            CategoryIconView(category: category, size: 18, appManager: appManager)
            Text(category == "Tutte" ? "all_categories".localized() : category)
                .fontWeight(isSelected ? .semibold : .regular)
            
            // Indicatore per categoria "Tutte" (non riordinabile)
            if category == "Tutte" {
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .help("fixed_category".localized())
            }
            
            Spacer()
            
            if !isReorderMode {
                Text("\(appManager.countForCategory(category))")
                    .foregroundColor(.secondary)
            }
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
            if !isReorderMode {
                onSelect?()
            }
        }
        .onDrop(of: ["com.appboard.app-info", "com.appboard.app-info-list", "com.appboard.weblink", UTType.json.identifier], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
        .contextMenu {
            if category != "Tutte" {
                // Tutte le categorie (predefinite e personalizzate) possono essere modificate
                Button {
                    editedName = category
                    showEditDialog = true
                } label: {
                    Label("rename".localized(), systemImage: "pencil")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("delete".localized(), systemImage: "trash")
                }
                
                if !appManager.isCustomCategory(category) {
                    Divider()
                    Text("default_category".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert("rename_category".localized(), isPresented: $showEditDialog) {
            TextField("new_name".localized(), text: $editedName)
            Button("cancel".localized(), role: .cancel) { }
            Button("rename".localized()) {
                if !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    _ = appManager.renameCategory(from: category, to: editedName)
                }
            }
        } message: {
            Text(String(format: "rename_category_message".localized(), category))
        }
        .alert("delete_category".localized(), isPresented: $showDeleteAlert) {
            Button("cancel".localized(), role: .cancel) { }
            Button("delete".localized(), role: .destructive) {
                _ = appManager.deleteCategory(category)
            }
        } message: {
            let itemCount = appManager.countForCategory(category)
            Text(String(format: "delete_category_message".localized(), category, itemCount))
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
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        // Non permettere drop nella categoria "Tutte"
        guard category != "Tutte" else { return false }
        
        // Prova prima WebLink
        provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.weblink") { data, _ in
            if let data = data, let webLink = try? JSONDecoder().decode(WebLink.self, from: data) {
                self.handleDecodedWebLink(webLink)
                return
            }
            // Poi prova AppInfo list
            provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.app-info-list") { listData, _ in
                if let listData = listData, let apps = try? JSONDecoder().decode([AppInfo].self, from: listData) {
                    self.handleDecodedArray(apps)
                    return
                }
                // Poi il payload singolo custom
                provider.loadDataRepresentation(forTypeIdentifier: "com.appboard.app-info") { data, _ in
                    if let data = data, let app = try? JSONDecoder().decode(AppInfo.self, from: data) {
                        self.handleDecoded(app)
                        return
                    }
                    // Fallback JSON generico - prova sia WebLink che AppInfo
                    provider.loadDataRepresentation(forTypeIdentifier: UTType.json.identifier) { jsonData, _ in
                        if let jsonData = jsonData {
                            // Prova WebLink
                            if let webLink = try? JSONDecoder().decode(WebLink.self, from: jsonData) {
                                self.handleDecodedWebLink(webLink)
                            }
                            // Prova AppInfo array
                            else if let apps = try? JSONDecoder().decode([AppInfo].self, from: jsonData) {
                                self.handleDecodedArray(apps)
                            }
                            // Prova AppInfo singola
                            else if let app = try? JSONDecoder().decode(AppInfo.self, from: jsonData) {
                                self.handleDecoded(app)
                            } else {
                                self.handleDecoded(nil)
                            }
                        } else {
                            self.handleDecoded(nil)
                        }
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
    
    private func handleDecodedWebLink(_ webLink: WebLink) {
        DispatchQueue.main.async {
            guard webLink.categoryName != category else { return }
            
            let updatedLink = webLink.withUpdatedCategory(category)
            appManager.updateWebLink(updatedLink)
            
            print("WebLink \(webLink.name) assegnato alla categoria \(category) tramite drag-drop")
        }
    }
    
}
