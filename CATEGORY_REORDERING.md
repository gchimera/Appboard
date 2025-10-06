# Riordino Categorie - AppBoard

## 🎯 Funzionalità

Ora puoi **riordinare le categorie** nella sidebar tramite drag & drop! L'unica categoria che rimane fissa è **"Tutte"**, che è sempre visualizzata per prima.

## ✨ Come Funziona

### Drag & Drop nella Sidebar

**Operazione:**
```
1. Click e tieni premuto su una categoria (non "Tutte")
2. Trascina la categoria sopra o sotto altre categorie
3. Rilascia per posizionarla nel nuovo ordine
4. L'ordine viene salvato automaticamente
```

### Protezione "Tutte"

La categoria "Tutte" ha un'icona 📌 (pin) che indica che è **fissa**:
- ❌ Non può essere spostata
- ✅ Rimane sempre in prima posizione
- 📌 Mostra icona "pin.fill" con tooltip

## 🎨 Indicatori Visivi

### Categoria "Tutte" (Fissa)
```
📱 Tutte 📌              25
   ↑ icona pin = non riordinabile
```

### Categoria Normale
```
⚙️ Sistema               8
   ↑ può essere spostata
```

### Categoria Personalizzata
```
📁 Lavoro 🔵             5
   ↑ può essere spostata + badge personalizzato
```

## 💾 Persistenza

**Salvataggio Automatico:**
- L'ordine viene salvato immediatamente dopo ogni spostamento
- Salvato in `UserDefaults` con chiave `"categoryOrder"`
- Persiste tra le sessioni dell'app
- Si mantiene anche dopo riavvio

**Caricamento:**
- All'avvio, l'ordine salvato viene ripristinato
- "Tutte" viene sempre posizionata per prima (anche se salvata altrove)
- Nuove categorie predefinite vengono aggiunte in fondo

## 🔧 Implementazione Tecnica

### AppManager.swift

**Metodo Principal:**
```swift
func moveCategoryItem(from source: IndexSet, to destination: Int) {
    // Protezione: "Tutte" non può essere spostata
    guard let sourceIndex = source.first, sourceIndex != 0 else {
        print("Impossibile spostare la categoria 'Tutte'")
        return
    }
    
    // Impedisce spostamento prima di "Tutte"
    var adjustedDestination = destination
    if adjustedDestination == 0 {
        adjustedDestination = 1
    }
    
    // Riordina array manualmente
    var newCategories = categories
    let movedItems = source.map { categories[$0] }
    
    for index in source.sorted(by: >) {
        newCategories.remove(at: index)
    }
    
    var insertIndex = adjustedDestination
    if sourceIndex < adjustedDestination {
        insertIndex -= source.count
    }
    
    for (offset, item) in movedItems.enumerated() {
        newCategories.insert(item, at: insertIndex + offset)
    }
    
    categories = newCategories
    saveCategoryOrder()
}
```

**Salvataggio:**
```swift
private func saveCategoryOrder() {
    UserDefaults.standard.set(categories, forKey: "categoryOrder")
    print("Ordine categorie salvato: \(categories)")
}
```

**Caricamento:**
```swift
private func loadCategoryOrder() {
    if let savedOrder = UserDefaults.standard.array(forKey: "categoryOrder") as? [String] {
        // Filtra "Tutte" e la reinserisce all'inizio
        var orderedCategories = savedOrder.filter { $0 != "Tutte" }
        orderedCategories.insert("Tutte", at: 0)
        
        // Aggiungi nuove categorie predefinite non presenti
        for defaultCategory in defaultCategories {
            if !orderedCategories.contains(defaultCategory) {
                orderedCategories.append(defaultCategory)
            }
        }
        
        categories = orderedCategories
    }
}
```

### ContentView.swift

**Lista con ForEach e onMove:**
```swift
List {
    ForEach(appManager.categories, id: \.self) { category in
        CategoryDropRow(
            category: category,
            appManager: appManager,
            isSelected: category == selectedCategory,
            onSelect: { selectedCategory = category }
        )
    }
    .onMove { source, destination in
        appManager.moveCategoryItem(from: source, to: destination)
    }
}
.listStyle(SidebarListStyle())
```

**Badge Indicatore:**
```swift
// Indicatore per categoria "Tutte" (non riordinabile)
if category == "Tutte" {
    Image(systemName: "pin.fill")
        .font(.caption2)
        .foregroundColor(.secondary)
        .help("Categoria fissa (non riordinabile)")
}
```

## 📝 Esempi d'Uso

### Esempio 1: Porta "Sviluppo" in seconda posizione
```
Stato iniziale:
1. Tutte 📌
2. Sistema
3. Produttività
4. Sviluppo  ← voglio spostare qui in su

Azione:
- Trascina "Sviluppo" sopra "Sistema"

Risultato:
1. Tutte 📌
2. Sviluppo  ✅
3. Sistema
4. Produttività
```

### Esempio 2: Raggruppare categorie correlate
```
Voglio mettere tutte le categorie creative insieme:

Prima:
1. Tutte 📌
2. Sistema
3. Produttività
4. Creatività
5. Sviluppo
6. Multimedia

Dopo (trascino Multimedia sotto Creatività):
1. Tutte 📌
2. Sistema
3. Produttività
4. Creatività
5. Multimedia  ✅
6. Sviluppo
```

### Esempio 3: Tentativo di spostare "Tutte"
```
Azione: Provo a trascinare "Tutte"
Risultato: ❌ Niente succede (categoria protetta)
Log console: "Impossibile spostare la categoria 'Tutte'"
```

## 🧪 Testing

