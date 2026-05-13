import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager
struct HapticManager {
    
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Soft tap for UI interactions
    static func softTap() { impact(.light) }
    
    /// Medium tap for button presses  
    static func tap() { impact(.medium) }
    
    /// Heavy thud for confirmations
    static func thud() { impact(.heavy) }
    
    /// Success feedback
    static func success() { notification(.success) }
    
    /// Error feedback
    static func error() { notification(.error) }
    
    /// Warning feedback
    static func warning() { notification(.warning) }
}

// MARK: - Keyboard Dismiss Helper
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - UIImage Extension for Resizing
extension UIImage {
    func resized(to maxDimension: CGFloat) -> UIImage {
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1.0 { return self }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}

// Color.toHex() is defined in TextToolsView.swift

// MARK: - Date Formatting
extension Date {
    var projectDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
