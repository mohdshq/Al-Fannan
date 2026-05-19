import SwiftUI

// MARK: - Template Category
struct TemplateCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameAr: String
    let icon: String
    let color: Color
    let templateCount: Int

    static let allCategories: [TemplateCategory] = [
        TemplateCategory(name: "Ramadan",  nameAr: "رمضان",   icon: "moon.stars",   color: Color(hex: "D4A853"), templateCount: 4),
        TemplateCategory(name: "Eid",      nameAr: "عيد",     icon: "sparkles",     color: Color(hex: "34C759"), templateCount: 4),
        TemplateCategory(name: "Wedding",  nameAr: "زفاف",    icon: "heart.fill",   color: Color(hex: "FF6B8A"), templateCount: 4),
        TemplateCategory(name: "Business", nameAr: "أعمال",   icon: "briefcase",    color: Color(hex: "5AC8FA"), templateCount: 4),
        TemplateCategory(name: "Quotes",   nameAr: "اقتباسات", icon: "quote.bubble", color: Color(hex: "FFB340"), templateCount: 4),
    ]
}

// MARK: - Template
struct Template: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameAr: String
    let category: String
    let subKey: String           // unique key passed to TemplateFactory to pick a layout
    let previewColors: [Color]
    let isPro: Bool
    let aspectRatio: CGFloat     // width / height
    let tags: [String]

    static let sampleTemplates: [Template] = [
        // ── Featured row order: Ramadan Kareem → Eid Mubarak → Wedding Invite → Quran Verse → Business Card → Ramadan Greeting ──

        // Ramadan
        Template(name: "Ramadan Kareem",   nameAr: "رمضان كريم",       category: "Ramadan",
                 subKey: "ramadan_kareem",
                 previewColors: [Color(hex: "1A237E"), Color(hex: "D4A853")],
                 isPro: false, aspectRatio: 1.0, tags: ["ramadan", "kareem"]),

        // Eid
        Template(name: "Eid Mubarak Gold", nameAr: "عيد مبارك",         category: "Eid",
                 subKey: "eid_mubarak_gold",
                 previewColors: [Color(hex: "0B3D2E"), Color(hex: "D4A853")],
                 isPro: false, aspectRatio: 1.0, tags: ["eid", "gold"]),

        // Wedding
        Template(name: "Wedding Invite",   nameAr: "دعوة زفاف",         category: "Wedding",
                 subKey: "wedding_classic",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "C9A96E")],
                 isPro: false, aspectRatio: 1.0, tags: ["wedding", "classic"]),

        // Quotes
        Template(name: "Quran Verse",      nameAr: "آية قرآنية",         category: "Quotes",
                 subKey: "quote_quran",
                 previewColors: [Color(hex: "141418"), Color(hex: "D4A853")],
                 isPro: false, aspectRatio: 1.0, tags: ["quote", "quran"]),

        // Business
        Template(name: "Business Card",    nameAr: "بطاقة عمل",         category: "Business",
                 subKey: "business_card",
                 previewColors: [Color(hex: "0D1B2A"), Color(hex: "5AC8FA")],
                 isPro: false, aspectRatio: 1.0, tags: ["business", "card"]),

        // Ramadan
        Template(name: "Ramadan Greeting", nameAr: "تهنئة رمضان",        category: "Ramadan",
                 subKey: "ramadan_greeting",
                 previewColors: [Color(hex: "0D1137"), Color(hex: "E6C229")],
                 isPro: false, aspectRatio: 1.0, tags: ["ramadan", "greeting"]),

        Template(name: "Iftar Invite",     nameAr: "دعوة إفطار",        category: "Ramadan",
                 subKey: "ramadan_iftar",
                 previewColors: [Color(hex: "1B0A3C"), Color(hex: "F0D48A")],
                 isPro: true,  aspectRatio: 1.0, tags: ["ramadan", "iftar"]),

        Template(name: "Suhoor Reminder",  nameAr: "تذكير سحور",        category: "Ramadan",
                 subKey: "ramadan_suhoor",
                 previewColors: [Color(hex: "1A2A3A"), Color(hex: "F0D48A")],
                 isPro: true,  aspectRatio: 1.0, tags: ["ramadan", "suhoor"]),

        // Eid
        Template(name: "Eid Al-Fitr",      nameAr: "عيد الفطر",         category: "Eid",
                 subKey: "eid_fitr",
                 previewColors: [Color(hex: "2E1A47"), Color(hex: "F0D48A")],
                 isPro: false, aspectRatio: 1.0, tags: ["eid", "fitr"]),

        Template(name: "Eid Al-Adha",      nameAr: "عيد الأضحى",        category: "Eid",
                 subKey: "eid_adha",
                 previewColors: [Color(hex: "1A3A1A"), Color(hex: "D4A853")],
                 isPro: true,  aspectRatio: 1.0, tags: ["eid", "adha"]),

        Template(name: "Eid Greeting",     nameAr: "تهنئة العيد",        category: "Eid",
                 subKey: "eid_greeting",
                 previewColors: [Color(hex: "1B1B3A"), Color(hex: "FFD700")],
                 isPro: true,  aspectRatio: 1.0, tags: ["eid", "greeting"]),

        // Wedding
        Template(name: "Save the Date",    nameAr: "احفظ التاريخ",       category: "Wedding",
                 subKey: "wedding_save_date",
                 previewColors: [Color(hex: "2D1B2E"), Color(hex: "F4C2C2")],
                 isPro: false, aspectRatio: 1.0, tags: ["wedding", "save"]),

        Template(name: "Engagement",       nameAr: "خطوبة",              category: "Wedding",
                 subKey: "wedding_engagement",
                 previewColors: [Color(hex: "3A1F2E"), Color(hex: "FFB6C1")],
                 isPro: true,  aspectRatio: 1.0, tags: ["wedding", "engagement"]),

        Template(name: "Thank You",        nameAr: "شكراً لكم",          category: "Wedding",
                 subKey: "wedding_thanks",
                 previewColors: [Color(hex: "FFF0F5"), Color(hex: "C9A96E")],
                 isPro: true,  aspectRatio: 1.0, tags: ["wedding", "thanks"]),

        // Business
        Template(name: "Quote of the Day", nameAr: "اقتباس اليوم",       category: "Business",
                 subKey: "business_quote",
                 previewColors: [Color(hex: "0F1B2A"), Color(hex: "D4A853")],
                 isPro: false, aspectRatio: 1.0, tags: ["business", "quote"]),

        Template(name: "Announcement",     nameAr: "إعلان",              category: "Business",
                 subKey: "business_announcement",
                 previewColors: [Color(hex: "0D1B2A"), Color(hex: "FF6B35")],
                 isPro: true,  aspectRatio: 1.0, tags: ["business", "announcement"]),

        Template(name: "Contact Info",     nameAr: "بيانات التواصل",     category: "Business",
                 subKey: "business_contact",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "5AC8FA")],
                 isPro: true,  aspectRatio: 1.0, tags: ["business", "contact"]),

        // Quotes
        Template(name: "Hadith",           nameAr: "حديث شريف",          category: "Quotes",
                 subKey: "quote_hadith",
                 previewColors: [Color(hex: "0F1F1A"), Color(hex: "D4A853")],
                 isPro: false, aspectRatio: 1.0, tags: ["quote", "hadith"]),

        Template(name: "Arabic Proverb",   nameAr: "مثل عربي",           category: "Quotes",
                 subKey: "quote_proverb",
                 previewColors: [Color(hex: "1A1410"), Color(hex: "E8C547")],
                 isPro: true,  aspectRatio: 1.0, tags: ["quote", "proverb"]),

        Template(name: "Motivation",       nameAr: "تحفيز",              category: "Quotes",
                 subKey: "quote_motivation",
                 previewColors: [Color(hex: "1F1147"), Color(hex: "FFB340")],
                 isPro: true,  aspectRatio: 1.0, tags: ["quote", "motivation"]),
    ]
}

