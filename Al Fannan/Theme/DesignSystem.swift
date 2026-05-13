import SwiftUI

// MARK: - Design System
struct DS {
    
    // MARK: - Colors
    struct Colors {
        // Primary palette - Rich gold/amber inspired by Arabic calligraphy
        static let primary = Color(hex: "D4A853")
        static let primaryLight = Color(hex: "E8C97A")
        static let primaryDark = Color(hex: "B8892F")
        
        // Secondary - Deep royal blue
        static let secondary = Color(hex: "1B2838")
        static let secondaryLight = Color(hex: "2A3F5F")
        
        // Accent - Warm coral
        static let accent = Color(hex: "E8734A")
        static let accentLight = Color(hex: "FF9B76")
        
        // Backgrounds
        static let bgPrimary = Color(hex: "0D0D0F")
        static let bgSecondary = Color(hex: "141418")
        static let bgTertiary = Color(hex: "1C1C22")
        static let bgCard = Color(hex: "1E1E26")
        static let bgElevated = Color(hex: "252530")
        
        // Surface
        static let surface = Color.white.opacity(0.06)
        static let surfaceHover = Color.white.opacity(0.10)
        static let surfaceBorder = Color.white.opacity(0.08)
        
        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.45)
        static let textInverse = Color(hex: "0D0D0F")
        
        // Semantic
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FFB340")
        static let error = Color(hex: "FF4757")
        static let info = Color(hex: "5AC8FA")
        
        // Gradients
        static let goldGradient = LinearGradient(
            colors: [Color(hex: "D4A853"), Color(hex: "F0D48A"), Color(hex: "D4A853")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let premiumGradient = LinearGradient(
            colors: [Color(hex: "D4A853"), Color(hex: "8B6914")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let darkGradient = LinearGradient(
            colors: [Color(hex: "1C1C22"), Color(hex: "0D0D0F")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let heroGradient = LinearGradient(
            colors: [
                Color(hex: "D4A853").opacity(0.3),
                Color(hex: "E8734A").opacity(0.15),
                Color(hex: "0D0D0F").opacity(0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Category Colors
        static let categoryColors: [Color] = [
            Color(hex: "D4A853"),
            Color(hex: "E8734A"),
            Color(hex: "5AC8FA"),
            Color(hex: "34C759"),
            Color(hex: "AF52DE"),
            Color(hex: "FF6B8A"),
            Color(hex: "FFB340"),
            Color(hex: "30D5C8"),
        ]
    }
    
    // MARK: - Typography
    struct Typography {
        static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title = Font.system(size: 20, weight: .semibold)
        static let titleSmall = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 15, weight: .medium)
        static let caption = Font.system(size: 13, weight: .regular)
        static let captionSmall = Font.system(size: 11, weight: .medium)
        static let tag = Font.system(size: 12, weight: .semibold)
        
        // Arabic-optimized
        static let arabicDisplay = Font.system(size: 36, weight: .bold)
        static let arabicTitle = Font.system(size: 24, weight: .semibold)
        static let arabicBody = Font.system(size: 18, weight: .regular)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let huge: CGFloat = 48
        static let massive: CGFloat = 64
    }
    
    // MARK: - Radius
    struct Radius {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let full: CGFloat = 999
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 8)
        static let glow = Shadow(color: Colors.primary.opacity(0.3), radius: 20, x: 0, y: 0)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - String Helpers
extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
