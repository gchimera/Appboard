import Foundation
import CloudKit
import SwiftUI
import Combine

// MARK: - Conflict Types

enum SyncConflictType {
    case categoryNameConflict(local: SyncableCategoryData, remote: SyncableCategoryData)
    case appAssignmentConflict(local: SyncableAppData, remote: SyncableAppData)
    case categoryDeletion(categoryName: String, affectedApps: [String])
}

struct SyncConflict: Identifiable {
    let id = UUID()
    let type: SyncConflictType
    let timestamp: Date = Date()
    
    var description: String {
        switch type {
        case .categoryNameConflict(let local, let remote):
            return "Conflitto categoria '\(local.name)': modificata su dispositivi diversi"
        case .appAssignmentConflict(let local, let remote):
            return "Conflitto assegnazione app '\(local.bundleIdentifier)'"
        case .categoryDeletion(let categoryName, let affectedApps):
            return "Categoria '\(categoryName)' eliminata, \(affectedApps.count) app interessate"
        }
    }
}

// MARK: - Conflict Resolution Strategies

enum ConflictResolutionStrategy {
    case useLocal          // Mantieni la versione locale
    case useRemote         // Usa la versione remota
    case merge             // Tenta di unire le modifiche
    case askUser           // Chiedi all'utente
    case useNewest         // Usa la versione più recente (default)
    case useOldest         // Usa la versione più vecchia
}

// MARK: - Conflict Resolution Manager

@MainActor
class SyncConflictResolver: ObservableObject {
    @Published var pendingConflicts: [SyncConflict] = []
    @Published var showingConflictResolution = false
    
    private let strategy: ConflictResolutionStrategy
    
    init(strategy: ConflictResolutionStrategy = .useNewest) {
        self.strategy = strategy
    }
    
    // MARK: - Category Conflicts
    
    func resolveCategoryConflict(local: SyncableCategoryData, remote: SyncableCategoryData) async -> SyncableCategoryData {
        let conflict = SyncConflict(type: .categoryNameConflict(local: local, remote: remote))
        
        switch strategy {
        case .useLocal:
            return local
            
        case .useRemote:
            return remote
            
        case .useNewest:
            return local.lastModified > remote.lastModified ? local : remote
            
        case .useOldest:
            return local.lastModified < remote.lastModified ? local : remote
            
        case .merge:
            return mergeCategoryData(local: local, remote: remote)
            
        case .askUser:
            // Aggiungi il conflitto alla coda per risoluzione manuale
            pendingConflicts.append(conflict)
            showingConflictResolution = true
            
            // Per ora, usa la strategia newest come fallback
            return local.lastModified > remote.lastModified ? local : remote
        }
    }
    
    private func mergeCategoryData(local: SyncableCategoryData, remote: SyncableCategoryData) -> SyncableCategoryData {
        // Logica di merge per categorie
        var merged = local
        
        // Se l'icona remota è stata cambiata più di recente, usala
        if remote.lastModified > local.lastModified {
            merged = SyncableCategoryData(
                name: local.name,
                icon: remote.icon.isEmpty ? local.icon : remote.icon,
                isCustom: local.isCustom || remote.isCustom,
                deviceName: local.deviceName
            )
            merged.recordID = local.recordID
            merged.lastModified = max(local.lastModified, remote.lastModified)
        }
        
        return merged
    }
    
    // MARK: - App Assignment Conflicts
    
    func resolveAppAssignmentConflict(local: SyncableAppData, remote: SyncableAppData) async -> SyncableAppData {
        let conflict = SyncConflict(type: .appAssignmentConflict(local: local, remote: remote))
        
        switch strategy {
        case .useLocal:
            return local
            
        case .useRemote:
            return remote
            
        case .useNewest:
            return local.lastModified > remote.lastModified ? local : remote
            
        case .useOldest:
            return local.lastModified < remote.lastModified ? local : remote
            
        case .merge:
            // Per le assegnazioni app, il merge è semplice: usa la più recente
            return local.lastModified > remote.lastModified ? local : remote
            
        case .askUser:
            // Aggiungi il conflitto alla coda per risoluzione manuale
            pendingConflicts.append(conflict)
            showingConflictResolution = true
            
            // Fallback: usa la più recente
            return local.lastModified > remote.lastModified ? local : remote
        }
    }
    
    // MARK: - Category Deletion Conflicts
    
    func handleCategoryDeletion(categoryName: String, affectedApps: [String]) async -> ConflictResolutionAction {
        let conflict = SyncConflict(type: .categoryDeletion(categoryName: categoryName, affectedApps: affectedApps))
        
        switch strategy {
        case .useLocal, .useRemote:
            // Se la strategia è specifica, procedi con l'eliminazione
            return .delete
            
        case .askUser:
            // Chiedi all'utente cosa fare
            pendingConflicts.append(conflict)
            showingConflictResolution = true
            return .askUser
            
        default:
            // Per le eliminazioni, di default sposta le app in "Utilità"
            return .moveToDefault
        }
    }
    
    // MARK: - Batch Conflict Resolution
    
    func resolveAllConflicts() async {
        for conflict in pendingConflicts {
            await resolveConflict(conflict)
        }
        
        pendingConflicts.removeAll()
        showingConflictResolution = false
    }
    
    private func resolveConflict(_ conflict: SyncConflict) async {
        switch conflict.type {
        case .categoryNameConflict(let local, let remote):
            let resolved = await resolveCategoryConflict(local: local, remote: remote)
            // Notifica il risultato
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.category(resolved)
            )
            
        case .appAssignmentConflict(let local, let remote):
            let resolved = await resolveAppAssignmentConflict(local: local, remote: remote)
            // Notifica il risultato
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.appAssignment(resolved)
            )
            