// MARK: - Canvas Size Presets
struct CanvasPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameAr: String
    let icon: String
    let width: CGFloat
    let height: CGFloat

    var aspectRatio: CGFloat { width / height }
    var displaySize: String { "\(Int(width)) × \(Int(height))" }

    static let presets: [CanvasPreset] = [
        CanvasPreset(name: "Instagram Post",  nameAr: "بوست انستغرام",  icon: "square",              width: 1080, height: 1080),
        CanvasPreset(name: "Instagram Story", nameAr: "ستوري انستغرام", icon: "rectangle.portrait",  width: 1080, height: 1920),
        CanvasPreset(name: "Facebook Post",   nameAr: "بوست فيسبوك",    icon: "rectangle",           width: 1200, height: 630),
        CanvasPreset(name: "TikTok Video",    nameAr: "فيديو تيك توك",   icon: "play.rectangle",      width: 1080, height: 1920),
        CanvasPreset(name: "Snapchat",        nameAr: "سناب شات",       icon: "camera.viewfinder",   width: 1080, height: 1920),
        CanvasPreset(name: "WhatsApp Status", nameAr: "حالة واتساب",    icon: "message",             width: 1080, height: 1920),
        CanvasPreset(name: "Twitter Post",    nameAr: "بوست تويتر",      icon: "text.bubble",         width: 1600, height: 900),
        CanvasPreset(name: "YouTube Thumb",   nameAr: "صورة يوتيوب",     icon: "play.rectangle.fill", width: 1280, height: 720),
        CanvasPreset(name: "Logo",            nameAr: "شعار",            icon: "crown",               width: 1000, height: 1000),
        CanvasPreset(name: "A4 Portrait",     nameAr: "A4 عمودي",        icon: "doc",                 width: 2480, height: 3508),
        CanvasPreset(name: "Business Card",   nameAr: "بطاقة عمل",       icon: "rectangle.fill",      width: 1050, height: 600),
    ]
}

