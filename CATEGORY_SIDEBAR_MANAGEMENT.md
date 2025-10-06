# Gestione Categorie dalla Sidebar - AppBoard

## Panoramica

Ora puoi gestire le categorie direttamente dalla sidebar senza dover aprire la finestra di gestione completa. Tutte le categorie possono essere modificate ed eliminate, **eccetto "Tutte"** che è una categoria virtuale speciale.

## 🎯 Funzionalità Implementate

### 1. **Context Menu su Categorie** 🖱️

Click destro su qualsiasi categoria nella sidebar per accedere a opzioni rapide.

#### Categorie Personalizzate
Per le categorie che hai creato tu (mostrate con badge 🔵):

**Opzioni disponibili:**
- ✏️ **Rinomina** - Cambia il nome della categoria
- 🗑️ **Elimina** - Rimuove la categoria (con conferma)

#### Categorie Predefinite
Per le categorie di sistema (Sistema, Produttività, etc.):

**Opzione disponibile:**
- ℹ️ Mostra solo "Categoria Predefinita" (non modificabile)

### 2. **Badge Identificativo** 🔵

Le categorie personalizzate mostrano un badge blu accanto al nome:
- Icona: `person.crop.circle.badge.checkmark`
- Tooltip: "Categoria personalizzata (modifica con click destro)"
- Colore: Blu

### 3. **Pulsante Rapido "+"** ➕

Un pulsante "+" accanto al titolo "Categorie" per aggiungere rapidamente nuove categorie.

**Posizione:**
```
┌─────────────────────┐
│ Categorie        [+]│  ← Qui
├─────────────────────┤
│ 📱 Tutte           │
│ ⚙️ Sistema          │
│ ...                 │
└─────────────────────┘
```

**Comportamento:**
- Click → Apre dialog creazione categoria
- Dopo creazione → Seleziona automaticamente la nuova categoria

## 📝 Come Usare

### Aggiungere una Categoria

**Metodo 1: Pulsante Rapido**
```
1. Click sul pulsante [+] accanto a "Categorie"
2. Inserisci il nome della nuova categoria
3. Conferma
4. La categoria viene creata e selezionata automaticamente
```

**Metodo 2: Pulsante "Gestisci Categorie"**
```
1. Click su "Gestisci Categorie" in fondo alla sidebar
2. Click su "Aggiungi Nuova Categoria"
3. Compila il form completo
4. Salva
```

### Rinominare una Categoria

```
1. Click destro sulla categoria personalizzata (con badge blu)
2. Seleziona "Rinomina" ✏️
3. Inserisci il nuovo nome nel dialog
4. Click "Rinomina"
```

**Nota:** Il nome viene aggiornato immediatamente per tutte le app e weblink assegnati.

### Eliminare una Categoria

```
1. Click destro sulla categoria personalizzata
2. Seleziona "Elimina" 🗑️
3. Leggi l'alert di conferma (mostra quanti elementi verranno spostati)
4. Conferma "Elimina"
```

**Cosa succede:**
- La categoria viene rimossa
- Tutte le app e weblink vengono spostati in "Utilità"
- Le modifiche sono persistenti

## 🛡️ Protezioni

### Categoria "Tutte"
- ❌ Non può essere modificata
- ❌ Non può essere eliminata
- ❌ Non mostra context menu con opzioni
- ℹ️ È una categoria virtuale che mostra tutti gli elementi

### Categorie Predefinite
Le seguenti categorie **NON possono** essere eliminate o rinominate:
- Sistema
- Produttività
- Creatività
- Sviluppo
- Giochi
- Social
- Utilità
- Educazione
- Sicurezza
- Multimedia
- Comunicazione
- Finanza
- Salute
- News

**Motivo:** Garantiscono una base stabile per la categorizzazione automatica delle app.

### Categorie Personalizzate
Tutte le altre categorie che crei possono essere:
- ✅ Rinominate
- ✅ Eliminate
- ✅ Modificate liberamente

## 💡 Esempi d'Uso

### Scenario 1: Creare Categoria di Progetto
```
1. Click su [+]
2. Nome: "Progetto X"
3. Conferma
4. Trascina le app del progetto nella nuova categoria
```

### Scenario 2: Rinominare Categoria
```
Hai "Lavoro" ma vuoi cambiarlo in "Business":
1. Click destro su "Lavoro" 🔵
2. "Rinomina" ✏️
3. Scrivi "Business"
4. Conferma → Tutte le 15 app ora sono in "Business"
```

### Scenario 3: Eliminare Categoria Obsoleta
```
Categoria "Test" non serve più:
1. Click destro su "Test" 🔵
2. "Elimina" 🗑️
3. Alert: "3 elementi verranno spostati in 'Utilità'"
4. Conferma → Categoria rimossa, elementi spostati
```

## 🎨 Dettagli Tecnici

### Implementazione

**CategoryDropRow Context Menu:**
```swift
.contextMenu {
    if category != "Tutte" {
        if appManager.isCustomCategory(category) {
            Button {
                editedName = category
                showEditDialog = true
            } label: {
                Label("Rinomina", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Elimina", systemImage: "trash")
            }
        } else {
            Text("Categoria Predefinita")
                .foregroundColor(.secondary)
        }
    }
}
```

**Badge Personalizzate:**
```swift
if appManager.isCustomCategory(category) {
    Image(systemName: "person.crop.circle.badge.checkmark")
        .font(.caption2)
        .foregroundColor(.blue)
        .help("Categoria personalizzata (modifica con click destro)")
}
```

