//
//  Theme.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 23/08/25.
//

import SwiftUI

struct AppTheme {
    let colorScheme: ColorScheme
    
    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    // MARK: - Background Colors
    var background: Color {
        colorScheme == .dark ? Color(hex: "0A0B0D")! : .white
    }
    
    var secondaryBackground: Color {
        colorScheme == .dark ? Color(hex: "1E293B")! : Color(hex: "F8FAFC")!
    }
    
    var cardBackground: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(hex: "1E293B")!, Color(hex: "0F172A")!],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "F8FAFC")!, Color(hex: "F1F5F9")!],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Text Colors
    var primaryText: Color {
        colorScheme == .dark ? .white : Color(hex: "0F172A")!
    }
    
    var secondaryText: Color {
        Color(hex: "64748B")!
    }
    
    var tertiaryText: Color {
        colorScheme == .dark ? Color(hex: "64748B")! : Color(hex: "94A3B8")!
    }
    
    // MARK: - Border Colors
    var border: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.05)
        } else {
            return Color(hex: "E2E8F0")!
        }
    }
    
    // MARK: - Accent Colors
    var accentBlue: Color {
        Color(hex: "3B82F6")!
    }
    
    var successGreen: Color {
        Color(hex: "10B981")!
    }
}

// MARK: - Environment Key
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme(.light)
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func setupAppTheme() -> some View {
        modifier(AppThemeModifier())
    }
}

private struct AppThemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, AppTheme(colorScheme))
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview Theme Wrapper
struct ThemedPreview<Content: View>: View {
    let content: Content
    let colorScheme: ColorScheme
    
    init(_ colorScheme: ColorScheme, @ViewBuilder content: () -> Content) {
        self.colorScheme = colorScheme
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.appTheme, AppTheme(colorScheme))
            .environment(\.colorScheme, colorScheme)
    }
}

// MARK: - Usage Examples
#Preview("Light Theme") {
    ThemedPreview(.light) {
        ThemePreviewContent()
    }
}

#Preview("Dark Theme") {
    ThemedPreview(.dark) {
        ThemePreviewContent()
    }
}

private struct ThemePreviewContent: View {
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Primary Text")
                .font(.headline)
                .foregroundColor(theme.primaryText)
            
            Text("Secondary Text")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
            
            Text("Tertiary Text")
                .font(.caption)
                .foregroundColor(theme.tertiaryText)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .frame(height: 100)
                .overlay(
                    Text("Card Background")
                        .foregroundColor(theme.primaryText)
                )
            
            HStack(spacing: 16) {
                Circle()
                    .fill(theme.accentBlue)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .fill(theme.successGreen)
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .background(theme.background)
    }
}

