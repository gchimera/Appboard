# Gestione Categorie WebLink - AppBoard

## Problema Risolto

La modifica delle categorie per i WebLink non funzionava né tramite context menu né tramite drag & drop. Ora entrambi i metodi sono completamente funzionanti!

## Funzionalità Implementate

### 1. 🖱️ **Drag & Drop**

Puoi ora trascinare i WebLink sulle categorie nella sidebar esattamente come fai con le app.

**Come usarlo:**
1. Clicca e trascina un WebLink dalla griglia
2. Trascina sopra una categoria nella sidebar
3. La categoria si evidenzia quando il cursore è sopra
4. Rilascia per assegnare il link alla nuova categoria

**Feedback Visivo:**
- ✨ Categoria si evidenzia in blu quando hover
- 🔄 Animazione smooth della scala (1.02x)
- 📝 Log in console: `WebLink [nome] assegnato alla categoria [categoria] tramite drag-drop`

### 2. 🔧 **Context Menu**

Click destro su un WebLink mostra ora un menu completo con l'opzione per cambiare categoria.

**Opzioni Menu:**
- **Apri** - Apre l'URL nel browser predefinito
- **Copia URL** - Copia l'URL negli appunti
- **Mostra Dettagli** - Apre la finestra dei dettagli
- **Sposta in Categoria** ➜ Submenu con tutte le categorie disponibili
- **Elimina** - Rimuove il WebLink (conferma richiesta)

**Submenu Categorie:**
```
Sposta in Categoria ➜
    ├─ Sistema
    ├─ Produttività
    ├─ Creatività
    ├─ Sviluppo
    ├─ [tutte le altre categorie]
    └─ [categorie personalizzate]
```

### 3. 📝 **Modifica nei Dettagli**

Nella finestra dettagli del WebLink puoi anche modificare la categoria usando il picker.

## Implementazione Tecnica

### Modifiche ai File

#### 1. **WebLink.swift**
Aggiunto metodo helper per creare una copia con categoria aggiornata:

```swift
func withUpdatedCategory(_ newCategory: String?) -> WebLink {
    var updated = self
    updated.categoryName = newCategory
    return updated
}
```

#### 2. **WebLinkGridItem.swift**
Aggiunti callbacks per gestire eliminazione e cambio categoria:

```swift
var onDelete: ((WebLink) -> Void)? = nil
var onChangeCategory: ((WebLink, String) -> Void)? = nil
var availableCategories: [String] = []
```

Context menu aggiornato con submenu:
```swift
Menu("Sposta in Categoria") {
    ForEach(availableCategories.filter { $0 != "Tutte" }, id: \.self) { category in
        Button(category) {
            onChangeCategory(webLink, category)
        }
    }
}
```

#### 3. **ContentView.swift**

**Drag Provider WebLink:**
```swift
// Register WebLink as JSON for drag & drop
provider.registerDataRepresentation(
    forTypeIdentifier: "com.appboard.weblink", 
    visibility: .all
)
```

**CategoryDropRow:**
Aggiornato per accettare WebLink:
```swift
.onDrop(of: [
    "com.appboard.app-info", 
    "com.appboard.app-info-list", 
    "com.appboard.weblink",  // ← NUOVO
    UTType.json.identifier
], isTargeted: $isDropTargeted)
```

Nuova funzione `handleDecodedWebLink`:
```swift
private func handleDecodedWebLink(_ webLink: WebLink) {
    DispatchQueue.main.async {
        guard webLink.categoryName != category else { return }
        
        let updatedLink = webLink.withUpdatedCategory(category)
        appManager.updateWebLink(updatedLink)
        
        print("WebLink \(webLink.name) assegnato alla categoria \(category)")
    }
}
```

**Callbacks in ContentView:**
```swift
WebLinkGridItem(
    // ... parametri esistenti ...
    onDelete: { linkToDelete in
        appManager.deleteWebLink(linkToDelete)
    },
    onChangeCategory: { link, newCategory in
        let updatedLink = link.withUpdatedCategory(newCategory)
        appManager.updateWebLink(updatedLink)
    },
    availableCategories: appManager.categories
)
```

## Flusso di Esecuzione

### Drag & Drop Flow

```
1. Utente inizia drag del WebLink
   ↓
2. NSItemProvider registra WebLink come JSON
   Tipo: "com.appboard.weblink"
   ↓
3. Utente trascina sopra categoria
   ↓
4. CategoryDropRow.onDrop attivato
   ↓
5. handleDrop() prova a decodificare WebLink
   ↓
6. handleDecodedWebLink() chiamato
   ↓
7. WebLink.withUpdatedCategory() crea copia aggiornata
   ↓
8. AppManager.updateWebLink() salva il cambiamento
   ↓
9. UI si aggiorna automaticamente (@Published)
```

