# Riordino Categorie con Frecce ↑↓

## 🎯 Funzionalità Implementata

Ho sostituito il drag & drop poco intuitivo con un sistema di **riordino tramite frecce** che si attiva/disattiva con un bottone dedicato.

## ✨ Come Funziona

### 1️⃣ Attivazione Modalità Riordino

**Posizione**: Nella sidebar "Categorie", accanto al titolo  
**Bottone**: 
- 🔄 Icona `arrow.up.arrow.down.circle` quando **disattivata**
- ✅ Icona `checkmark.circle.fill` (verde) quando **attiva**
- **Tooltip**: "Riordina categorie" / "Termina riordino"

### 2️⃣ Comportamento in Modalità Normale (default)

```
📱 Tutte 📌              25
⚙️ Sistema               8
📁 Produttività         12
🎨 Creatività            5
```

- Click su categoria = seleziona categoria
- Mostra contatore elementi sulla destra
- Nessuna freccia visibile

### 3️⃣ Comportamento in Modalità Riordino (attiva)

```
   ↑
   ↓  📱 Tutte 📌
   
   ↑
   ↓  ⚙️ Sistema
   
   ↑
   ↓  📁 Produttività
   
   ↑
   ↓  🎨 Creatività
```

- **Frecce visibili** a sinistra di ogni categoria
- **Freccia ↑**: Sposta categoria in su
- **Freccia ↓**: Sposta categoria in giù
- **Contatori nascosti** per dare più spazio
- **Click su categoria disabilitato** (evita selezioni accidentali)
- **Frecce disabilitate** quando non utilizzabili (grigie)

### 4️⃣ Protezione Categoria "Tutte"

La categoria **"Tutte"** rimane sempre **fissa** in prima posizione:

- ❌ Freccia ↑ sempre disabilitata (è già in cima)
- ❌ Freccia ↓ sempre disabilitata (non può muoversi)
- 📌 Mostra icona "pin" per indicare che è fissa
- ✅ Rimane sempre visibile in posizione 0

## 🎨 Indicatori Visivi

### Frecce Attive (Blu)
```swift
Image(systemName: "chevron.up")
    .foregroundColor(.blue)
```
- **Colore**: Blu (cliccabili)
- **Tooltip**: "Sposta su" / "Sposta giù"

### Frecce Disabilitate (Grigie)
```swift
Image(systemName: "chevron.up")
    .foregroundColor(.gray.opacity(0.3))
```
- **Colore**: Grigio trasparente (non cliccabili)
- **Tooltip**: "Impossibile spostare"

### Bottone Toggle Modalità

**Disattivata**:
```
🔄 (blu)
```

**Attiva**:
```
✅ (verde)
```

## 🔧 Implementazione Tecnica

### ContentView.swift

**Nuovo State Variable**:
```swift
@State private var isCategoryReorderMode = false
```

**Bottone Toggle**:
```swift
Button {
    isCategoryReorderMode.toggle()
} label: {
    Image(systemName: isCategoryReorderMode ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
        .foregroundColor(isCategoryReorderMode ? .green : .blue)
}
.help(isCategoryReorderMode ? "Termina riordino" : "Riordina categorie")
```

**ForEach con Parametri Aggiuntivi**:
```swift
ForEach(Array(appManager.categories.enumerated()), id: \.element) { index, category in
    CategoryDropRow(
        category: category,
        appManager: appManager,
        isSelected: category == selectedCategory,
        isReorderMode: isCategoryReorderMode,
        categoryIndex: index,
        totalCategories: appManager.categories.count,
        onSelect: { selectedCategory = category },
        onMoveUp: {
            appManager.moveCategoryUp(at: index)
        },
        onMoveDown: {
            appManager.moveCategoryDown(at: index)
        }
    )
}
```

**Rimozione drag & drop**:
- ❌ Rimosso `.onMove` modifier
- ❌ Rimosso metodo `moveCategoryItem(from:to:)` usage
- ✅ Mantenuto drag & drop per app verso categorie

### CategoryDropRow.swift

**Nuovi Parametri**:
```swift
let isReorderMode: Bool
let categoryIndex: Int
let totalCategories: Int
var onMoveUp: (() -> Void)? = nil
var onMoveDown: (() -> Void)? = nil
```

**Computed Properties**:
```swift
private var canMoveUp: Bool {
    guard category != "Tutte" else { return false }
    return categoryIndex > 1
}

private var canMoveDown: Bool {
    guard category != "Tutte" else { return false }
    return categoryIndex < totalCategories - 1
}
```

