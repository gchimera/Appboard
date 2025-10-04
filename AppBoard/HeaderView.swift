import SwiftUI

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var viewMode: ContentView.ViewMode
    @Binding var sortOption: ContentView.SortOption
    @Binding var showSettings: Bool
    let onReload: () -> Void
    
    var body: some View {
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
                ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .frame(width: 150)
            
            Picker("Vista", selection: $viewMode) {
                Image(systemName: "square.grid.2x2").tag(ContentView.ViewMode.grid)
                Image(systemName: "list.bullet").tag(ContentView.ViewMode.list)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 100)
            
            // Sync indicator
            CompactSyncIndicator()
                .padding(.trailing, 8)
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .help("Impostazioni")
            }
            .buttonStyle(.plain)
            
            // Refresh loading apps
            Button {
                           onReload()
                       } label: {
                           Image(systemName: "arrow.clockwise")
                               .imageScale(.large)
                               .help("Ricarica app e cancella cache")
                       }
                       .buttonStyle(.plain)
                       .padding(.leading, 8)
            
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}
