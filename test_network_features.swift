#!/usr/bin/env swift

import Foundation
import Network

print("🔍 Test delle funzionalità di rete - AppBoard")
print("============================================\n")

// Test 1: Connessione base a Internet
print("1. 🌐 Test connessione internet...")
let monitor = NWPathMonitor()
let queue = DispatchQueue(label: "NetworkMonitor")
monitor.start(queue: queue)

let semaphore1 = DispatchSemaphore(value: 0)
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        print("   ✅ Connessione internet attiva")
    } else {
        print("   ❌ Nessuna connessione internet")
    }
    monitor.cancel()
    semaphore1.signal()
}
semaphore1.wait()

// Test 2: Risoluzione DNS
print("\n2. 🔍 Test risoluzione DNS...")
let host = NWEndpoint.Host("api.openai.com")
let port = NWEndpoint.Port(443)!

let connection = NWConnection(host: host, port: port, using: .tcp)
connection.start(queue: queue)

let semaphore2 = DispatchSemaphore(value: 0)
connection.stateUpdateHandler = { state in
    switch state {
    case .ready:
        print("   ✅ DNS risolto e connessione TCP stabilita")
        connection.cancel()
        semaphore2.signal()
    case .failed(let error):
        print("   ❌ Errore connessione: \(error)")
        connection.cancel()
        semaphore2.signal()
    default:
        break
    }
}

// Timeout di 5 secondi
DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
    print("   ⏱️ Timeout connessione")
    connection.cancel()
    semaphore2.signal()
}

semaphore2.wait()

// Test 3: Chiamata HTTP semplice
print("\n3. 📡 Test chiamata HTTP...")
let url = URL(string: "https://www.google.com/s2/favicons?domain=github.com&sz=32")!
let semaphore3 = DispatchSemaphore(value: 0)

let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("   ❌ Errore HTTP: \(error.localizedDescription)")
    } else if let httpResponse = response as? HTTPURLResponse {
        print("   ✅ Risposta HTTP: \(httpResponse.statusCode)")
        if let data = data {
            print("   📊 Dati ricevuti: \(data.count) bytes")
        }
    }
    semaphore3.signal()
}
task.resume()
semaphore3.wait()

// Test 4: Test API OpenAI (senza chiave valida)
print("\n4. 🤖 Test endpoint OpenAI...")
let openaiURL = URL(string: "https://api.openai.com/v1/models")!
var request = URLRequest(url: openaiURL)
request.addValue("Bearer test-invalid", forHTTPHeaderField: "Authorization")

let semaphore4 = DispatchSemaphore(value: 0)
let task2 = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
        print("   ❌ Errore OpenAI: \(error.localizedDescription)")
    } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 401 {
            print("   ✅ Endpoint OpenAI raggiungibile (401 Unauthorized è atteso)")
        } else {
            print("   ✅ Risposta OpenAI: \(httpResponse.statusCode)")
        }
    }
    semaphore4.signal()
}
task2.resume()
semaphore4.wait()

print("\n🎉 Test completati!")
print("\n📝 Suggerimenti per risolvere i problemi:")
print("   • Assicurati che AppBoard sia stato ricompilato dopo le modifiche agli entitlements")
print("   • Verifica che la chiave API OpenAI sia configurata correttamente nelle impostazioni")
print("   • Controlla la connessione internet")
print("   • Se usi una VPN, verifica che permetta le connessioni alle API")

exit(0)