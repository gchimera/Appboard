import Foundation

actor AIDescriptionService {
    static let shared = AIDescriptionService()
    
    private init() {}
    
    // API key should be stored in UserDefaults or Keychain
    private var apiKey: String? {
        UserDefaults.standard.string(forKey: "openai_api_key")
    }
    
    /// Generate a description for a website using AI
    /// - Parameters:
    ///   - name: The name of the website
    ///   - url: The URL of the website
    /// - Returns: A generated description or nil if failed
    func generateDescription(for name: String, url: String) async -> String? {
        // Check if API key is available
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            print("⚠️ OpenAI API key non configurata - usando descrizione fallback")
            return generateFallbackDescription(for: name, url: url)
        }
        
        do {
            let description = try await fetchAIDescription(name: name, url: url, apiKey: apiKey)
            print("✅ Descrizione AI generata con successo per: \(name)")
            return description
        } catch let error as AIDescriptionError {
            switch error {
            case .invalidResponse:
                print("❌ Errore: Risposta non valida dall'API OpenAI")
            case .apiError(let statusCode):
                print("❌ Errore API OpenAI (\(statusCode)): Controlla la chiave API e il credito")
            case .noAPIKey:
                print("❌ Nessuna chiave API configurata")
            }
            return generateFallbackDescription(for: name, url: url)
        } catch {
            print("❌ Errore nella generazione descrizione AI: \(error.localizedDescription)")
            print("💡 Suggerimento: Verifica la connessione internet e i permessi di rete dell'app")
            return generateFallbackDescription(for: name, url: url)
        }
    }
    
    private func fetchAIDescription(name: String, url: String, apiKey: String) async throws -> String {
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // 30 seconds timeout
        
        let prompt = """
        Analizza questo sito web e fornisci una breve descrizione (massimo 2-3 frasi) in italiano che spieghi cosa offre il servizio o il sito.
        
        Nome: \(name)
        URL: \(url)
        
        La descrizione deve essere concisa, informativa e utile per un utente che vuole capire rapidamente di cosa si tratta.
        Non includere frasi introduttive come "Questo è" o "Questo sito". Vai diretto al punto.
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "Sei un assistente che genera descrizioni concise e utili per siti web e servizi online in italiano."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIDescriptionError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("OpenAI API error: \(httpResponse.statusCode)")
            if let errorBody = String(data: data, encoding: .utf8) {
                print("Error body: \(errorBody)")
            }
            throw AIDescriptionError.apiError(statusCode: httpResponse.statusCode)
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIDescriptionError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Generate a fallback description based on URL analysis
    private func generateFallbackDescription(for name: String, url: String) -> String {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return "Sito web: \(name)"
        }
        
        let domain = host.replacingOccurrences(of: "www.", with: "")
        let domainParts = domain.components(separatedBy: ".")
        
        // Try to infer type from domain
        if url.contains("github.com") {
            return "Repository e piattaforma di sviluppo collaborativo per progetti open source."
        } else if url.contains("youtube.com") || url.contains("youtu.be") {
            return "Piattaforma di condivisione e streaming video."
        } else if url.contains("twitter.com") || url.contains("x.com") {
            return "Social network per la condivisione di brevi messaggi e aggiornamenti."
        } else if url.contains("linkedin.com") {
            return "Rete professionale per connessioni di lavoro e opportunità di carriera."
        } else if url.contains("instagram.com") {
            return "Piattaforma di condivisione di foto e video social."
        } else if url.contains("facebook.com") {
            return "Social network per connettersi con amici e comunità."
        } else if url.contains("reddit.com") {
            return "Comunità online organizzate per argomenti e discussioni."
        } else if url.contains("medium.com") {
            return "Piattaforma di pubblicazione per articoli e storie."
        } else if url.contains("stackoverflow.com") {
            return "Comunità Q&A per sviluppatori e programmatori."
        } else if url.contains("notion.so") {
            return "Workspace per note, documenti e gestione progetti."
        } else if url.contains("figma.com") {
            return "Strumento di design collaborativo per interfacce e prototipi."
        } else if url.contains("openai.com") {
            return "Azienda di ricerca in intelligenza artificiale e sviluppatore di ChatGPT."
        } else if url.contains("anthropic.com") {
            return "Azienda di ricerca in AI sicura e sviluppatore di Claude."
        } else if url.contains("spotify.com") {
            return "Servizio di streaming musicale e podcast."
        } else if url.contains("netflix.com") {
            return "Servizio di streaming per film, serie TV e contenuti originali."
        } else if url.contains("amazon.com") || url.contains("amazon.it") {
            return "Marketplace online per acquisti e servizi cloud."
        } else if url.contains("apple.com") {
            return "Produttore di dispositivi elettronici e servizi digitali."
        } else if url.contains("google.com") {
            return "Motore di ricerca e servizi online."
        } else if domainParts.count >= 2 {
            let tld = domainParts.last ?? ""
            
            switch tld {
            case "edu":
                return "Risorsa educativa: \(name)"
            case "gov":
                return "Sito governativo: \(name)"
            case "org":
                return "Organizzazione: \(name)"
            case "io":
                return "Servizio tech o startup: \(name)"
            case "app":
                return "Applicazione web: \(name)"
            case "dev":
                return "Risorsa per sviluppatori: \(name)"
            default:
                return "Sito web: \(name)"
            }
        }
        
        return "Sito web: \(name)"
    }
    
    /// Fetch page title and meta description from URL (alternative method)
    func fetchPageMetadata(from urlString: String) async -> (title: String?, description: String?)? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { return nil }
            
            // Extract title
            let title = extractTag(from: html, pattern: "<title>(.*?)</title>")
            
            // Extract meta description
            let description = extractMetaContent(from: html, name: "description") ??
                            extractMetaProperty(from: html, property: "og:description")
            
            return (title, description)
        } catch {
            print("Errore nel fetch metadata: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractTag(from html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, range: range),
              let titleRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        
        return String(html[titleRange])
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    private func extractMetaContent(from html: String, name: String) -> String? {
        let pattern = "<meta\\s+name=[\"']\(name)[\"']\\s+content=[\"'](.*?)[\"']"
        return extractTag(from: html, pattern: pattern)
    }
    
    private func extractMetaProperty(from html: String, property: String) -> String? {
        let pattern = "<meta\\s+property=[\"']\(property)[\"']\\s+content=[\"'](.*?)[\"']"
        return extractTag(from: html, pattern: pattern)
    }
}

enum AIDescriptionError: Error {
    case invalidResponse
    case apiError(statusCode: Int)
    case noAPIKey
}
