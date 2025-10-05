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
        .frame(width: 550, height: 650)
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
}
