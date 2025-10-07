# 🔧 Risoluzione Problemi Rete - AppBoard

## 🐛 Problema Identificato

Il **rilevamento della favicon** e la **generazione descrizione con AI** non funzionavano perché **mancavano i permessi di rete nel file entitlements di release**.

### 📋 Diagnosi

✅ **File entitlements debug** (`AppBoard.entitlements`): aveva già `com.apple.security.network.client`  
❌ **File entitlements release** (`AppBoardRelease.entitlements`): **mancava** `com.apple.security.network.client`

## 🛠️ Soluzione Implementata

### 1. **Aggiunta Permesso di Rete**

Ho aggiunto il permesso mancante al file `AppBoardRelease.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

Questo permette all'app di:
- ✅ Effettuare chiamate HTTP/HTTPS in uscita
- ✅ Scaricare favicon dai siti web
- ✅ Chiamare l'API di OpenAI
- ✅ Connettersi a qualsiasi servizio web esterno

## 📝 Come Testare la Risoluzione

### Step 1: Ricompila l'App
```bash
# Da Xcode, seleziona il build configuration corretto e ricompila
# Oppure da terminale:
cd /Users/gchimera/Developer/AppBoard
xcodebuild -scheme AppBoard -configuration Release
```

### Step 2: Esegui Test di Connettività
```bash
# Esegui il test automatico:
swift test_network_features.swift
```

### Step 3: Testa Nell'App
1. **Apri AppBoard**
2. **Vai in Impostazioni** (⚙️)
3. **Sezione "Intelligenza Artificiale"**
4. **Inserisci chiave API OpenAI** (se hai una)
5. **Clicca "Test"** → Dovrebbe mostrare ✅ "Connessione riuscita!"

### Step 4: Aggiungi un WebLink di Test
1. **Clicca 🔗➕** nell'header
2. **Inserisci URL**: `https://github.com`
3. **Premi Invio**
4. **Risultato Atteso**:
   - ✅ Favicon scaricata
   - ✅ Nome estratto automaticamente
   - ✅ Descrizione AI generata (con badge ✨)

## 🔍 Possibili Problemi Residui

### Problema: "Favicon non si scarica"

**Possibili Cause**:
- App non ricompilata dopo modifica entitlements
- Sito web blocca il download delle favicon
- Problema di connettività

**Soluzioni**:
1. Ricompila completamente l'app
2. Testa con siti diversi (GitHub, YouTube, Google)
3. Verifica connessione internet

### Problema: "Descrizione AI non generata"

**Possibili Cause**:
- Chiave API OpenAI non configurata
- Chiave API non valida o senza credito
- Rate limit API superato

**Soluzioni**:
1. Vai su [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Crea/verifica la chiave API
3. Controlla credito su [platform.openai.com/usage](https://platform.openai.com/usage)
4. Inserisci chiave in AppBoard → Impostazioni → AI

### Problema: "Errore 'server with specified hostname could not be found'"

**Cause**:
- Permessi di rete mancanti (già risolto)
- Firewall macOS che blocca l'app
- VPN che interferisce

**Soluzioni**:
1. **Firewall**: Impostazioni Sistema → Rete → Firewall → Autorizza AppBoard
2. **VPN**: Verifica che permetta connessioni a `api.openai.com` e `*.gstatic.com`

## 📊 Log di Debug

Per debuggare eventuali problemi, controlla i log dell'app:

```bash
# Apri Console.app
open /System/Applications/Utilities/Console.app

# Filtra per "AppBoard" e cerca:
✅ "Descrizione AI generata con successo"
⚠️ "OpenAI API key non configurata"
❌ "Errore API OpenAI (401): Controlla la chiave API"
💡 "Suggerimento: Verifica connessione internet"
```

## 🚀 Verifica Entitlements Applicati

Per verificare che gli entitlements siano stati applicati correttamente:

```bash
# Trova l'app compilata
find ~/Library/Developer/Xcode/DerivedData -name "AppBoard.app" -type d

# Verifica entitlements (sostituisci con il path trovato)
codesign -d --entitlements :- "path/to/AppBoard.app"

# Dovresti vedere:
# <key>com.apple.security.network.client</key>
# <true/>
```

## ✅ Checklist Finale

Prima di considerare il problema risolto:

- [ ] File `AppBoardRelease.entitlements` contiene `com.apple.security.network.client`
- [ ] App ricompilata completamente
- [ ] Test di rete superati (`swift test_network_features.swift`)
- [ ] Test connessione API in-app funzionante
- [ ] Favicon scaricate correttamente per nuovi link
- [ ] Descrizioni AI generate (se chiave API configurata)

## 🎯 Prossimi Miglioramenti

Considerare per il futuro:
- **Retry automatico** con backoff esponenziale per chiamate API
- **Cache locale** delle favicon per evitare ri-download
- **Indicatori di progresso** più chiari durante il download
- **Fallback** più intelligenti quando i servizi sono offline

---

## 📞 Supporto

Se il problema persiste:
1. Verifica tutti i punti della checklist
2. Esegui il test automatico
3. Controlla i log in Console.app
4. Prova con diversi siti web per isolare il problema