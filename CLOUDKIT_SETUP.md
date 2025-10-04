# Guida Configurazione Sincronizzazione iCloud per AppBoard

## Panoramica del Sistema

Il sistema di sincronizzazione iCloud per AppBoard permette di sincronizzare le categorie personalizzate e le assegnazioni delle app tra diversi dispositivi Mac utilizzando CloudKit.

### Caratteristiche Principali

- **Sincronizzazione automatica** ogni 5 minuti
- **Sincronizzazione manuale** tramite interfaccia utente  
- **Gestione conflitti** con strategie configurabili
- **Supporto offline** con coda delle operazioni
- **Risoluzione conflitti interattiva** per l'utente
- **Monitoring stato rete** e status CloudKit

## Configurazione del Progetto

### 1. Aggiungi CloudKit Capability

Nel progetto Xcode:
1. Seleziona il target **AppBoard**
2. Vai su **Signing & Capabilities**
3. Clicca su **+ Capability**
4. Aggiungi **iCloud**
5. Seleziona **CloudKit**
6. Configura il container: `iCloud.com.appboard.mac`

### 2. Configura Entitlements

Il file `AppBoard.entitlements` è già creato con la configurazione necessaria:

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.appboard.mac</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### 3. Configura CloudKit Dashboard

1. Vai su [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Seleziona il container `iCloud.com.appboard.mac`
3. Crea i seguenti Record Types:

#### Record Type: `AppAssignment`
- `bundleIdentifier` (String, Indexed)
- `assignedCategory` (String, Indexed)  
- `lastModified` (Date/Time, Indexed)
- `deviceName` (String)

#### Record Type: `CustomCategory`
- `name` (String, Indexed)
- `icon` (String)
- `isCustom` (Int64)
- `lastModified` (Date/Time, Indexed)
- `deviceName` (String)

### 4. Configurazione Team e Signing

Assicurati che:
- Il **Development Team** sia configurato correttamente
- Il **Bundle Identifier** corrisponda: `com.appboard.mac`
- I **Provisioning Profiles** includano CloudKit

## Architettura del Sistema

### Componenti Principali

1. **CloudKitModels.swift** - Modelli dati sincronizzabili
2. **CloudKitManager.swift** - Manager principale per sync
3. **SyncConflictResolver.swift** - Gestione conflitti
4. **SyncView.swift** - Interfaccia utente per sync
5. **AppManager.swift** (modificato) - Integrazione con sync

### Flusso di Sincronizzazione

1. **Modifiche Locali** → Creazione `SyncableAppData` / `SyncableCategoryData`
2. **Upload** → CloudKit Records via `CloudKitManager`
3. **Download** → Query records remoti  
4. **Merge** → Risoluzione conflitti con `SyncConflictResolver`
5. **Applicazione** → Aggiornamento dati locali via notifiche

### Gestione Conflitti

Il sistema supporta diverse strategie di risoluzione:

- `useNewest` - Usa la versione più recente (default)
- `useLocal` - Mantieni sempre la versione locale  
- `useRemote` - Usa sempre la versione remota
- `askUser` - Richiedi intervento utente
- `merge` - Unisci automaticamente le modifiche

## Utilizzo dell'Interfaccia

### Indicatore Sync nella Header

L'indicatore compatto mostra:
- **Verde** - Sincronizzato correttamente
- **Blu** - Sincronizzazione in corso
- **Rosso** - Errore di sincronizzazione
- **Arancione** - Offline
- **Grigio** - Inattivo

### Pannello Sincronizzazione

Accessibile cliccando sull'indicatore:
- Stato attuale sincronizzazione
- Toggle sincronizzazione automatica
- Pulsante sincronizzazione manuale
- Dettagli elemento sincronizzati

### Impostazioni

Nelle impostazioni dell'app:
- Abilita/disabilita sincronizzazione
- Stato account iCloud
- Impostazioni avanzate

## Test e Debug

### Verifica Configurazione

```swift
// Test account status
let status = await CloudKitManager.shared.checkAccountStatus()
print("iCloud Status: \(status)")

// Test manual sync
await CloudKitManager.shared.syncAll()
```

### Debug Logging

Il sistema include logging dettagliato:
- Operazioni CloudKit
- Conflitti risolti
- Errori di rete
- Status sincronizzazione

### Test Multi-Dispositivo

1. Installa l'app su dispositivi diversi
2. Configura stesso account iCloud
3. Crea categorie personalizzate su dispositivo A
4. Verifica sincronizzazione su dispositivo B
5. Testa risoluzione conflitti modificando stessa categoria

## Risoluzione Problemi

### Account iCloud Non Disponibile
- Verifica account iCloud nelle Preferenze Sistema
- Controlla connessione internet
- Verifica abilitazione iCloud Drive

### Errori di Sincronizzazione
- Controlla CloudKit Dashboard per errori
- Verifica entitlements e capabilities
- Controlla log per errori specifici

### Conflitti Persistenti
- Usa risoluzione manuale conflitti
- Forza sincronizzazione completa
- Reset cache locale se necessario

## Sicurezza e Privacy

- **Dati Privati**: Tutti i dati sono memorizzati nel database privato dell'utente
- **Crittografia**: CloudKit crittografa automaticamente i dati
- **Accesso**: Solo l'utente proprietario può accedere ai suoi dati
- **Dispositivi**: Sincronizzazione limitata ai dispositivi dello stesso account iCloud

## Performance

### Ottimizzazioni Implementate

- **Sincronizzazione incrementale** - Solo dati modificati
- **Caching offline** - Operazioni in coda quando offline
- **Batch operations** - Operazioni CloudKit raggruppate
- **Background sync** - Sincronizzazione automatica in background

### Limiti CloudKit

- **Record Size**: Max 1MB per record
- **Request Rate**: Max 40 richieste/secondo
- **Database Size**: 1PB per utente (teorico)
- **Bandwidth**: Managed automaticamente da CloudKit

## Manutenzione

### Monitoring

Monitora regolarmente:
- Statistiche sincronizzazione
- Errori frequenti
- Performance query
- Utilizzo storage

### Aggiornamenti

Per aggiungere nuovi campi:
1. Aggiorna modelli Swift
2. Aggiorna CloudKit schema
3. Gestisci migrazione dati
4. Testa compatibilità versioni

## Esempi di Codice

### Sincronizzazione Manuale
```swift
@EnvironmentObject var appManager: AppManager

Button("Sync Now") {
    Task {
        await appManager.syncWithiCloud()
    }
}
```

### Controllo Stato
```swift
@ObservedObject var cloudKitManager = CloudKitManager.shared

Text(cloudKitManager.syncStatus.displayName)
    .foregroundColor(statusColor)
```

### Gestione Conflitti Personalizzata
```swift
let resolver = SyncConflictResolver(strategy: .askUser)
resolver.resolveCategoryConflict(local: localData, remote: remoteData)
```

---

## Contatti e Supporto

Per problemi o domande sulla sincronizzazione iCloud, consulta:
- CloudKit Documentation (Apple)
- CloudKit Best Practices
- Apple Developer Forums