# WebLink con Descrizioni AI

## Panoramica

AppBoard ora supporta l'aggiunta di collegamenti web (WebLinks) con descrizioni generate automaticamente tramite intelligenza artificiale. Questa funzionalità utilizza l'API di OpenAI per analizzare i siti web e creare descrizioni concise e informative in italiano.

## Funzionalità Principali

### 1. **Aggiunta di Collegamenti Web**
- Clicca sull'icona **"Aggiungi Sito Web"** (🔗➕) nella barra degli strumenti
- Inserisci l'URL del sito
- Premi **Invio** per:
  - Scaricare automaticamente la favicon
  - Generare una descrizione AI del sito
  - Estrarre il nome dal dominio (se vuoto)

### 2. **Descrizioni AI**
Le descrizioni vengono generate in due modi:

#### Con Chiave API OpenAI
Se hai configurato una chiave API OpenAI:
- Descrizione personalizzata generata da GPT-4o-mini
- Analisi intelligente del sito basata su nome e URL
- Descrizioni concise (2-3 frasi) in italiano
- Aggiornamenti in tempo reale

#### Senza Chiave API (Fallback)
Se non hai configurato la chiave API:
- Descrizioni predefinite per siti popolari (GitHub, YouTube, etc.)
- Analisi euristica basata sul dominio (.edu, .gov, .org, etc.)
- Comunque funzionale, ma meno personalizzato

### 3. **Gestione Collegamenti**
- **Visualizzazione**: I WebLink appaiono nella griglia con un badge blu "🔗"
- **Apertura**: Click singolo per aprire nel browser
- **Dettagli**: Doppio click per vedere e modificare i dettagli
- **Menu contestuale**:
  - Apri nel browser
  - Copia URL
  - Mostra dettagli
  - Elimina

### 4. **Modifica e Rigenerazione**
Nella finestra dei dettagli (modalità modifica):
- Modifica nome, URL, categoria
- Modifica manualmente la descrizione
- Pulsante **"Rigenera con AI"** per creare una nuova descrizione

## Configurazione

### Ottenere una Chiave API OpenAI

1. Vai su [platform.openai.com](https://platform.openai.com/api-keys)
2. Crea un account o accedi
3. Vai nella sezione "API Keys"
4. Clicca su "Create new secret key"
5. Copia la chiave (inizia con `sk-...`)

### Configurare la Chiave in AppBoard

1. Apri le **Impostazioni** (⚙️)
2. Vai alla sezione **"Intelligenza Artificiale"**
3. Incolla la chiave API nel campo
4. Clicca su **"Salva"**

**Nota**: La chiave viene salvata in modo sicuro in UserDefaults locale.

## Costi API

Il servizio utilizza il modello `gpt-4o-mini` che è:
- Molto economico (~$0.00015 per richiesta)
- Veloce (risponde in 1-2 secondi)
- Efficiente per descrizioni brevi

**Esempio di costi**:
- 100 descrizioni ≈ $0.015 USD
- 1000 descrizioni ≈ $0.15 USD

## Esempi di Descrizioni Generate

### Con AI (OpenAI)
**GitHub** (github.com):
> "Piattaforma di hosting per progetti software che utilizza il controllo di versione Git. Offre funzionalità di collaborazione per sviluppatori, inclusi issue tracking, pull requests e gestione di repository open source e privati."

### Fallback (senza API)
**GitHub** (github.com):
> "Repository e piattaforma di sviluppo collaborativo per progetti open source."

## Struttura Tecnica

### File Principali
- **`WebLink.swift`**: Modello dati con supporto per descrizioni
- **`AIDescriptionService.swift`**: Servizio per generare descrizioni AI
- **`AddWebLinkView.swift`**: UI per aggiungere nuovi link
- **`WebLinkDetailView.swift`**: UI per visualizzare/modificare dettagli
- **`WebLinkGridItem.swift`**: Componente griglia per visualizzare link
- **`Settings.swift`**: Configurazione chiave API

### Flusso di Generazione Descrizione

```swift
1. Utente inserisce URL
2. Sistema chiama AIDescriptionService.generateDescription()
3. Se API key presente:
   - Chiamata a OpenAI API
   - Parsing risposta JSON
   - Estrazione descrizione
4. Se API key assente o errore:
   - Fallback a generateFallbackDescription()
   - Analisi euristica URL
5. Descrizione salvata nel WebLink
```

## Privacy e Sicurezza

- ✅ La chiave API è salvata localmente sul tuo Mac
- ✅ Nessun dato viene condiviso tranne con OpenAI quando usi l'API
- ✅ Puoi usare la funzionalità anche senza API (modalità fallback)
- ✅ Le descrizioni sono generate on-demand, non automaticamente in background

## Troubleshooting

### La descrizione non viene generata
- Verifica che la chiave API sia configurata correttamente
- Controlla la console per eventuali errori API
- Assicurati di avere credito nel tuo account OpenAI

### Errore 401 (Unauthorized)
- Chiave API non valida o scaduta
- Rigenera una nuova chiave da platform.openai.com

### Errore 429 (Rate Limit)
- Hai superato il limite di richieste
- Attendi qualche minuto prima di riprovare
- Considera l'upgrade del piano OpenAI

### Le descrizioni sono in inglese invece che in italiano
- Questo non dovrebbe accadere, il prompt specifica italiano
- Se succede, contatta il supporto o rigenera la descrizione

## Prossimi Sviluppi

Funzionalità pianificate:
- [ ] Supporto per altri provider AI (Anthropic Claude, Gemini)
- [ ] Cache locale delle descrizioni per ridurre costi
- [ ] Batch generation per più link contemporaneamente
- [ ] Personalizzazione del prompt AI
- [ ] Screenshot automatico del sito
- [ ] Estrazione di tag/keywords automatica
- [ ] Sync descrizioni con iCloud

## Credits

Sviluppato da **ChimeraDev** (chimeradev.app)  
Utilizza OpenAI GPT-4o-mini per la generazione delle descrizioni
