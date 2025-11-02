import SwiftUI

struct SettingsView: View {
    @Binding var iconSize: CGFloat
    let iconSizes: [CGFloat]
    let iconSizeLabels: [CGFloat: String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var showResetAlert = false
    @State private var showToast = false
    @State private var toastMessage: String = ""
    @State private var toastStyle: ToastStyle = .success
    @State private var openAIKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    @State private var isKeyVisible: Bool = false
    @State private var isTesting: Bool = false
    @State private var showBackupView = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with title and close button
            HStack {
                Text("settings".localized())
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("close".localized()) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            
            Divider()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 20) {
                    // Language Settings
                    VStack(alignment: .leading, spacing: 12) {
                Text("language".localized())
                    .font(.headline)
                
                HStack {
                    Text("language".localized() + ":")
                    Spacer()
                    Picker(selection: $localizationManager.currentLanguage) {
                        Text("language_english".localized()).tag("en")
                        Text("language_italian".localized()).tag("it")
                    } label: {
                        EmptyView()
                    }
                    .labelsHidden()
                    .pickerStyle(MenuPickerStyle())
                    .frame(minWidth: 150, alignment: .leading)
                }
                
                Text("language_change_note".localized())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Divider()
            
            // UI Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("interface".localized())
                    .font(.headline)
                
                HStack {
                    Text("icon_size".localized())
                    Spacer()
                    Picker(selection: $iconSize) {
                        ForEach(iconSizes, id: \.self) { size in
                            Text(iconSizeLabels[size] ?? "\(Int(size)) pt")
                                .tag(size)
                        }
                    } label: {
                        EmptyView()
                    }
                    .labelsHidden()
                    .pickerStyle(MenuPickerStyle())
                    .frame(minWidth: 200, alignment: .leading)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // AI Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("artificial_intelligence".localized())
                    .font(.headline)
                
                Text("ai_description".localized())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    if isKeyVisible {
                        TextField("sk-...", text: $openAIKey)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("sk-...", text: $openAIKey)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button {
                        isKeyVisible.toggle()
                    } label: {
                        Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                    .help(isKeyVisible ? "hide_key".localized() : "show_key".localized())
                    
                    Button("save".localized()) {
                        UserDefaults.standard.set(openAIKey, forKey: "openai_api_key")
                        toastMessage = "api_key_saved".localized()
                        toastStyle = .success
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            showToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showToast = false
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(openAIKey.isEmpty)
                    
                    Button {
                        testConnection()
                    } label: {
                        HStack(spacing: 4) {
                            if isTesting {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "network")
                            }
                            Text("test".localized())
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(openAIKey.isEmpty || isTesting)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("get_api_key_from".localized())
                        .font(.caption)
                    Link("platform.openai.com", destination: URL(string: "https://platform.openai.com/api-keys")!)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                if openAIKey.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("no_api_key_warning".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Tutorial Avvio Automatico
            VStack(alignment: .leading, spacing: 12) {
                Text("auto_start".localized())
                    .font(.headline)
                
                Text("auto_start_description".localized())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("1.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("auto_start_step1".localized())
                                .fontWeight(.medium)
                            Text("auto_start_step1_detail".localized())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("2.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("auto_start_step2".localized())
                                .fontWeight(.medium)
                            Text("auto_start_step2_detail".localized())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("3.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("auto_start_step3".localized())
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("4.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("auto_start_step4".localized())
                                .fontWeight(.medium)
                            Text("auto_start_step4_detail".localized())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 4)
                
                Button(action: {
                    // Open System Settings > Login Items
                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("open_system_settings".localized())
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Gestione Categorie
            VStack(alignment: .leading, spacing: 12) {
                Text("categories".localized())
                    .font(.headline)
                Text("reset_categories_description".localized())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle")
                        Text("reset_categories".localized())
                    }
                }
                .help("reset_categories_help".localized())
            }
            .padding(.horizontal)
            
            Divider()
            
            // Backup & Restore Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Backup e Ripristino")  // Dovrebbe essere "backup_restore".localized()
                    .font(.headline)
                Text("Esporta o importa le tue app, link e categorie")  // Dovrebbe essere "backup_description".localized()
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button {
                    showBackupView = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Gestisci Backup")  // Non ha una chiave di localizzazione
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            Divider()
            
            // Version info at bottom of scroll
            VStack(spacing: 4) {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text(String(format: "app_version".localized(), version, build))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("app_version_default".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
                }
                .padding(.vertical)
            }
            
            .alert("reset_categories_alert_title".localized(), isPresented: $showResetAlert) {
                Button("cancel".localized(), role: .cancel) {}
                Button("confirm".localized(), role: .destructive) {
                    let count = appManager.resetCategoriesToDefaults()
                    toastMessage = String(format: "reset_completed".localized(), count)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showToast = false
                        }
                    }
                }
            } message: {
                Text("reset_categories_alert_message".localized())
            }
        }
        .frame(width: 550, height: 780)
        .sheet(isPresented: $showBackupView) {
            BackupView()
        }
        .alert("reset_categories_alert_title".localized(), isPresented: $showResetAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("confirm".localized(), role: .destructive) {
                let count = appManager.resetCategoriesToDefaults()
                toastMessage = String(format: "reset_completed".localized(), count)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    showToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showToast = false
                    }
                }
            }
        } message: {
            Text("reset_categories_alert_message".localized())
        }
        .overlay(alignment: .bottom) {
            if showToast {
                ToastView(message: toastMessage, style: toastStyle)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
                    .zIndex(1)
            }
        }
    }
    
    private func testConnection() {
        isTesting = true
        
        // Save the key temporarily to test
        let previousKey = UserDefaults.standard.string(forKey: "openai_api_key")
        UserDefaults.standard.set(openAIKey, forKey: "openai_api_key")
        
        Task {
            let testDescription = await AIDescriptionService.shared.generateDescription(
                for: "Test",
                url: "https://github.com"
            )
            
            await MainActor.run {
                // Restore previous key if it was different
                if let prev = previousKey, prev != openAIKey {
                    UserDefaults.standard.set(prev, forKey: "openai_api_key")
                }
                
                isTesting = false
                
                if let description = testDescription, description.contains("GitHub") || description.contains("Repository") {
                    toastMessage = "connection_successful".localized()
                    toastStyle = .success
                } else {
                    toastMessage = "connection_unexpected".localized()
                    toastStyle = .info
                }
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    showToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showToast = false
                    }
                }
            }
        }
    }
}