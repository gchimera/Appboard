import SwiftUI
import Combine

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

                List(appManager.categories, id: \.self, selection: $selectedCategory) { category in
                    HStack {
                        CategoryIconView(category: category, size: 18, appManager: appManager)
                        Text(category)
                        Spacer()
                        Text("\(appManager.countForCategory(category))")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
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
            VStack(spacing: 0) {
                HeaderView(
                    searchText: $searchText,
                    viewMode: $viewMode,
                    sortOption: $sortOption,
                    showSettings: $showSettings,
                    onReload: reloadApps
                )
                .environmentObject(appManager)

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
        }
        .sheet(item: $selectedApp) { app in
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