### Test 1: Riordino Normale
```
1. Trascina "Giochi" dalla posizione 6 alla posizione 2
2. Verifica: "Giochi" ora è in posizione 2
3. Riavvia app
4. Verifica: "Giochi" ancora in posizione 2 ✅
```

### Test 2: Protezione "Tutte"
```
1. Prova a trascinare "Tutte"
2. Verifica: Non si sposta ❌
3. Controlla console: "Impossibile spostare la categoria 'Tutte'"
```

### Test 3: Impedisci Spostamento Prima di "Tutte"
```
1. Trascina "Sistema" nella posizione 0 (prima di "Tutte")
2. Verifica: "Sistema" va in posizione 1 (dopo "Tutte") ✅
```

### Test 4: Nuove Categorie
```
1. Riordina categorie esistenti
2. Aggiungi nuova categoria personalizzata
3. Verifica: Nuova categoria appare in fondo
4. Riordina nuova categoria come desideri ✅
```

### Test 5: Persistenza
```
1. Riordina varie categorie
2. Chiudi app
3. Apri app
4. Verifica: Ordine mantenuto ✅
5. Aggiungi/Elimina categoria
6. Verifica: Ordine delle altre categorie intatto ✅
```

## 🔄 Integrazione con Altre Funzioni

### Con Aggiunta Categoria
```
Quando aggiungi una nuova categoria:
- Appare in fondo alla lista
- Puoi subito riordinarla trascinandola
- Ordine viene salvato automaticamente
```

### Con Rinomina
```
Quando rinomini una categoria:
- Mantiene la sua posizione
- Ordine viene ri-salvato
- Nessun cambiamento nella posizione
```

### Con Eliminazione
```
Quando elimini una categoria:
- Viene rimossa dall'ordine
- Altre categorie mantengono le loro posizioni relative
- Ordine aggiornato viene salvato
```

## ⚙️ Opzioni di Inizializzazione

**Prima Esecuzione (nessun ordine salvato):**
```
Ordine default:
1. Tutte
2. Sistema
3. Produttività
4. Creatività
... (ordine predefinito)
```

**Con Ordine Salvato:**
```
Carica ordine da UserDefaults
Garantisce "Tutte" sempre in posizione 0
Aggiunge eventuali nuove categorie predefinite in fondo
```

## 💡 Casi d'Uso

### 1. Priorità Personale
```
Metti le categorie che usi di più in cima:
1. Tutte 📌
2. Sviluppo     ← uso molto
3. Produttività ← uso molto
4. Sistema      ← uso poco (spostato più giù)
```

### 2. Raggruppamento Logico
```
Raggruppa categorie simili:
1. Tutte 📌
2. Sviluppo
3. Sistema
4. Utilità
--- (tool tecniche)
5. Social
6. Comunicazione
--- (comunicazione)
7. Multimedia
8. Creatività
--- (media)
```

### 3. Alfabetico Personalizzato
```
Riordina alfabeticamente (escluso Tutte):
1. Tutte 📌
2. Comunicazione
3. Creatività
4. Educazione
5. Finanza
... (alfabetico)
```

## ⚠️ Limitazioni

1. **"Tutte" Sempre Prima**: Non può essere spostata o rimossa dalla prima posizione
2. **Singolo Spostamento**: Puoi spostare una categoria alla volta (no selezione multipla)
3. **No Undo**: Lo spostamento è permanente (fino al prossimo spostamento)

## 🎓 Best Practices

### ✅ Consigliato
1. **Ordine Frequenza**: Metti le categorie più usate in alto
2. **Raggruppamento**: Raggruppa categorie correlate vicine
3. **Consistenza**: Mantieni un ordine logico e prevedibile

### ❌ Da Evitare
1. Non riordinare troppo frequentemente (crea confusione)
2. Non mettere categorie importanti troppo in basso
3. Non ignorare la posizione fissa di "Tutte"

## 🔮 Miglioramenti Futuri

- [ ] Preset di ordinamento (alfabetico, per frequenza uso, etc.)
- [ ] Reset ordine a default con un click
- [ ] Ordinamento automatico basato su statistiche d'uso
- [ ] Sezioni/Gruppi di categorie visive
- [ ] Drag indicator visivo durante lo spostamento
- [ ] Animazioni smooth per il riordino
- [ ] Export/Import configurazione ordine

## 📊 Tabella Riepilogativa

| Categoria | Riordinabile | Pin | Badge |
|-----------|--------------|-----|-------|
| Tutte | ❌ No | 📌 Sì | - |
| Sistema | ✅ Sì | - | - |
| Produttività | ✅ Sì | - | - |
| *Predefinite* | ✅ Sì | - | - |
| Personalizzate | ✅ Sì | - | 🔵 Sì |

## 📚 File Modificati

1. **AppManager.swift**
   - `moveCategoryItem()` - Gestisce lo spostamento
   - `saveCategoryOrder()` - Salva l'ordine
   - `loadCategoryOrder()` - Carica l'ordine
   - Updated `init()` - Chiama `loadCategoryOrder()`
   - Updated add/rename/delete - Salvano ordine

2. **ContentView.swift**
   - Lista con `ForEach` invece di `List(items)`
   - Aggiunto `.onMove` callback
   - Badge pin per "Tutte"

## 🎉 Risultato

Ora hai **completo controllo** sull'ordine delle categorie! Organizza la sidebar come preferisci per massimizzare la tua produttività.

**L'unica limitazione: "Tutte" rimane sempre in cima come punto di riferimento fisso.**

## Credits

Sviluppato da **ChimeraDev** (chimeradev.app)  
Funzionalità di riordino categorie con drag & drop