**Pulsante Rapido Add:**
```swift
Button {
    showAddCategory = true
} label: {
    Image(systemName: "plus.circle.fill")
        .foregroundColor(.blue)
}
.buttonStyle(.plain)
.help("Aggiungi nuova categoria")
```

### Alert di Rinomina
```swift
.alert("Rinomina Categoria", isPresented: $showEditDialog) {
    TextField("Nuovo nome", text: $editedName)
    Button("Annulla", role: .cancel) { }
    Button("Rinomina") {
        if !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            _ = appManager.renameCategory(from: category, to: editedName)
        }
    }
} message: {
    Text("Inserisci il nuovo nome per la categoria '\(category)'")
}
```

### Alert di Eliminazione
```swift
.alert("Elimina Categoria", isPresented: $showDeleteAlert) {
    Button("Annulla", role: .cancel) { }
    Button("Elimina", role: .destructive) {
        _ = appManager.deleteCategory(category)
    }
} message: {
    let itemCount = appManager.countForCategory(category)
    Text("Sei sicuro di voler eliminare '\(category)'? \(itemCount) elementi verranno spostati in 'Utilità'.")
}
```

## 🔍 Stati Visivi

### Categoria Normale
```
📱 Tutte                    12
```

### Categoria Predefinita (Context Menu)
```
⚙️ Sistema                  8
   → "Categoria Predefinita"
```

### Categoria Personalizzata
```
📁 Lavoro 🔵                5
   → "Rinomina" ✏️
   → "Elimina" 🗑️
```

### Categoria Durante Drop
```
📁 Lavoro 🔵                5
   ↑ (evidenziata in blu, scala 1.02x)
```

## 📊 Flusso Operazioni

### Rinomina
```
1. Click destro → "Rinomina"
   ↓
2. Alert con TextField
   ↓
3. Utente inserisce nuovo nome
   ↓
4. appManager.renameCategory(from:to:)
   ↓
5. Aggiorna lista categorie
   ↓
6. Aggiorna tutte le app/weblink
   ↓
7. Salva in UserDefaults
   ↓
8. UI si aggiorna (@Published)
```

### Eliminazione
```
1. Click destro → "Elimina"
   ↓
2. Alert conferma (mostra conteggio elementi)
   ↓
3. Utente conferma
   ↓
4. appManager.deleteCategory(category)
   ↓
5. Rimuove dalla lista categorie
   ↓
6. Sposta tutti elementi in "Utilità"
   ↓
7. Salva modifiche
   ↓
8. UI si aggiorna
```

## 🧪 Testing

### Test 1: Rinomina Categoria
```
1. Crea categoria "Test123"
2. Aggiungi 3 app alla categoria
3. Click destro → "Rinomina"
4. Cambia in "Produzione"
5. Verifica: Le 3 app sono ora in "Produzione"
6. Riavvia app: La categoria è ancora "Produzione"
```

### Test 2: Elimina Categoria
```
1. Crea categoria "Temporanea"
2. Aggiungi 5 weblink
3. Click destro → "Elimina"
4. Conferma alert (dice "5 elementi")
5. Verifica: Categoria sparita, 5 weblink in "Utilità"
```

### Test 3: Protezione Predefinite
```
1. Click destro su "Sistema"
2. Verifica: Solo "Categoria Predefinita" mostrato
3. Nessuna opzione di modifica disponibile
```

### Test 4: Pulsante Rapido
```
1. Click su [+] in sidebar
2. Inserisci "Nuovo Progetto"
3. Conferma
4. Verifica: Categoria creata e selezionata automaticamente
```

## ⚠️ Limitazioni Note

1. **Undo/Redo**: Non ancora implementato
   - Eliminazione permanente
   - Rinomina irreversibile

2. **Validazione Nome**: Limitata
   - Non verifica duplicati durante typing
   - Solo al salvataggio

3. **Batch Operations**: Non supportate
   - Non puoi rinominare/eliminare multiple categorie contemporaneamente

4. **Icona Personalizzata**: Non accessibile dal context menu
   - Devi usare "Gestisci Categorie" per cambiare icona

## 🔮 Miglioramenti Futuri

- [ ] Undo/Redo per operazioni categoria
- [ ] Duplica categoria (crea con stesso nome + " Copia")
- [ ] Merge categorie (unisci due categorie)
- [ ] Statistiche inline (mostra conteggio app vs weblink)
- [ ] Drag & drop per riordinare categorie
- [ ] Keyboard shortcuts (Cmd+N per nuova, Del per eliminare)
- [ ] Color picker per categoria
- [ ] Esporta/Importa configurazione categorie

## 📚 Risorse Correlate

- **CategoryManagementView.swift** - Gestione completa categorie
- **CategoryCreationView.swift** - Form creazione categoria
- **AppManager.swift** - Logica business categorie
- **CategoryIconView.swift** - Rendering icone categorie

## 🎓 Best Practices

### Nomenclatura Categorie
✅ **Buone:**
- "Progetto ABC"
- "Clienti VIP"
- "Dev Tools"

❌ **Da Evitare:**
- "asdf" (non descrittivo)
- "Categoria1", "Categoria2" (generico)
- Nomi troppo lunghi (> 30 caratteri)

### Organizzazione
1. Usa categorie predefinite quando possibile
2. Crea categorie personalizzate solo per esigenze specifiche
3. Mantieni un numero gestibile (< 20 totali)
4. Elimina categorie obsolete regolarmente

## Credits

Sviluppato da **ChimeraDev** (chimeradev.app)  
Funzionalità di gestione categorie rapida dalla sidebar
