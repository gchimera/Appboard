import SwiftUI
import CloudKit

struct SyncView: View {
    @ObservedObject private var cloudKitManager = CloudKitManager.shared
    @EnvironmentObject private var appManager: AppManager
    @State private var showingSyncDetails = false
    @State private var accountStatus: CKAccountStatus = .couldNotDetermine
    @State private var showingAccountAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastStyle: ToastStyle = .success
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: cloudSymbolName)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Sincronizzazione iCloud")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingSyncDetails.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            // Sync Status
            SyncStatusSection()
            
            Divider()
            
            // Sync Controls
            SyncControlsSection(onShowToast: { message, style in
                toastMessage = message
                toastStyle = style
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    showToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showToast = false
                    }
                }
            })
            
            if showingSyncDetails {
                Divider()
                SyncDetailsSection()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .onAppear {
            Task {
                accountStatus = await cloudKitManager.checkAccountStatus()
            }
        }
        .alert("Account iCloud", isPresented: $showingAccountAlert) {
            Button("OK") { }
        } message: {
            Text(accountStatusMessage)
        }
        .overlay(alignment: .bottom) {
            if showToast {
                ToastView(message: toastMessage, style: toastStyle)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 12)
            }
        }
    }
    
    private var cloudSymbolName: String {
        cloudKitManager.syncStatus == .success ? "icloud.fill" : "icloud"
    }
    
    private var accountStatusMessage: String {
        switch accountStatus {
        case .available:
            return "Account iCloud disponibile"
        case .noAccount:
            return "Nessun account iCloud configurato. Vai nelle Impostazioni di Sistema per configurare iCloud."
        case .restricted:
            return "Account iCloud limitato dalle impostazioni"
        case .couldNotDetermine:
            return "Impossibile determinare lo stato dell'account iCloud"
        @unknown default:
            return "Stato account iCloud sconosciuto"
        }
    }
}

struct SyncStatusSection: View {
    @ObservedObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stato Sincronizzazione")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: cloudKitManager.syncStatus.icon)
                    .foregroundColor(statusColor)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(cloudKitManager.syncStatus.displayName)
                        .fontWeight(.medium)
                    
                    if let lastSync = cloudKitManager.lastSyncDate {
                        Text("Ultima sincronizzazione: \(formatDate(lastSync))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Indicator di rete
                HStack(spacing: 4) {
                    Circle()
                        .fill(cloudKitManager.isOnline ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(cloudKitManager.isOnline ? "Online" : "Offline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch cloudKitManager.syncStatus {
        case .success:
            return .green
        case .error:
            return .red
        case .syncing:
            return .blue
        case .offline:
            return .orange
        case .idle:
            return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SyncControlsSection: View {
    @ObservedObject private var cloudKitManager = CloudKitManager.shared
    @EnvironmentObject private var appManager: AppManager
    @State private var isSyncing = false
    var onShowToast: ((String, ToastStyle) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Controlli")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                // Toggle sincronizzazione automatica
                HStack {
                    Toggle("Sincronizzazione automatica", isOn: Binding(
                        get: { cloudKitManager.syncEnabled },
                        set: { enabled in
                            cloudKitManager.enableSync(enabled)
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Spacer()
                
                // Pulsante sincronizzazione manuale
                Button(action: {
                    Task {
                        isSyncing = true
                        await appManager.syncWithiCloud()
                        isSyncing = false
                        let status = appManager.syncStatus
                        switch status {
                        case .success:
                            onShowToast?("Sincronizzazione completata", .success)
                        case .error:
                            onShowToast?("Errore durante la sincronizzazione", .error)
                        case .offline:
                            onShowToast?("Offline: impossibile sincronizzare", .error)
                        case .syncing:
                            onShowToast?("Sincronizzazione in corso...", .info)
                        case .idle:
                            onShowToast?("Sincronizzazione inattiva", .info)
                        }
                    }
                }) {
                    HStack {
                        if isSyncing {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Sincronizza ora")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .disabled(isSyncing || !cloudKitManager.syncEnabled || !cloudKitManager.isOnline)
            }
        }
    }
}

struct SyncDetailsSection: View {
    @EnvironmentObject private var appManager: AppManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dettagli Sincronizzazione")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Categorie personalizzate:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(appManager.customCategories.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("App con categorie personalizzate:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(customAssignmentsCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Container iCloud:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("iCloud.com.appboard.mac")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var customAssignmentsCount: Int {
        appManager.apps.filter { appManager.isCustomCategory($0.category) }.count
    }
}

// MARK: - Compact Sync Indicator for Header

struct CompactSyncIndicator: View {
    @EnvironmentObject private var appManager: AppManager
    @State private var showingSyncView = false
    
    var body: some View {
        Button(action: {
            showingSyncView.toggle()
        }) {
            HStack(spacing: 4) {
                Image(systemName: appManager.syncStatus.icon)
                    .foregroundColor(statusColor)
                    .font(.caption)
                
                if appManager.syncStatus == .syncing {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .help(appManager.syncStatus.displayName)
        .popover(isPresented: $showingSyncView) {
            SyncView()
                .environmentObject(appManager)
                .frame(width: 400, height: 300)
        }
    }
    
    private var statusColor: Color {
        switch appManager.syncStatus {
        case .success:
            return .blue // Modificato da .green a .blue
        case .error:
            return .red
        case .syncing:
            return .orange // Usiamo arancione per indicare in corso
        case .offline:
            return .gray
        case .idle:
            return .secondary
        }
    }
}

// MARK: - Settings Integration

struct SyncSettingsSection: View {
    @EnvironmentObject private var appManager: AppManager
    @State private var showingAdvancedSettings = false
    
    var body: some View {
        GroupBox(label: Text("Sincronizzazione iCloud")) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Abilita sincronizzazione iCloud", isOn: Binding(
                    get: { appManager.isSyncEnabled },
                    set: { enabled in
                        appManager.setSyncEnabled(enabled)
                    }
                ))
                
                if appManager.isSyncEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Stato:")
                            Spacer()
                            Label(appManager.syncStatus.displayName, systemImage: appManager.syncStatus.icon)
                                .foregroundColor(statusColor)
                        }
                        
                        Button("Impostazioni Avanzate...") {
                            showingAdvancedSettings.toggle()
                        }
                        .sheet(isPresented: $showingAdvancedSettings) {
                            AdvancedSyncSettingsView()
                        }
                    }
                    .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var statusColor: Color {
        switch appManager.syncStatus {
        case .success:
            return .blue
        case .error:
            return .red
        case .syncing:
            return .orange
        case .offline:
            return .gray
        case .idle:
            return .secondary
        }
    }
}

struct AdvancedSyncSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Impostazioni Avanzate Sincronizzazione")
                    .font(.headline)
                Spacer()
                Button("Chiudi") {
                    dismiss()
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Container CloudKit:")
                    .fontWeight(.medium)
                Text("iCloud.com.appboard.mac")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Tipi di Record:")
                    .fontWeight(.medium)
                VStack(alignment: .leading, spacing: 4) {
                    Text("• AppAssignment - Assegnazioni categoria app")
                    Text("• CustomCategory - Categorie personalizzate")
                }
                .font(.caption)
            }
            
            Spacer()
            
            HStack {
                Button("Forza Sincronizzazione Completa") {
                    Task {
                        await cloudKitManager.syncAll()
                    }
                }
                .disabled(cloudKitManager.syncStatus == .syncing)
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    SyncView()
        .environmentObject(AppManager())
}