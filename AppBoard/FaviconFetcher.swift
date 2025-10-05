import Foundation
import AppKit

actor FaviconFetcher {
    static let shared = FaviconFetcher()
    
    private init() {}
    
    func fetchFavicon(for urlString: String) async -> Data? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        
        // Try multiple favicon sources
        let faviconURLs = [
            // Google's favicon service (most reliable)
            "https://www.google.com/s2/favicons?domain=\(host)&sz=64",
            // Direct favicon.ico
            "https://\(host)/favicon.ico",
            // Apple touch icon
            "https://\(host)/apple-touch-icon.png"
        ]
        
        for faviconURLString in faviconURLs {
            if let faviconURL = URL(string: faviconURLString),
               let data = try? await fetchData(from: faviconURL),
               data.count > 100, // Ensure it's not an error page
               NSImage(data: data) != nil { // Ensure it's a valid image
                return data
            }
        }
        
        return nil
    }
    
    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func fetchFaviconWithRetry(for urlString: String, maxRetries: Int = 2) async -> Data? {
        for attempt in 0..<maxRetries {
            if let data = await fetchFavicon(for: urlString) {
                return data
            }
            // Wait a bit before retrying
            if attempt < maxRetries - 1 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
        }
        return nil
    }
}
