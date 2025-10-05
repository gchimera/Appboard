import SwiftUI

enum ToastStyle {
    case success
    case error
    case info
}

struct ToastView: View {
    let message: String
    var style: ToastStyle = .success

    private var iconName: String {
        switch style {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var iconColor: Color {
        switch style {
        case .success: return .accentColor
        case .error: return .red
        case .info: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.96))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}
