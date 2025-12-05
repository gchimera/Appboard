import SwiftUI

struct ServerSelectionView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @Binding var isPresented: Bool
    @State private var searchText = ""

    var filteredServers: [VPNServer] {
        if searchText.isEmpty {
            return VPNServer.availableServers
        }
        return VPNServer.availableServers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderSection(isPresented: $isPresented)

            SearchBar(searchText: $searchText)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredServers) { server in
                        ServerRow(server: server, isSelected: server.id == vpnManager.currentServer?.id)
                            .onTapGesture {
                                selectServer(server)
                            }
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func selectServer(_ server: VPNServer) {
        vpnManager.currentServer = server
        isPresented = false

        if vpnManager.connectionStatus == .connected {
            vpnManager.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                vpnManager.connect(to: server)
            }
        }
    }
}

struct HeaderSection: View {
    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            Text("Select Server Location")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search locations...", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .padding()
    }
}

struct ServerRow: View {
    let server: VPNServer
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 15) {
            Text(server.flagEmoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(server.name)
                    .font(.system(size: 16, weight: .semibold))

                HStack(spacing: 8) {
                    if let latency = server.latency {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(latencyColor(latency))
                                .frame(width: 8, height: 8)

                            Text("\(latency)ms")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private func latencyColor(_ latency: Int) -> Color {
        if latency < 50 {
            return .green
        } else if latency < 100 {
            return .yellow
        } else {
            return .orange
        }
    }
}

#Preview {
    ServerSelectionView(isPresented: .constant(true))
        .environmentObject(VPNManager.shared)
}
