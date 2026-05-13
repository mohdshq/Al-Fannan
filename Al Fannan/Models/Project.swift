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
        // MARK: Arabic Fonts (24)
        // ══════════════════════════════════════
        let arabicFonts: [(String, String, String, Bool)] = [
            // (PostScript name, displayName, displayNameAr, isPro)
            ("GeezaPro",               "Geeza Pro",            "جيزا برو",       false),
            ("GeezaPro-Bold",          "Geeza Pro Bold",       "جيزا برو عريض",  false),
            ("Damascus",               "Damascus",             "دمشق",           false),
            ("DamascusBold",           "Damascus Bold",        "دمشق عريض",      false),
            ("DamascusLight",          "Damascus Light",       "دمشق خفيف",      false),
            ("DamascusMedium",         "Damascus Medium",      "دمشق وسط",       false),
            ("DamascusSemiBold",       "Damascus SemiBold",    "دمشق نصف عريض",  false),
            ("Baghdad",                "Baghdad",              "بغداد",           false),
            ("Farah",                  "Farah",                "فرح",             false),
            ("Nadeem",                 "Nadeem",               "نديم",            false),
            ("AlNile",                 "Al Nile",              "النيل",           false),
            ("AlNile-Bold",            "Al Nile Bold",         "النيل عريض",     false),
            ("AlBayan",                "Al Bayan",             "البيان",          false),
            ("AlBayan-Bold",           "Al Bayan Bold",        "البيان عريض",    false),
            ("AlTarikh",               "Al Tarikh",            "التاريخ",         false),
            ("Waseem",                 "Waseem",               "وسيم",            false),
            ("WaseemLight",            "Waseem Light",         "وسيم خفيف",      false),
            ("Muna",                   "Muna",                 "منى",             false),
            ("MunaBold",               "Muna Bold",            "منى عريض",       false),
            ("Sana",                   "Sana",                 "سنا",             false),
            ("Mishafi",                "Mishafi",              "مشافي",           false),
            ("MishafiGold",            "Mishafi Gold",         "مشافي ذهبي",     true),
            ("KacstOne",               "KACST One",            "كاكست",           false),
            ("Diwan Mishafi",          "Diwan Mishafi",        "ديوان مشافي",    true),
        ]
        for (name, display, displayAr, pro) in arabicFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: true, isPro: pro, category: .arabic, previewText: "بسم الله الرحمن الرحيم"))
        }
        
        // ══════════════════════════════════════
        // MARK: Calligraphy & Naskh (10)
        // ══════════════════════════════════════
        let calligraphyFonts: [(String, String, String, Bool)] = [
            ("KufiStandardGK",         "Kufi Standard",        "كوفي",            false),
            ("DecoTypeNaskh",          "Naskh",                "نسخ",             false),
            ("DevanagariSangamMN",     "Devanagari Sangam",    "ديفاناغري",       true),
            ("NotoNastaliqUrdu",       "Noto Nastaliq",        "نستعليق",         true),
            ("Diwan Kufi",             "Diwan Kufi",           "ديوان كوفي",      true),
            ("Diwan Thuluth",          "Diwan Thuluth",        "ديوان ثلث",       true),
            ("Kohinoor Devanagari",    "Kohinoor",             "كوهينور",         true),
            ("ArialHebrew",            "Arial Hebrew",         "أريال عبري",      false),
            ("ArialHebrew-Bold",       "Arial Hebrew Bold",    "أريال عبري عريض", false),
            ("EuphemiaUCAS",           "Euphemia",             "يوفيميا",         false),
        ]
        for (name, display, displayAr, pro) in calligraphyFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: true, isPro: pro, category: .calligraphy, previewText: "صمّم بإبداع"))
        }
        
        // ══════════════════════════════════════
        // MARK: Modern English Fonts (20)
        // ══════════════════════════════════════
        let modernFonts: [(String, String, String, Bool)] = [
            ("System",                 "System Default",       "النظام",           false),
            ("Helvetica",              "Helvetica",            "هلفيتيكا",         false),
            ("HelveticaNeue",          "Helvetica Neue",       "هلفيتيكا نيو",    false),
            ("HelveticaNeue-Bold",     "Helvetica Neue Bold",  "هلفيتيكا عريض",   false),
            ("HelveticaNeue-Light",    "Helvetica Neue Light", "هلفيتيكا خفيف",   false),
            ("HelveticaNeue-Thin",     "Helvetica Neue Thin",  "هلفيتيكا رفيع",   false),
            ("HelveticaNeue-UltraLight","Helvetica Ultra Light","هلفيتيكا فائق",   false),
            ("AvenirNext-Regular",     "Avenir Next",          "أفينير",           false),
            ("AvenirNext-Bold",        "Avenir Next Bold",     "أفينير عريض",     false),
            ("AvenirNext-Medium",      "Avenir Next Medium",   "أفينير وسط",      false),
            ("AvenirNext-DemiBold",    "Avenir Next DemiBold", "أفينير نصف عريض", false),
            ("AvenirNext-UltraLight",  "Avenir Next UltraLight","أفينير فائق",    false),
            ("Futura-Medium",          "Futura",               "فيوتشرا",         false),
            ("Futura-Bold",            "Futura Bold",          "فيوتشرا عريض",   false),
            ("Futura-CondensedMedium", "Futura Condensed",     "فيوتشرا ضيق",    false),
            ("SFProDisplay-Regular",   "SF Pro Display",       "سان فرانسيسكو",   false),
            ("SFProText-Regular",      "SF Pro Text",          "سان فرانسيسكو نص",false),
            ("GillSans",               "Gill Sans",            "غيل سانس",        false),
            ("GillSans-Bold",          "Gill Sans Bold",       "غيل سانس عريض",  false),
            ("GillSans-Light",         "Gill Sans Light",      "غيل سانس خفيف",  false),
        ]
        for (name, display, displayAr, pro) in modernFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .modern, previewText: "Hello World"))
        }
        
        // ══════════════════════════════════════
        // MARK: Classic / Serif English Fonts (14)
        // ══════════════════════════════════════
        let classicFonts: [(String, String, String, Bool)] = [
            ("Georgia",                "Georgia",              "جورجيا",           false),
            ("Georgia-Bold",           "Georgia Bold",         "جورجيا عريض",     false),
            ("Georgia-Italic",         "Georgia Italic",       "جورجيا مائل",     false),
            ("TimesNewRomanPSMT",      "Times New Roman",      "تايمز نيو رومان", false),
            ("TimesNewRomanPS-BoldMT", "Times New Roman Bold", "تايمز عريض",      false),
            ("Baskerville",            "Baskerville",          "باسكرفيل",        false),
            ("Baskerville-Bold",       "Baskerville Bold",     "باسكرفيل عريض",  false),
            ("Palatino-Roman",         "Palatino",             "بالاتينو",        false),
            ("Palatino-Bold",          "Palatino Bold",        "بالاتينو عريض",  false),
            ("Didot",                  "Didot",                "ديدو",            false),
            ("Didot-Bold",             "Didot Bold",           "ديدو عريض",      false),
            ("Cochin",                 "Cochin",               "كوشين",           false),
            ("BodoniSvtyTwoITCTT-Book","Bodoni 72",            "بودوني",          true),
            ("Optima-Regular",         "Optima",               "أوبتيما",         false),
        ]
        for (name, display, displayAr, pro) in classicFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .english, previewText: "The Quick Brown Fox"))
        }
        
        // ══════════════════════════════════════
        // MARK: Decorative Fonts (10)
        // ══════════════════════════════════════
        let decorativeFonts: [(String, String, String, Bool)] = [
            ("Copperplate",            "Copperplate",          "كوبربليت",        false),
            ("Copperplate-Bold",       "Copperplate Bold",     "كوبربليت عريض",  false),
            ("Papyrus",                "Papyrus",              "بردي",            false),
            ("PartyLetPlain",          "Party LET",            "حفلة",            true),
            ("SnellRoundhand",         "Snell Roundhand",      "سنيل",            true),
            ("SnellRoundhand-Bold",    "Snell Roundhand Bold", "سنيل عريض",      true),
            ("AmericanTypewriter",     "American Typewriter",  "آلة كاتبة",       false),
            ("AmericanTypewriter-Bold","Typewriter Bold",      "آلة كاتبة عريض",  false),
            ("Rockwell-Regular",       "Rockwell",             "روكويل",          false),
            ("IowanOldStyle-Roman",    "Iowan Old Style",      "آيوان",           false),
        ]
        for (name, display, displayAr, pro) in decorativeFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .decorative, previewText: "Creative Design"))
        }
        
        // ══════════════════════════════════════
        // MARK: Handwriting Fonts (8)
        // ══════════════════════════════════════
        let handwritingFonts: [(String, String, String, Bool)] = [
            ("MarkerFelt-Thin",        "Marker Felt Thin",     "ماركر رفيع",      false),
            ("MarkerFelt-Wide",        "Marker Felt Wide",     "ماركر عريض",      false),
            ("BradleyHandITCTT-Bold",  "Bradley Hand",         "برادلي",          false),
            ("Chalkduster",            "Chalkduster",          "طباشير",          false),
            ("ChalkboardSE-Regular",   "Chalkboard SE",        "سبورة",           false),
            ("ChalkboardSE-Bold",      "Chalkboard SE Bold",   "سبورة عريض",     false),
            ("Noteworthy-Bold",        "Noteworthy Bold",      "ملاحظات عريض",   false),
            ("Noteworthy-Light",       "Noteworthy Light",     "ملاحظات خفيف",   false),
        ]
        for (name, display, displayAr, pro) in handwritingFonts {
            fonts.append(FontItem(name: name, displayName: display, displayNameAr: displayAr, isArabic: false, isPro: pro, category: .handwriting, previewText: "Handwritten Style"))
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
