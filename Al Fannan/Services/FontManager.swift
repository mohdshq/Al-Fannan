import SwiftUI
import CoreText
import UniformTypeIdentifiers

@Observable
class FontManager {
    static let shared = FontManager()
    
    var customFonts: [FontItem] = []
    private var _systemFonts: [FontItem]? = nil
    private var isLoadingFonts = false
    
    init() {
        // Start with curated fonts only — system fonts load lazily
        loadImportedFonts()
    }
    
    var allFonts: [FontItem] {
        return (_systemFonts ?? FontItem.sampleFonts) + customFonts
    }
    
    /// Call this when the font picker appears to trigger background loading
    func ensureSystemFontsLoaded() {
        guard _systemFonts == nil && !isLoadingFonts else { return }
        isLoadingFonts = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var loaded: [FontItem] = FontItem.sampleFonts
            var existingNames = Set(loaded.map { $0.name })
            
            // Only load one variant per family to reduce count
            let families = UIFont.familyNames.sorted()
            for family in families {
                let fontNames = UIFont.fontNames(forFamilyName: family)
                // Take first font from each family (regular style)
                if let name = fontNames.first, !existingNames.contains(name) {
                    let isArabic = name.localizedCaseInsensitiveContains("Arabic") || 
                                   name.localizedCaseInsensitiveContains("Kufi") || 
                                   name.localizedCaseInsensitiveContains("Naskh") || 
                                   name.localizedCaseInsensitiveContains("Bayan") || 
                                   name.localizedCaseInsensitiveContains("Farah") || 
                                   name.localizedCaseInsensitiveContains("Geeza") || 
                                   name.localizedCaseInsensitiveContains("Damascus") ||
                                   family.localizedCaseInsensitiveContains("Arabic")
                    
                    let newItem = FontItem(
                        name: name,
                        displayName: family,
                        displayNameAr: family,
                        isArabic: isArabic,
                        isPro: false,
                        category: isArabic ? .arabic : .english,
                        previewText: isArabic ? "بسم الله الرحمن الرحيم" : "The Quick Brown Fox"
                    )
                    loaded.append(newItem)
                    existingNames.insert(name)
                }
            }
            
            DispatchQueue.main.async {
                self?._systemFonts = loaded
                self?.isLoadingFonts = false
            }
        }
    }
    
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
            
            // Register font
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(destinationURL as CFURL, .process, &error) {
                // Get postscript name
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
                        // Avoid duplicates
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
                    // Avoid duplicates
                    if !loaded.contains(where: { $0.name == name }) {
                        loaded.append(newItem)
                    }
                }
            }
        }
        self.customFonts = loaded
    }
}
