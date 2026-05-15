import SwiftUI

// MARK: - Project Model
struct Project: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var nameAr: String
    var elements: [CanvasElement]
    var canvasWidth: CGFloat
    var canvasHeight: CGFloat
    var backgroundColor: String
    var backgroundGradient: [String]?
    var createdAt: Date
    var updatedAt: Date
    var thumbnailData: Data?

    init(name: String = "Untitled", nameAr: String = "بدون عنوان",
         canvasWidth: CGFloat = 1080, canvasHeight: CGFloat = 1080) {
        self.id = UUID()
        self.name = name
        self.nameAr = nameAr
        self.elements = []
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.backgroundColor = "#141418"
        self.backgroundGradient = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.thumbnailData = nil
    }

    var aspectRatio: CGFloat { canvasWidth / canvasHeight }
}

// MARK: - Font Item
struct FontItem: Identifiable, Hashable {
    let id = UUID()
    let name: String          // PostScript font name for UIFont/Font.custom
    let displayName: String   // English display name
    let displayNameAr: String // Arabic display name
    let isArabic: Bool
    let isPro: Bool
    let category: FontCategory
    let previewText: String
    
    enum FontCategory: String, CaseIterable {
        case arabic = "عربي / Arabic"
        case calligraphy = "خط / Calligraphy"
        case modern = "حديث / Modern"
        case english = "إنجليزي / English"
        case decorative = "زخرفي / Decorative"
        case handwriting = "يدوي / Handwriting"
        case custom = "مخصص / Custom"
    }
    
