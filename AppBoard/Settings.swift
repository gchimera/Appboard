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
    @State private var openAIKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    @State private var isKeyVisible: Bool = false
    @State private var isTesting: Bool = false

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
            
            // AI Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Intelligenza Artificiale")
                    .font(.headline)
                
                Text("Configura la chiave API di OpenAI per generare automaticamente descrizioni dei siti web.")
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
                    .help(isKeyVisible ? "Nascondi chiave" : "Mostra chiave")
                    
                    Button("Salva") {
                        UserDefaults.standard.set(openAIKey, forKey: "openai_api_key")
                        toastMessage = "Chiave API salvata"
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
                            Text("Test")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(openAIKey.isEmpty || isTesting)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("Ottieni una chiave API da")
                        .font(.caption)
                    Link("platform.openai.com", destination: URL(string: "https://platform.openai.com/api-keys")!)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                if openAIKey.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Senza chiave API, verranno generate descrizioni di fallback basate sull'URL.")
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
                Text("Avvio Automatico")
                    .font(.headline)
                
                Text("Per far avviare AppBoard automaticamente al login:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("1.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apri Impostazioni di Sistema")
                                .fontWeight(.medium)
                            Text("Menu Apple () > Impostazioni di Sistema")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("2.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vai in Generali > Elementi login")
                                .fontWeight(.medium)
                            Text("Oppure cerca \"Elementi login\" nella barra di ricerca")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("3.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clicca il pulsante \"+\" sotto \"Apri al login\"")
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("4.")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Seleziona AppBoard dalla lista")
                                .fontWeight(.medium)
                            Text("Di solito si trova in Applicazioni")
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
                        Text("Apri Impostazioni di Sistema")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            
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
            
            // Version info
            VStack(spacing: 4) {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("AppBoard versione \(version) (\(build))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("AppBoard versione 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            Button("Chiudi") {
                dismiss()
            }
            .padding(.bottom)
        }
        .frame(width: 550, height: 780)
        .padding()
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
                    toastMessage = "✅ Connessione riuscita! API funzionante"
                    toastStyle = .success
                } else {
                    toastMessage = "⚠️ Connessione funziona ma risposta inattesa"
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