### Context Menu Flow

```
1. Utente fa click destro su WebLink
   ↓
2. Context menu mostrato con tutte le opzioni
   ↓
3. Utente seleziona "Sposta in Categoria" → [Nome Categoria]
   ↓
4. onChangeCategory callback chiamato
   ↓
5. WebLink.withUpdatedCategory() crea copia aggiornata
   ↓
6. AppManager.updateWebLink() salva il cambiamento
   ↓
7. UI si aggiorna automaticamente
```

## Testing

### Test 1: Drag & Drop
1. Aggiungi un WebLink (es. GitHub)
2. Assegna alla categoria "Sviluppo"
3. Clicca e trascina il WebLink
4. Trascina sopra "Produttività" nella sidebar
5. **Risultato Atteso**: WebLink si sposta in "Produttività"

### Test 2: Context Menu
1. Click destro su un WebLink
2. Seleziona "Sposta in Categoria"
3. Scegli una categoria diversa
4. **Risultato Atteso**: WebLink si sposta nella nuova categoria

### Test 3: Verifica Persistenza
1. Sposta un WebLink in una categoria
2. Chiudi l'app
3. Riapri l'app
4. **Risultato Atteso**: WebLink è ancora nella categoria corretta

### Test 4: Categoria "Tutte"
1. Prova a trascinare un WebLink sulla categoria "Tutte"
2. **Risultato Atteso**: Drop non permesso (categoria "Tutte" è virtuale)

## Log Console

Quando sposti un WebLink, vedrai:

```
✅ WebLink GitHub assegnato alla categoria Sviluppo tramite drag-drop
```

O tramite context menu:
```
✅ WebLink aggiornato: GitHub
```

## Compatibilità

- ✅ **Drag & Drop**: Funziona con WebLink singoli
- ✅ **Context Menu**: Mostra tutte le categorie disponibili
- ✅ **Sincronizzazione**: CloudKit supportato (quando implementato)
- ✅ **Undo/Redo**: Non ancora implementato (futuro)

## Limitazioni Attuali

1. **Selezione Multipla**: Drag & drop multiplo di WebLink non ancora supportato
2. **Undo**: Impossibile annullare lo spostamento (futuro)
3. **Batch Operations**: Non puoi spostare più link contemporaneamente via context menu

## Prossimi Miglioramenti

- [ ] Drag & drop multiplo per WebLink
- [ ] Undo/Redo per cambio categoria
- [ ] Animazione smooth quando si sposta un link
- [ ] Keyboard shortcut per cambio categoria rapido
- [ ] Batch edit per categoria (seleziona multipli → cambia categoria tutti)
- [ ] Smart suggestions per categoria basata su URL/descrizione

## Troubleshooting

### Il drag & drop non funziona
**Problema**: WebLink non si sposta quando lo trascino  
**Soluzione**: 
- Verifica che la categoria target non sia "Tutte"
- Controlla i log console per errori
- Ricompila l'app se hai modificato il codice

### Il context menu non mostra "Sposta in Categoria"
**Problema**: Menu mancante  
**Soluzione**:
- Verifica che `availableCategories` sia popolato
- Controlla che `onChangeCategory` sia passato come callback
- Compila con versione aggiornata di `WebLinkGridItem`

### Le modifiche non persistono
**Problema**: WebLink torna alla categoria originale al riavvio  
**Soluzione**:
- Verifica che `AppManager.updateWebLink()` chiami `saveWebLinks()`
- Controlla UserDefaults per la chiave "savedWebLinks"
- Debug log per verificare salvataggio

## Codice di Esempio

### Aggiungere nuovo callback personalizzato

```swift
// In WebLinkGridItem
var onCustomAction: ((WebLink) -> Void)? = nil

// Nel context menu
Button("Azione Personalizzata") {
    onCustomAction?(webLink)
}

// In ContentView
WebLinkGridItem(
    // ...
    onCustomAction: { link in
        // Fai qualcosa con il link
        print("Azione custom per: \(link.name)")
    }
)
```

### Creare helper per batch operations

```swift
extension AppManager {
    func updateWebLinksCategory(_ links: [WebLink], to category: String) {
        for link in links {
            let updated = link.withUpdatedCategory(category)
            updateWebLink(updated)
        }
    }
}
```

## Credits

Sviluppato da **ChimeraDev** (chimeradev.app)  
Parte del sistema di gestione WebLink con descrizioni AI