    // Helper to resolve UIFont — falls back to system if name not found
    var uiFont: UIFont {
        if name == "System" { return UIFont.systemFont(ofSize: 17) }
        return UIFont(name: name, size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    static let sampleFonts: [FontItem] = {
        var fonts: [FontItem] = []

        // ══════════════════════════════════════
        // MARK: Arabic Modern (bundled Google Fonts)
        // ══════════════════════════════════════
        let arabicModern: [(String, String, String, Bool)] = [
            // (PostScript name, displayName, displayNameAr, isPro)
            ("Cairo-Regular",       "Cairo",          "القاهرة",      false),
            ("Tajawal-Regular",     "Tajawal",        "تجوال",        false),
            ("Tajawal-Bold",        "Tajawal Bold",   "تجوال عريض",  false),
            ("Almarai-Regular",     "Almarai",        "المراعي",      false),
            ("Almarai-Bold",        "Almarai Bold",   "المراعي عريض", false),
            ("ElMessiri-Regular",   "El Messiri",     "المسيري",      false),
        ]
        for (name, display, displayAr, pro) in arabicModern {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: true, isPro: pro, category: .arabic, previewText: "بسم الله الرحمن الرحيم"))
        }

        // ══════════════════════════════════════
        // MARK: Arabic Calligraphy & Naskh (bundled)
        // ══════════════════════════════════════
        let arabicCalligraphy: [(String, String, String, Bool)] = [
            ("Amiri-Regular",            "Amiri",            "أميري",          false),
            ("Amiri-Bold",               "Amiri Bold",       "أميري عريض",     false),
            ("ReemKufi",                 "Reem Kufi",        "ريم كوفي",       false),
            ("ArefRuqaa-Regular",        "Aref Ruqaa",       "عارف رقعة",      false),
            ("Lateef-Regular",           "Lateef",           "لطيف",            false),
            ("MarkaziText-Regular",      "Markazi Text",     "مركزي",          false),
            ("ScheherazadeNew-Regular",  "Scheherazade",     "شهرزاد",         false),
        ]
        for (name, display, displayAr, pro) in arabicCalligraphy {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: true, isPro: pro, category: .calligraphy, previewText: "صمّم بإبداع"))
        }

        // ══════════════════════════════════════
        // MARK: System Arabic (iOS built-in, always available)
        // ══════════════════════════════════════
        let systemArabic: [(String, String, String, Bool)] = [
            ("GeezaPro",        "Geeza Pro",       "جيزا برو",       false),
            ("GeezaPro-Bold",   "Geeza Pro Bold",  "جيزا برو عريض",  false),
            ("Damascus",        "Damascus",        "دمشق",            false),
            ("DamascusBold",    "Damascus Bold",   "دمشق عريض",      false),
            ("Baghdad",         "Baghdad",         "بغداد",           false),
            ("AlNile",          "Al Nile",         "النيل",           false),
            ("AlNile-Bold",     "Al Nile Bold",    "النيل عريض",     false),
            ("AlBayan",         "Al Bayan",        "البيان",          false),
            ("AlBayan-Bold",    "Al Bayan Bold",   "البيان عريض",    false),
            ("KufiStandardGK",  "Kufi Standard",   "كوفي",            false),
            ("DecoTypeNaskh",   "Naskh",           "نسخ",             false),
            ("Farah",           "Farah",           "فرح",             false),
        ]
        for (name, display, displayAr, pro) in systemArabic {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: true, isPro: pro, category: .arabic, previewText: "بسم الله الرحمن الرحيم"))
        }

        // ══════════════════════════════════════
        // MARK: English Modern (iOS built-in)
        // ══════════════════════════════════════
        let english: [(String, String, String, Bool)] = [
            ("System",                  "System Default",       "النظام",            false),
            ("HelveticaNeue",           "Helvetica Neue",       "هلفيتيكا",         false),
            ("HelveticaNeue-Bold",      "Helvetica Bold",       "هلفيتيكا عريض",    false),
            ("HelveticaNeue-Light",     "Helvetica Light",      "هلفيتيكا خفيف",    false),
            ("AvenirNext-Regular",      "Avenir Next",          "أفينير",            false),
            ("AvenirNext-Bold",         "Avenir Next Bold",     "أفينير عريض",      false),
            ("AvenirNext-Medium",       "Avenir Next Medium",   "أفينير وسط",       false),
            ("Futura-Medium",           "Futura",               "فيوتشرا",          false),
            ("Futura-Bold",             "Futura Bold",          "فيوتشرا عريض",    false),
            ("GillSans",                "Gill Sans",            "غيل سانس",         false),
            ("GillSans-Bold",           "Gill Sans Bold",       "غيل سانس عريض",   false),
            ("Georgia",                 "Georgia",              "جورجيا",           false),
            ("Georgia-Bold",            "Georgia Bold",         "جورجيا عريض",     false),
            ("TimesNewRomanPSMT",       "Times New Roman",      "تايمز",            false),
            ("Baskerville",             "Baskerville",          "باسكرفيل",         false),
            ("Palatino-Roman",          "Palatino",             "بالاتينو",         false),
            ("Didot",                   "Didot",                "ديدو",             false),
            ("Cochin",                  "Cochin",               "كوشين",            false),
            ("Optima-Regular",          "Optima",               "أوبتيما",          false),
            ("AmericanTypewriter",      "Typewriter",           "آلة كاتبة",        false),
        ]
        for (name, display, displayAr, pro) in english {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .english, previewText: "The Quick Brown Fox"))
        }

        // ══════════════════════════════════════
        // MARK: Decorative & Handwriting (iOS built-in)
        // ══════════════════════════════════════
        let decorative: [(String, String, String, Bool)] = [
            ("SnellRoundhand",          "Snell Roundhand",      "سنيل",             false),
            ("SnellRoundhand-Bold",     "Snell Bold",           "سنيل عريض",       false),
            ("Copperplate",             "Copperplate",          "كوبربليت",         false),
            ("Papyrus",                 "Papyrus",              "بردي",             false),
            ("MarkerFelt-Thin",         "Marker Felt",          "ماركر",            false),
            ("MarkerFelt-Wide",         "Marker Wide",          "ماركر عريض",      false),
            ("BradleyHandITCTT-Bold",   "Bradley Hand",         "برادلي",           false),
            ("Chalkduster",             "Chalkduster",          "طباشير",           false),
            ("ChalkboardSE-Regular",    "Chalkboard",           "سبورة",            false),
            ("Noteworthy-Bold",         "Noteworthy",           "ملاحظات",         false),
        ]
        for (name, display, displayAr, pro) in decorative {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .decorative, previewText: "Creative Design"))
        }

        return fonts
    }()
    
    /// Get fonts filtered by category
    static func fonts(for category: FontCategory) -> [FontItem] {
        sampleFonts.filter { $0.category == category }
    }
    
    /// All Arabic-supporting fonts
    static var arabicFonts: [FontItem] {
        sampleFonts.filter { $0.isArabic }
    }
    
    /// All free fonts
    static var freeFonts: [FontItem] {
        sampleFonts.filter { !$0.isPro }
    }
}

