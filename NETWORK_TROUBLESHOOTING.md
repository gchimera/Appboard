# Risoluzione Problemi di Rete - AppBoard

## Problema Risolto: "A server with the specified hostname could not be found"

Questo errore si verificava perché l'app non aveva i permessi necessari per effettuare connessioni di rete in uscita.

## Soluzione Implementata

### 1. **Permessi di Rete Aggiunti**
Ho aggiunto l'entitlement `com.apple.security.network.client` al file `AppBoard.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

Questo permette all'app di effettuare connessioni HTTP/HTTPS in uscita, necessarie per:
- Chiamate API a OpenAI
- Download delle favicon
- Fetch dei metadata dei siti web

### 2. **Miglioramenti Implementati**

#### Gestione Errori Avanzata
```swift
✅ Descrizione AI generata con successo
⚠️ OpenAI API key non configurata - usando descrizione fallback
❌ Errore API OpenAI (401): Controlla la chiave API e il credito
💡 Suggerimento: Verifica la connessione internet e i permessi di rete
```

#### Timeout Aumentato
- Timeout richiesta API: **30 secondi** (prima era default)
- Garantisce tempo sufficiente anche con connessioni lente

#### Pulsante Test Connessione
Nelle Impostazioni → Intelligenza Artificiale:
- Nuovo pulsante **"Test"** accanto a "Salva"
- Testa la connessione API senza dover aggiungere un link
- Mostra feedback immediato con toast

## Come Testare

### Test 1: Verifica Permessi di Rete

1. Apri l'app AppBoard
2. Vai in **Impostazioni** (⚙️)
3. Sezione **"Intelligenza Artificiale"**
4. Inserisci una chiave API OpenAI valida
5. Clicca su **"Test"**

**Risultato Atteso**:
- ✅ "Connessione riuscita! API funzionante"

**Se Fallisce**:
- Verifica che la chiave API sia corretta
- Controlla la console Xcode per messaggi dettagliati

### Test 2: Aggiungi un WebLink

1. Clicca su **🔗➕** nell'header
2. Inserisci URL: `https://github.com`
3. Premi **Invio**

**Risultato Atteso**:
- Favicon scaricata ✅
- Descrizione generata con badge sparkles ✨
- Box viola con testo della descrizione

**Se Fallisce**:
- La favicon dovrebbe comunque funzionare (usa `com.apple.security.network.client`)
- La descrizione userà fallback se API non disponibile

### Test 3: Verifica Console

Apri la **Console** di macOS (`Console.app`):
1. Filtra per processo: `AppBoard`
2. Aggiungi un link
3. Cerca questi log:

```
✅ Descrizione AI generata con successo per: GitHub
```

O se fallisce:
```
❌ Errore nella generazione descrizione AI: ...
💡 Suggerimento: Verifica la connessione internet e i permessi di rete dell'app
```

## Verifica Entitlements

Puoi verificare che gli entitlements siano stati applicati correttamente:

```bash
codesign -d --entitlements :- /Users/gchimera/Library/Developer/Xcode/DerivedData/AppBoard-*/Build/Products/Debug/AppBoard.app
```

Dovresti vedere:
```xml
<key>com.apple.security.network.client</key>
<true/>
```

## Possibili Problemi Residui

### 1. **Firewall macOS**
Se hai un firewall attivo:
- Vai in **Impostazioni di Sistema** → **Rete** → **Firewall**
- Assicurati che AppBoard sia autorizzato

### 2. **VPN o Proxy**
Se usi VPN o proxy:
- L'app usa le impostazioni di sistema
- Verifica che la VPN permetta connessioni a `api.openai.com`

### 3. **Credito OpenAI**
Se ricevi errore 429 o 402:
- Verifica il credito su [platform.openai.com/usage](https://platform.openai.com/usage)
- Aggiungi un metodo di pagamento se necessario

### 4. **Rate Limiting**
OpenAI ha limiti di richieste:
- Tier free: ~3 richieste/minuto
- Tier paid: ~60 richieste/minuto
- Se superi, aspetta qualche secondo e riprova

## Debug Avanzato

### Abilitare Log Dettagliati

Modifica `AIDescriptionService.swift` per log più verbosi:

```swift
print("🔍 Attempting API call to: \(endpoint)")
print("📡 Request headers: \(request.allHTTPHeaderFields ?? [:])")
```

### Test da Terminale

Testa la connessione OpenAI dal terminale:

```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

Se questo funziona ma l'app no, il problema è nei permessi dell'app.

## Codici di Stato API

| Codice | Significato | Soluzione |
|--------|-------------|-----------|
| 200 | ✅ OK | Tutto funziona |
| 401 | ❌ Unauthorized | Chiave API non valida |
| 429 | ⚠️ Too Many Requests | Rate limit, aspetta |
| 500 | ❌ Server Error | Problema OpenAI, riprova |
| -1009 | ❌ Network Offline | Connessione internet assente |

## Messaggi di Errore Comuni

### "The Internet connection appears to be offline"
**Causa**: Nessuna connessione internet  
**Soluzione**: Verifica WiFi/Ethernet

### "Could not connect to the server"
**Causa**: Server OpenAI non raggiungibile  
**Soluzione**: Controlla stato su [status.openai.com](https://status.openai.com)

### "The request timed out"
**Causa**: Server lento o connessione instabile  
**Soluzione**: Timeout aumentato a 30s, riprova

### "Certificate trust failed"
**Causa**: Problema SSL/TLS  
**Soluzione**: Aggiorna macOS, verifica data/ora sistema

## Supporto

Se il problema persiste:

1. **Console Log**: Salva i log da Console.app
2. **Network Trace**: Usa Charles Proxy o Wireshark
3. **Entitlements**: Verifica con `codesign -d --entitlements`
4. **Xcode**: Compila da Xcode e guarda Build Log

## Changelog

### Versione Attuale
- ✅ Aggiunto `com.apple.security.network.client`
- ✅ Timeout aumentato a 30 secondi
- ✅ Gestione errori migliorata
- ✅ Pulsante test connessione
- ✅ Log dettagliati con emoji

### Prossimi Miglioramenti
- [ ] Retry automatico con backoff
- [ ] Cache locale delle descrizioni
- [ ] Modalità offline con fallback migliorato
- [ ] Supporto per altri provider AI