**Rendering Frecce**:
```swift
if isReorderMode {
    VStack(spacing: 2) {
        Button {
            onMoveUp?()
        } label: {
            Image(systemName: "chevron.up")
                .font(.caption2)
                .foregroundColor(canMoveUp ? .blue : .gray.opacity(0.3))
        }
        .buttonStyle(.plain)
        .disabled(!canMoveUp)
        .help(canMoveUp ? "Sposta su" : "Impossibile spostare")
        
        Button {
            onMoveDown?()
        } label: {
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(canMoveDown ? .blue : .gray.opacity(0.3))
        }
        .buttonStyle(.plain)
        .disabled(!canMoveDown)
        .help(canMoveDown ? "Sposta giù" : "Impossibile spostare")
    }
    .frame(width: 20)
}
```

**Click Disabilitato in Modalità Riordino**:
```swift
.onTapGesture {
    if !isReorderMode {
        onSelect?()
    }
}
```

### AppManager.swift

**Nuovi Metodi**:

```swift
// Sposta categoria in su di una posizione
func moveCategoryUp(at index: Int) {
    guard index > 1 && index < categories.count else {
        print("Impossibile spostare categoria: indice non valido o categoria 'Tutte'")
        return
    }
    
    categories.swapAt(index, index - 1)
    saveCategoryOrder()
    print("Categoria \(categories[index]) spostata in su")
}

// Sposta categoria in giù di una posizione
func moveCategoryDown(at index: Int) {
    guard index >= 1 && index < categories.count - 1 else {
        print("Impossibile spostare categoria: indice non valido o categoria 'Tutte'")
        return
    }
    
    categories.swapAt(index, index + 1)
    saveCategoryOrder()
    print("Categoria \(categories[index]) spostata in giù")
}
```

**Caratteristiche**:
- ✅ Usa `swapAt` per scambiare posizioni (più semplice e affidabile)
- ✅ Salva automaticamente l'ordine dopo ogni spostamento
- ✅ Verifica indici validi e protezione "Tutte"
- ✅ Log console per debug

## 📝 Esempi d'Uso

### Esempio 1: Spostare "Sviluppo" in seconda posizione

**Stato iniziale**:
```
1. Tutte 📌
2. Sistema
3. Produttività
4. Sviluppo  ← voglio spostarlo in su
```

**Azione**:
1. Click su bottone 🔄 (attiva modalità riordino)
2. Frecce appaiono accanto a ogni categoria
3. Click su ↑ accanto a "Sviluppo" (2 volte)

**Risultato**:
```
1. Tutte 📌
2. Sviluppo  ✅
3. Sistema
4. Produttività
```

### Esempio 2: Spostare "Giochi" in fondo

**Stato iniziale**:
```
1. Tutte 📌
2. Sistema
3. Giochi  ← voglio spostarlo in fondo
4. Produttività
5. Creatività
```

**Azione**:
1. Modalità riordino attiva
2. Click su ↓ accanto a "Giochi" (3 volte)

**Risultato**:
```
1. Tutte 📌
2. Sistema
3. Produttività
4. Creatività
5. Giochi  ✅
```

### Esempio 3: Tentare di spostare "Tutte"

**Azione**: 
- Modalità riordino attiva
- Frecce ↑↓ accanto a "Tutte" sono **grigie** (disabilitate)
- Click non fa nulla

**Risultato**: 
- ❌ Nessun movimento
- "Tutte" rimane in posizione 1

## ✅ Vantaggi Rispetto al Drag & Drop

| Aspetto | Drag & Drop | Frecce ↑↓ |
|---------|-------------|-----------|
| **Intuitività** | ⚠️ Poco chiaro | ✅ Molto intuitivo |
| **Precisione** | ❌ Difficile posizionare | ✅ Controllo preciso |
| **Feedback visivo** | ⚠️ Limitato | ✅ Frecce mostrano direzione |
| **Accessibilità** | ❌ Difficile con trackpad | ✅ Semplice click |
| **Errori accidentali** | ⚠️ Facili da fare | ✅ Difficili (modalità dedicata) |
| **Mobile/Touch** | ⚠️ Ok ma confuso | ✅ Ottimo |
| **Attivazione** | 🔄 Sempre attivo | ✅ On-demand (meno confusione) |

## 🧪 Test Eseguiti

### ✅ Test 1: Spostamento Normale
```
1. Attiva modalità riordino
2. Sposta "Sistema" in giù (2 posizioni)
3. Verifica: "Sistema" ora è in posizione corretta
4. Disattiva modalità riordino
5. Verifica: Ordine mantenuto ✅
```