// MARK: - Sticker
struct StickerItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let systemIcon: String
    let category: StickerCategory
    let isPro: Bool
    
    enum StickerCategory: String, CaseIterable {
        case emoji = "Emoji"
        case islamic = "Islamic"
        case calligraphy = "Calligraphy"
        case celebration = "Celebration"
        case nature = "Nature"
        case business = "Business"
        case social = "Social"
        case arrows = "Arrows"
        case decorative = "Decorative"
    }
    
    static let sampleStickers: [StickerItem] = {
        var stickers: [StickerItem] = []
        let emojiIcons = ["face.smiling", "hand.thumbsup", "heart.fill", "star.fill", "sun.max.fill", "moon.fill", "cloud.fill", "bolt.fill"]
        let islamicIcons = ["moon.stars.fill", "sparkles", "star.circle.fill", "sun.haze.fill", "moon.haze.fill", "light.beacon.max"]
        let calligraphyIcons = ["Calligraphy_Bismillah", "Calligraphy_Allah", "Calligraphy_Muhammad", "Calligraphy_Mashallah", "Calligraphy_Subhanallah", "Calligraphy_Alhamdulillah"]
        let celebrationIcons = ["party.popper.fill", "gift.fill", "balloon.fill", "fireworks", "trophy.fill", "medal.fill"]
        let natureIcons = ["leaf.fill", "tree.fill", "drop.fill", "flame.fill", "snowflake", "wind"]
        let businessIcons = ["briefcase.fill", "chart.bar.fill", "dollarsign.circle.fill", "building.2.fill", "phone.fill", "envelope.fill"]
        
        for icon in emojiIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .emoji, isPro: false)) }
        for icon in islamicIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .islamic, isPro: false)) }
        for icon in calligraphyIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .calligraphy, isPro: false)) }
        for icon in celebrationIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .celebration, isPro: false)) }
        for icon in natureIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .nature, isPro: false)) }
        for icon in businessIcons { stickers.append(StickerItem(name: icon, systemIcon: icon, category: .business, isPro: true)) }
        return stickers
    }()
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable {
    case png = "PNG"
    case jpg = "JPG"
    case pngTransparent = "PNG (Transparent)"
    case pdf = "PDF"
    case video = "Video (MP4)"
    
    var icon: String {
        switch self {
        case .png, .pngTransparent: return "photo"
        case .jpg: return "photo.fill"
        case .pdf: return "doc.fill"
        case .video: return "video.fill"
        }
    }
}

// MARK: - Filter
struct PhotoFilter: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameAr: String
    let ciFilterName: String?
    var intensity: Double = 1.0
    
    static let filters: [PhotoFilter] = [
        PhotoFilter(name: "Original", nameAr: "أصلي", ciFilterName: nil),
        PhotoFilter(name: "Vivid", nameAr: "حيوي", ciFilterName: "CIVibrance"),
        PhotoFilter(name: "Dramatic", nameAr: "درامي", ciFilterName: "CIHighlightShadowAdjust"),
        PhotoFilter(name: "Mono", nameAr: "أحادي", ciFilterName: "CIPhotoEffectMono"),
        PhotoFilter(name: "Chrome", nameAr: "كروم", ciFilterName: "CIPhotoEffectChrome"),
        PhotoFilter(name: "Fade", nameAr: "باهت", ciFilterName: "CIPhotoEffectFade"),
        PhotoFilter(name: "Instant", nameAr: "فوري", ciFilterName: "CIPhotoEffectInstant"),
        PhotoFilter(name: "Noir", nameAr: "نوار", ciFilterName: "CIPhotoEffectNoir"),
        PhotoFilter(name: "Tonal", nameAr: "لوني", ciFilterName: "CIPhotoEffectTonal"),
        PhotoFilter(name: "Sepia", nameAr: "بني", ciFilterName: "CISepiaTone"),
    ]
}
