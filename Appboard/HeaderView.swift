import SwiftUI

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var viewMode: ContentView.ViewMode
    @Binding var sortOption: ContentView.SortOption
    @Binding var showSettings: Bool
    @Binding var isGridSelectionMode: Bool
    @Binding var showAddWebLink: Bool
    let onReload: () -> Void
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack {
            TextField("search_apps".localized(), text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
            
            Spacer()
            
            Text("click_to_open".localized())
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Picker("sort_by".localized(), selection: $sortOption) {
                ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .frame(width: 150)
            
            Picker("view_mode".localized(), selection: $viewMode) {
                Image(systemName: "square.grid.2x2").tag(ContentView.ViewMode.grid)
                Image(systemName: "list.bullet").tag(ContentView.ViewMode.list)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 100)

            if viewMode == .grid {
                Button {
                    isGridSelectionMode.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isGridSelectionMode ? "checkmark.square.fill" : "checkmark.square")
                        Text(isGridSelectionMode ? "done".localized() : "select".localized())
                    }
                }
                .buttonStyle(.bordered)
                .help(isGridSelectionMode ? "end_selection".localized() : "enable_multi_select".localized())
            }
            
            // Add WebLink button
            Button {
                showAddWebLink = true
            } label: {
                Image(systemName: "link.badge.plus")
                    .imageScale(.large)
                    .help("add_website".localized())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
            
            // Sync indicator
            CompactSyncIndicator()
                .padding(.trailing, 8)
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .help("settings".localized())
            }
            .buttonStyle(.plain)
            
            // Refresh loading apps
            Button {
                           onReload()
                       } label: {
                           Image(systemName: "arrow.clockwise")
                               .imageScale(.large)
                               .help("reload_apps".localized())
                       }
                       .buttonStyle(.plain)
                       .padding(.leading, 8)
            
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}
