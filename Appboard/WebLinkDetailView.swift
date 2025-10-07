import SwiftUI

struct WebLinkDetailView: View {
    let webLink: WebLink
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appManager: AppManager
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    @State private var editedName: String
    @State private var editedURL: String
    @State private var editedDescription: String
    @State private var selectedCategory: String?
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isRegeneratingDescription: Bool = false
    
    init(webLink: WebLink) {
        self.webLink = webLink
        _editedName = State(initialValue: webLink.name)
        _editedURL = State(initialValue: webLink.url)
        _editedDescription = State(initialValue: webLink.description ?? "")
        _selectedCategory = State(initialValue: webLink.categoryName)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with favicon
            HStack(spacing: 16) {
                if let favicon = webLink.favicon {
                    Image(nsImage: favicon)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                } else {
                    Image(systemName: "globe")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .frame(width: 64, height: 64)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("name".localized(), text: $editedName)
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                    } else {
                        Text(webLink.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text(webLink.displayURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Details
            VStack(alignment: .leading, spacing: 16) {
                // URL
                DetailRow(label: "url".localized()) {
                    if isEditing {
                        TextField("url".localized(), text: $editedURL)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(webLink.url)
                            .textSelection(.enabled)
                    }
                }
                
                // Category
                DetailRow(label: "category".localized()) {
                    if isEditing {
                        Picker("", selection: $selectedCategory) {
                            Text("none".localized()).tag(nil as String?)
                            ForEach(appManager.categories, id: \.self) { category in
                                if category != "Tutte" {
                                    Text(category).tag(category as String?)
                                }
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Text(webLink.categoryName ?? "none".localized())
                    }
                }
                
                // Description
                DetailRow(label: "description".localized()) {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $editedDescription)
                                .frame(height: 80)
                                .font(.caption)
                                .padding(4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            
                            Button {
                                regenerateDescription()
                            } label: {
                                HStack(spacing: 4) {
                                    if isRegeneratingDescription {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text("regenerate_with_ai".localized())
                                }
                                .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .disabled(isRegeneratingDescription)
                        }
                    } else {
                        if let description = webLink.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textSelection(.enabled)
                        } else {
                            Text("no_description".localized())
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                // Date added
                DetailRow(label: "date_added".localized()) {
                    Text(webLink.dateAdded.formatted(date: .abbreviated, time: .shortened))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                if isEditing {
                    Button("cancel".localized()) {
                        isEditing = false
                        editedName = webLink.name
                        editedURL = webLink.url
                        editedDescription = webLink.description ?? ""
                        selectedCategory = webLink.categoryName
                    }
                    
                    Button("save".localized()) {
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(editedName.isEmpty || editedURL.isEmpty)
                } else {
                    Button("open_in_browser".localized()) {
                        if let url = URL(string: webLink.url) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("edit".localized()) {
                        isEditing = true
                    }
                    
                    Button("delete".localized(), role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    
                    Button("close".localized()) {
                        dismiss()
                    }
                }
            }
            .padding(.bottom)
        }
        .frame(width: 500, height: 400)
        .padding()
        .alert("delete_link".localized(), isPresented: $showDeleteConfirmation) {
            Button("cancel".localized(), role: .cancel) { }
            Button("delete".localized(), role: .destructive) {
                appManager.deleteWebLink(webLink)
                dismiss()
            }
        } message: {
            Text(String(format: "delete_link_message".localized(), webLink.name))
        }
    }
    
    private func saveChanges() {
        let updatedLink = WebLink(
            id: webLink.id,
            name: editedName,
            url: editedURL,
            faviconData: webLink.faviconData,
            categoryName: selectedCategory,
            description: editedDescription.isEmpty ? nil : editedDescription
        )
        appManager.updateWebLink(updatedLink)
        isEditing = false
        dismiss()
    }
    
    private func regenerateDescription() {
        isRegeneratingDescription = true
        Task {
            let newDescription = await AIDescriptionService.shared.generateDescription(
                for: editedName,
                url: editedURL
            )
            await MainActor.run {
                if let description = newDescription {
                    editedDescription = description
                }
                isRegeneratingDescription = false
            }
        }
    }
}

struct DetailRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .trailing)
            
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
