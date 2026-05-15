import SwiftUI
import CoreText
import UniformTypeIdentifiers

@Observable
class FontManager {
    static let shared = FontManager()

    /// User-imported custom fonts (loaded from Documents/Fonts at launch).
    var customFonts: [FontItem] = []

    init() {
        loadImportedFonts()
    }

    /// The complete font list shown to users:
    /// curated bundled + system fonts (from `FontItem.sampleFonts`) plus user-imported fonts.
    var allFonts: [FontItem] {
        FontItem.sampleFonts + customFonts
    }

    // MARK: - User-imported fonts

    func importFont(from url: URL) {
        let isSecuredURL = url.startAccessingSecurityScopedResource()
        defer {
            if isSecuredURL {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fontsDirectory = documentsDirectory.appendingPathComponent("Fonts")

        if !fileManager.fileExists(atPath: fontsDirectory.path) {
            try? fileManager.createDirectory(at: fontsDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let destinationURL = fontsDirectory.appendingPathComponent(url.lastPathComponent)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)

            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(destinationURL as CFURL, .process, &error) {
                if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(destinationURL as CFURL) as? [CTFontDescriptor],
                   let descriptor = descriptors.first,
                   let name = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String {

                    let displayName = url.deletingPathExtension().lastPathComponent
                    let newItem = FontItem(
                        name: name,
                        displayName: displayName,
                        displayNameAr: displayName,
                        isArabic: true,
                        isPro: false,
                        category: .custom,
                        previewText: "نص مخصص / Custom Text"
                    )

                    DispatchQueue.main.async {
                        if !self.customFonts.contains(where: { $0.name == name }) {
                            self.customFonts.append(newItem)
                        }
                    }
                }
            } else {
                print("Failed to register font: \(String(describing: error?.takeRetainedValue()))")
            }
        } catch {
            print("Error importing font: \(error.localizedDescription)")
        }
    }

    private func loadImportedFonts() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fontsDirectory = documentsDirectory.appendingPathComponent("Fonts")

        guard let urls = try? fileManager.contentsOfDirectory(at: fontsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }

        var loaded: [FontItem] = []
        for url in urls where url.pathExtension.lowercased() == "ttf" || url.pathExtension.lowercased() == "otf" {
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
                   let descriptor = descriptors.first,
                   let name = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String {
                    let displayName = url.deletingPathExtension().lastPathComponent
                    let newItem = FontItem(
                        name: name,
                        displayName: displayName,
                        displayNameAr: displayName,
                        isArabic: true,
                        isPro: false,
                        category: .custom,
                        previewText: "نص مخصص / Custom Text"
                    )
                    if !loaded.contains(where: { $0.name == name }) {
                        loaded.append(newItem)
                    }
                }
            }
        }
        self.customFonts = loaded
    }
}

