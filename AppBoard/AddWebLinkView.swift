import SwiftUI

struct AddWebLinkView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var selectedCategory: String?
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var faviconPreview: NSImage?
    @State private var generatedDescription: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("add_website_title".localized())
                .font(.title2)
                .fontWeight(.semibold)
            
            // Favicon preview
            if let favicon = faviconPreview {
                Image(nsImage: favicon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } else {
                Image(systemName: "globe")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                    .frame(width: 64, height: 64)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // URL field
                VStack(alignment: .leading, spacing: 6) {
                    Text("url".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("url_placeholder".localized(), text: $url)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            fetchMetadata()
                        }
                }
                
                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("name".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("website_name_placeholder".localized(), text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Category picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("category".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("category".localized(), selection: $selectedCategory) {
                        Text("none".localized()).tag(nil as String?)
                        ForEach(appManager.categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Description (if generated)
                if let description = generatedDescription {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("description".localized())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(8)
                            .background(Color.purple.opacity(0.05))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.horizontal)
            
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Buttons
            HStack(spacing: 12) {
                Button("cancel".localized()) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("add".localized()) {
                    addWebLink()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(url.isEmpty || name.isEmpty || isLoading)
            }
            .padding(.bottom)
        }
        .frame(width: 400, height: 450)
        .padding()
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.windowBackgroundColor))
                        )
                }
            }
        }
    }
    
    private func fetchMetadata() {
        guard !url.isEmpty else { return }
        
        // Auto-add https:// if missing
        var urlToFetch = url
        if !urlToFetch.hasPrefix("http://") && !urlToFetch.hasPrefix("https://") {
            urlToFetch = "https://" + urlToFetch
            url = urlToFetch
        }
        
        // Try to extract name from URL if empty
        if name.isEmpty, let host = URL(string: urlToFetch)?.host {
            let cleanHost = host.replacingOccurrences(of: "www.", with: "")
            name = cleanHost.components(separatedBy: ".").first?.capitalized ?? cleanHost
        }
        
        isLoading = true
        Task {
            // Fetch favicon
            async let faviconData = FaviconFetcher.shared.fetchFaviconWithRetry(for: urlToFetch)
            
            // Generate AI description
            async let description = AIDescriptionService.shared.generateDescription(for: name, url: urlToFetch)
            
            // Wait for both to complete
            let (favicon, aiDescription) = await (faviconData, description)
            
            await MainActor.run {
                if let favicon = favicon {
                    faviconPreview = NSImage(data: favicon)
                }
                generatedDescription = aiDescription
                isLoading = false
            }
        }
    }
    
    private func addWebLink() {
        guard !url.isEmpty, !name.isEmpty else { return }
        
        isLoading = true
        showError = false
        
        Task {
            var finalURL = url
            if !finalURL.hasPrefix("http://") && !finalURL.hasPrefix("https://") {
                finalURL = "https://" + finalURL
            }
            
            // Validate URL
            guard URL(string: finalURL) != nil else {
                await MainActor.run {
                    errorMessage = "invalid_url".localized()
                    showError = true
                    isLoading = false
                }
                return
            }
            
            // Fetch favicon if we don't have it yet
            var faviconData: Data?
            if faviconPreview == nil {
                faviconData = await FaviconFetcher.shared.fetchFaviconWithRetry(for: finalURL)
            } else if let favicon = faviconPreview {
                faviconData = favicon.tiffRepresentation
            }
            
            // Generate description if we don't have it yet
            var description = generatedDescription
            if description == nil {
                description = await AIDescriptionService.shared.generateDescription(for: name, url: finalURL)
            }
            
            let webLink = WebLink(
                name: name,
                url: finalURL,
                faviconData: faviconData,
                categoryName: selectedCategory,
                description: description
            )
            
            await MainActor.run {
                appManager.addWebLink(webLink)
                isLoading = false
                dismiss()
            }
        }
    }
}