        case .categoryDeletion(let categoryName, let affectedApps):
            let action = await handleCategoryDeletion(categoryName: categoryName, affectedApps: affectedApps)
            // Notifica il risultato
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.categoryDeletion(categoryName, action)
            )
        }
    }
    
    // MARK: - Manual Resolution
    
    func resolveConflictManually(_ conflict: SyncConflict, with choice: ManualResolutionChoice) {
        switch (conflict.type, choice) {
        case (.categoryNameConflict(let local, let remote), .useLocal):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.category(local)
            )
            
        case (.categoryNameConflict(let local, let remote), .useRemote):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.category(remote)
            )
            
        case (.appAssignmentConflict(let local, let remote), .useLocal):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.appAssignment(local)
            )
            
        case (.appAssignmentConflict(let local, let remote), .useRemote):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.appAssignment(remote)
            )
            
        case (.categoryDeletion(let categoryName, _), .delete):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.categoryDeletion(categoryName, .delete)
            )
            
        case (.categoryDeletion(let categoryName, _), .keepLocal):
            NotificationCenter.default.post(
                name: .conflictResolved,
                object: ConflictResolutionResult.categoryDeletion(categoryName, .keepLocal)
            )
            
        default:
            break
        }
        
        // Rimuovi il conflitto risolto
        pendingConflicts.removeAll { $0.id == conflict.id }
        
        if pendingConflicts.isEmpty {
            showingConflictResolution = false
        }
    }
}

// MARK: - Supporting Types

enum ConflictResolutionAction {
    case delete
    case moveToDefault
    case keepLocal
    case askUser
}

enum ManualResolutionChoice {
    case useLocal
    case useRemote
    case delete
    case keepLocal
}

enum ConflictResolutionResult {
    case category(SyncableCategoryData)
    case appAssignment(SyncableAppData)
    case categoryDeletion(String, ConflictResolutionAction)
}

// MARK: - Conflict Resolution UI

struct ConflictResolutionView: View {
    @ObservedObject var resolver: SyncConflictResolver
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Conflitti di Sincronizzazione")
                        .font(.headline)
                    Text("Risolvi i seguenti conflitti per continuare")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Annulla") {
                    dismiss()
                }
            }
            
            Divider()
            
            // Lista conflitti
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(resolver.pendingConflicts) { conflict in
                        ConflictItemView(conflict: conflict, resolver: resolver)
                    }
                }
            }
            
            Divider()
            
            // Azioni batch
            HStack {
                Button("Risolvi Tutto Automaticamente") {
                    Task {
                        await resolver.resolveAllConflicts()
                        dismiss()
                    }
                }
                
                Spacer()
                
                Button("Chiudi") {
                    dismiss()
                }
                .disabled(!resolver.pendingConflicts.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

struct ConflictItemView: View {
    let conflict: SyncConflict
    let resolver: SyncConflictResolver
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(conflict.description)
                .font(.subheadline)
                .fontWeight(.medium)
            
            switch conflict.type {
            case .categoryNameConflict(let local, let remote):
                CategoryConflictDetails(local: local, remote: remote, resolver: resolver, conflict: conflict)
                
            case .appAssignmentConflict(let local, let remote):
                AppAssignmentConflictDetails(local: local, remote: remote, resolver: resolver, conflict: conflict)
                
            case .categoryDeletion(let categoryName, let affectedApps):
                CategoryDeletionConflictDetails(categoryName: categoryName, affectedApps: affectedApps, resolver: resolver, conflict: conflict)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CategoryConflictDetails: View {
    let local: SyncableCategoryData
    let remote: SyncableCategoryData
    let resolver: SyncConflictResolver
    let conflict: SyncConflict
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Versione Locale")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Icona: \(local.icon)")
                    Text("Modificata: \(formatDate(local.lastModified))")
                    Text("Dispositivo: \(local.deviceName)")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Versione Remota")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Icona: \(remote.icon)")
                    Text("Modificata: \(formatDate(remote.lastModified))")
                    Text("Dispositivo: \(remote.deviceName)")
                }
            }
            .font(.caption)
            
            HStack {
                Button("Usa Locale") {
                    resolver.resolveConflictManually(conflict, with: .useLocal)
                }
                
                Button("Usa Remoto") {
                    resolver.resolveConflictManually(conflict, with: .useRemote)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AppAssignmentConflictDetails: View {
    let local: SyncableAppData
    let remote: SyncableAppData
    let resolver: SyncConflictResolver
    let conflict: SyncConflict
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Locale: \(local.assignedCategory)")
                    Text("Modificata: \(formatDate(local.lastModified))")
                    Text("Dispositivo: \(local.deviceName)")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remoto: \(remote.assignedCategory)")
                    Text("Modificata: \(formatDate(remote.lastModified))")
                    Text("Dispositivo: \(remote.deviceName)")
                }
            }
            .font(.caption)
            
            HStack {
                Button("Usa Locale") {
                    resolver.resolveConflictManually(conflict, with: .useLocal)
                }
                
                Button("Usa Remoto") {
                    resolver.resolveConflictManually(conflict, with: .useRemote)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CategoryDeletionConflictDetails: View {
    let categoryName: String
    let affectedApps: [String]
    let resolver: SyncConflictResolver
    let conflict: SyncConflict
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App interessate: \(affectedApps.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Elimina Categoria") {
                    resolver.resolveConflictManually(conflict, with: .delete)
                }
                
                Button("Mantieni Locale") {
                    resolver.resolveConflictManually(conflict, with: .keepLocal)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let conflictResolved = Notification.Name("conflictResolved")
}