import SwiftUI

struct SettingsView: View {
    @Binding var iconSize: CGFloat
    let iconSizes: [CGFloat]
    let iconSizeLabels: [CGFloat: String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @State private var showResetAlert = false
    @State private var showToast = false
    @State private var toastMessage: String = ""
    @State private var toastStyle: ToastStyle = .success

    // Avvio al login
    @State private var launchAtLoginEnabled: Bool = false
    @State private var isProcessingLaunchAtLogin: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Impostazioni")
                .font(.title)
                .padding(.top)
            
            Divider()
            
            // UI Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Interfaccia")
                    .font(.headline)
                
                HStack {
                    Text("Dimensione icone:")
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
            
            // Avvio al login
            if #available(macOS 13.0, *) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Avvio")
                        .font(.headline)
                    
                    HStack {
                        Toggle("Avvia al login", isOn: $launchAtLoginEnabled)
                            .disabled(isProcessingLaunchAtLogin)
                        
                        if isProcessingLaunchAtLogin {
                            ProgressView()
                                .scaleEffect(0.7)
                                .padding(.leading, 8)
                        }
                    }
                    
                    Text("Avvia automaticamente AppBoard all'accesso al sistema")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .onChange(of: launchAtLoginEnabled) { newValue in
                    Task {
                        await setLaunchAtLogin(enabled: newValue)
                    }
                }
            }
            
            Divider()
            
            // Gestione Categorie
            VStack(alignment: .leading, spacing: 12) {
                Text("Categorie")
                    .font(.headline)
                Text("Reimposta l'elenco delle categorie rimuovendo quelle aggiunte e riassegnando le app alle categorie iniziali.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle")
                        Text("Reset Categorie")
                    }
                }
                .help("Rimuove le categorie personalizzate e riassegna le app alle categorie iniziali")
            }
            .padding(.horizontal)
            .alert("Reset Categorie", isPresented: $showResetAlert) {
                Button("Annulla", role: .cancel) {}
                Button("Conferma", role: .destructive) {
                    let count = appManager.resetCategoriesToDefaults()
                    toastMessage = "Reset completato: \(count) app riassegnate"
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
                Text("Questa azione rimuoverà tutte le categorie aggiunte e riassegnare le relative app alle categorie iniziali. L'operazione non può essere annullata.")
            }
            
            Spacer()
            
            Button("Chiudi") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 500, height: 520)
        .padding()
        .overlay(alignment: .bottom) {
            if showToast {
                ToastView(message: toastMessage, style: toastStyle)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
                    .zIndex(1)
            }
        }
        .onAppear {
            if #available(macOS 13.0, *) {
                Task {
                    await refreshLaunchAtLoginState()
                }
            }
        }
    }
    
    // MARK: - Launch at Login Helpers
    @available(macOS 13.0, *)
    @MainActor
    private func refreshLaunchAtLoginState() async {
        launchAtLoginEnabled = LoginItemManager.isEnabled()
    }
    
    @available(macOS 13.0, *)
    @MainActor
    private func setLaunchAtLogin(enabled: Bool) async {
        isProcessingLaunchAtLogin = true
        defer { isProcessingLaunchAtLogin = false }
        
        do {
            let status = try LoginItemManager.setEnabledReturningStatus(enabled)
            
            switch status {
            case .enabled:
                toastMessage = "Avvio al login attivato"
                toastStyle = .success
                launchAtLoginEnabled = true
            case .disabled:
                toastMessage = "Avvio al login disattivato"
                toastStyle = .success
                launchAtLoginEnabled = false
            case .requiresApproval:
                toastMessage = "Richiesta approvazione nelle Impostazioni di Sistema"
                toastStyle = .info
                launchAtLoginEnabled = false
                // Open system preferences after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    LoginItemManager.openLoginItemsPreferences()
                }
            case .notFound:
                toastMessage = "Errore: Helper non trovato"
                toastStyle = .error
                launchAtLoginEnabled = false
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                showToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showToast = false
                }
            }
        } catch {
            toastMessage = "Errore: \(error.localizedDescription)"
            toastStyle = .error
            launchAtLoginEnabled = false
            
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