### ✅ Test 2: Protezione "Tutte"
```
1. Attiva modalità riordino
2. Verifica: Frecce ↑↓ di "Tutte" sono grigie
3. Click su frecce di "Tutte"
4. Verifica: Nessun movimento ✅
```

### ✅ Test 3: Frecce Disabilitate ai Limiti
```
1. Attiva modalità riordino
2. Verifica seconda categoria: freccia ↑ grigia (dopo "Tutte")
3. Verifica ultima categoria: freccia ↓ grigia (fine lista)
4. Click su frecce disabilitate
5. Verifica: Nessun movimento ✅
```

### ✅ Test 4: Persistenza
```
1. Riordina categorie con frecce
2. Chiudi app
3. Riapri app
4. Verifica: Ordine mantenuto ✅
```

### ✅ Test 5: Modalità Toggle
```
1. Modalità riordino disattivata (default)
2. Click su categoria = selezione funziona
3. Frecce non visibili
4. Attiva modalità riordino
5. Click su categoria = non fa nulla (protetto)
6. Frecce visibili ✅
```

## 🔄 Modifiche Rispetto a Versione Precedente

### ❌ Rimosso

1. **Pulsante "+" nelle categorie**:
   - Rimosso completamente
   - Era poco utilizzato e confuso
   - Sheet per aggiungere categoria rimossa da lì

2. **Drag & Drop per riordinare categorie**:
   - Rimosso `.onMove` modifier
   - Non più possibile trascinare categorie
   - ✅ Mantenuto drag & drop app→categorie

### ✅ Aggiunto

1. **Bottone Toggle Modalità Riordino**:
   - Posizione: Header "Categorie"
   - Icone: 🔄 / ✅
   - Tooltip descrittivi

2. **Frecce ↑↓ per Riordino**:
   - Visibili solo in modalità riordino
   - Disabilitate quando non utilizzabili
   - Feedback visivo chiaro

3. **Metodi AppManager**:
   - `moveCategoryUp(at:)`
   - `moveCategoryDown(at:)`
   - Più semplici e affidabili del vecchio `moveCategoryItem`

## 💡 Best Practices

### ✅ Consigliato

1. **Attiva modalità riordino solo quando serve**:
   - Evita confusione con selezione categorie
   - Modalità dedicata = più sicuro

2. **Riordina categorie in batch**:
   - Attiva modalità una volta
   - Riordina tutte le categorie che vuoi
   - Disattiva modalità quando finito

3. **Usa frecce per piccoli spostamenti**:
   - Perfetto per aggiustamenti 1-2 posizioni
   - Più intuitivo del drag & drop

### ❌ Da Evitare

1. Non lasciare modalità riordino sempre attiva
2. Non aspettarti di poter cliccare su categorie in modalità riordino
3. Non tentare di spostare "Tutte" (è protetta)

## 🎉 Risultato Finale

Ora hai un sistema di **riordino categorie super intuitivo**:

✅ **Controllo preciso** con frecce ↑↓  
✅ **Modalità dedicata** per evitare errori accidentali  
✅ **Feedback visivo chiaro** con frecce disabilitate quando necessario  
✅ **Protezione "Tutte"** sempre in prima posizione  
✅ **Persistenza automatica** dell'ordine  
✅ **Zero confusione** tra riordino e selezione  

**L'esperienza utente è molto più chiara e user-friendly!** 🚀

## 📚 File Modificati

1. **ContentView.swift**
   - Aggiunto `@State private var isCategoryReorderMode`
   - Sostituito pulsante "+" con toggle riordino
   - Rimosso `.onMove` modifier
   - Aggiunto parametri a `CategoryDropRow`
   - Aggiunto callbacks `onMoveUp` e `onMoveDown`

2. **AppManager.swift**
   - Aggiunto `moveCategoryUp(at:)`
   - Aggiunto `moveCategoryDown(at:)`
   - Mantenuto `moveCategoryItem(from:to:)` (non usato ma disponibile)

3. **CategoryDropRow (in ContentView.swift)**
   - Nuovi parametri: `isReorderMode`, `categoryIndex`, `totalCategories`
   - Nuove callbacks: `onMoveUp`, `onMoveDown`
   - Computed properties: `canMoveUp`, `canMoveDown`
   - Rendering condizionale frecce
   - Click disabilitato in modalità riordino

## Credits

Sviluppato da **ChimeraDev** (chimeradev.app)  
Riordino categorie con frecce ↑↓ - Versione 2.0
