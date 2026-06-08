import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum AppColors {
    public static let primary = Color.accentColor
    public static let cardBackground = Color.secondaryBackground
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
}

private extension Color {
    static var secondaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }
}
