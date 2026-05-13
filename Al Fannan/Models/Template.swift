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
        TemplateCategory(name: "Instagram", nameAr: "انستغرام", icon: "camera", color: Color(hex: "E1306C"), templateCount: 156),
        TemplateCategory(name: "Stories", nameAr: "ستوري", icon: "rectangle.portrait", color: Color(hex: "5B51D8"), templateCount: 203),
        TemplateCategory(name: "Ramadan", nameAr: "رمضان", icon: "moon.stars", color: Color(hex: "D4A853"), templateCount: 89),
        TemplateCategory(name: "Eid", nameAr: "عيد", icon: "sparkles", color: Color(hex: "34C759"), templateCount: 67),
        TemplateCategory(name: "Wedding", nameAr: "زفاف", icon: "heart.fill", color: Color(hex: "FF6B8A"), templateCount: 124),
        TemplateCategory(name: "Business", nameAr: "أعمال", icon: "briefcase", color: Color(hex: "5AC8FA"), templateCount: 198),
        TemplateCategory(name: "Real Estate", nameAr: "عقارات", icon: "building.2", color: Color(hex: "30D5C8"), templateCount: 76),
        TemplateCategory(name: "Fashion", nameAr: "أزياء", icon: "tshirt", color: Color(hex: "AF52DE"), templateCount: 145),
        TemplateCategory(name: "Sports", nameAr: "رياضة", icon: "sportscourt", color: Color(hex: "FF9500"), templateCount: 52),
        TemplateCategory(name: "Quotes", nameAr: "اقتباسات", icon: "quote.bubble", color: Color(hex: "FFB340"), templateCount: 234),
        TemplateCategory(name: "National Day", nameAr: "اليوم الوطني", icon: "flag", color: Color(hex: "00C851"), templateCount: 43),
        TemplateCategory(name: "Graduation", nameAr: "تخرج", icon: "graduationcap", color: Color(hex: "2196F3"), templateCount: 38),
        TemplateCategory(name: "TikTok", nameAr: "تيك توك", icon: "play.rectangle", color: Color(hex: "010101"), templateCount: 167),
        TemplateCategory(name: "Snapchat", nameAr: "سناب شات", icon: "camera.viewfinder", color: Color(hex: "FFFC00"), templateCount: 91),
        TemplateCategory(name: "WhatsApp", nameAr: "واتساب", icon: "message", color: Color(hex: "25D366"), templateCount: 115),
        TemplateCategory(name: "Logo", nameAr: "شعار", icon: "crown", color: Color(hex: "D4A853"), templateCount: 78),
    ]
}

// MARK: - Template
struct Template: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameAr: String
    let category: String
    let previewColors: [Color]
    let isPro: Bool
    let aspectRatio: CGFloat // width/height
    let tags: [String]
    
    static let sampleTemplates: [Template] = [
        // Instagram
        Template(name: "Elegant Gold", nameAr: "ذهبي أنيق", category: "Instagram",
                 previewColors: [Color(hex: "D4A853"), Color(hex: "1C1C22")], isPro: false, aspectRatio: 1.0, tags: ["gold", "elegant"]),
        Template(name: "Sunset Vibes", nameAr: "غروب الشمس", category: "Instagram",
                 previewColors: [Color(hex: "FF6B35"), Color(hex: "F7931E")], isPro: false, aspectRatio: 1.0, tags: ["sunset", "warm"]),
        Template(name: "Neon Glow", nameAr: "توهج نيون", category: "Instagram",
                 previewColors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")], isPro: true, aspectRatio: 1.0, tags: ["neon", "dark"]),
        
        // Ramadan
        Template(name: "Ramadan Kareem", nameAr: "رمضان كريم", category: "Ramadan",
                 previewColors: [Color(hex: "1A237E"), Color(hex: "D4A853")], isPro: false, aspectRatio: 1.0, tags: ["ramadan", "islamic"]),
        Template(name: "Ramadan Night", nameAr: "ليالي رمضان", category: "Ramadan",
                 previewColors: [Color(hex: "0D1137"), Color(hex: "E6C229")], isPro: false, aspectRatio: 1.0, tags: ["ramadan", "night"]),
        Template(name: "Iftar Invite", nameAr: "دعوة إفطار", category: "Ramadan",
                 previewColors: [Color(hex: "1B0A3C"), Color(hex: "F0D48A")], isPro: true, aspectRatio: 1.0, tags: ["ramadan", "iftar"]),
        
        // Eid
        Template(name: "Eid Mubarak", nameAr: "عيد مبارك", category: "Eid",
                 previewColors: [Color(hex: "2E7D32"), Color(hex: "F0D48A")], isPro: true, aspectRatio: 1.0, tags: ["eid", "celebration"]),
        Template(name: "Eid Gold", nameAr: "عيد ذهبي", category: "Eid",
                 previewColors: [Color(hex: "000000"), Color(hex: "D4A853")], isPro: false, aspectRatio: 1.0, tags: ["eid", "gold"]),
        
        // Wedding
        Template(name: "Wedding Invite", nameAr: "دعوة زفاف", category: "Wedding",
                 previewColors: [Color(hex: "FFF0F5"), Color(hex: "FF6B8A")], isPro: true, aspectRatio: 0.71, tags: ["wedding", "invite"]),
        Template(name: "Classic Wedding", nameAr: "زفاف كلاسيكي", category: "Wedding",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "C9A96E")], isPro: false, aspectRatio: 0.71, tags: ["wedding", "classic"]),
        Template(name: "Floral Wedding", nameAr: "زفاف ورود", category: "Wedding",
                 previewColors: [Color(hex: "FFEEF8"), Color(hex: "FFB6C1")], isPro: true, aspectRatio: 0.71, tags: ["wedding", "floral"]),
        
        // Business
        Template(name: "Business Card", nameAr: "بطاقة عمل", category: "Business",
                 previewColors: [Color(hex: "0D1B2A"), Color(hex: "5AC8FA")], isPro: false, aspectRatio: 1.78, tags: ["business", "card"]),
        Template(name: "Corporate Blue", nameAr: "شركات أزرق", category: "Business",
                 previewColors: [Color(hex: "1B2838"), Color(hex: "2980B9")], isPro: false, aspectRatio: 1.0, tags: ["business", "corporate"]),
        Template(name: "Startup Fresh", nameAr: "شركة ناشئة", category: "Business",
                 previewColors: [Color(hex: "FFFFFF"), Color(hex: "00B894")], isPro: true, aspectRatio: 1.0, tags: ["business", "startup"]),
        
        // Stories
        Template(name: "Story Gradient", nameAr: "ستوري متدرج", category: "Stories",
                 previewColors: [Color(hex: "667eea"), Color(hex: "764ba2")], isPro: false, aspectRatio: 0.5625, tags: ["story", "gradient"]),
        Template(name: "Story Dark", nameAr: "ستوري داكن", category: "Stories",
                 previewColors: [Color(hex: "0F0F0F"), Color(hex: "1A1A2E")], isPro: false, aspectRatio: 0.5625, tags: ["story", "dark"]),
        Template(name: "Story Pastel", nameAr: "ستوري باستيل", category: "Stories",
                 previewColors: [Color(hex: "FAD0C4"), Color(hex: "FFD1FF")], isPro: true, aspectRatio: 0.5625, tags: ["story", "pastel"]),
        
        // Quotes
        Template(name: "Quote Minimal", nameAr: "اقتباس بسيط", category: "Quotes",
                 previewColors: [Color(hex: "141418"), Color(hex: "D4A853")], isPro: false, aspectRatio: 1.0, tags: ["quote", "minimal"]),
        Template(name: "Quote Elegant", nameAr: "اقتباس أنيق", category: "Quotes",
                 previewColors: [Color(hex: "2D1B4E"), Color(hex: "E8D5B7")], isPro: false, aspectRatio: 1.0, tags: ["quote", "elegant"]),
        Template(name: "Quote Bold", nameAr: "اقتباس جريء", category: "Quotes",
                 previewColors: [Color(hex: "FF416C"), Color(hex: "FF4B2B")], isPro: true, aspectRatio: 1.0, tags: ["quote", "bold"]),
        
        // Real Estate
        Template(name: "Real Estate Pro", nameAr: "عقارات احترافي", category: "Real Estate",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "30D5C8")], isPro: true, aspectRatio: 1.0, tags: ["property", "real estate"]),
        Template(name: "Property Sale", nameAr: "عقار للبيع", category: "Real Estate",
                 previewColors: [Color(hex: "0B0B1A"), Color(hex: "E8B100")], isPro: false, aspectRatio: 1.0, tags: ["property", "sale"]),
        
        // Fashion
        Template(name: "Fashion Look", nameAr: "أزياء عصرية", category: "Fashion",
                 previewColors: [Color(hex: "2D1B4E"), Color(hex: "AF52DE")], isPro: true, aspectRatio: 0.8, tags: ["fashion", "style"]),
        Template(name: "Fashion Minimal", nameAr: "أزياء بسيطة", category: "Fashion",
                 previewColors: [Color(hex: "F5F5F5"), Color(hex: "000000")], isPro: false, aspectRatio: 1.0, tags: ["fashion", "minimal"]),
        
        // Sports
        Template(name: "Sports Energy", nameAr: "رياضة حيوية", category: "Sports",
                 previewColors: [Color(hex: "1C1C1C"), Color(hex: "FF9500")], isPro: false, aspectRatio: 1.0, tags: ["sports", "energy"]),
        Template(name: "Game Day", nameAr: "يوم المباراة", category: "Sports",
                 previewColors: [Color(hex: "0A0A0A"), Color(hex: "E74C3C")], isPro: true, aspectRatio: 1.0, tags: ["sports", "game"]),
        
        // National Day
        Template(name: "National Pride", nameAr: "فخر وطني", category: "National Day",
                 previewColors: [Color(hex: "006C35"), Color(hex: "FFFFFF")], isPro: false, aspectRatio: 1.0, tags: ["national", "pride"]),
        Template(name: "National Day 93", nameAr: "اليوم الوطني ٩٣", category: "National Day",
                 previewColors: [Color(hex: "004225"), Color(hex: "E8D64B")], isPro: false, aspectRatio: 1.0, tags: ["national", "saudi"]),
        
        // Graduation
        Template(name: "Graduation Cap", nameAr: "قبعة تخرج", category: "Graduation",
                 previewColors: [Color(hex: "0D47A1"), Color(hex: "FFD700")], isPro: false, aspectRatio: 1.0, tags: ["graduation", "academic"]),
        Template(name: "Grad Congrats", nameAr: "مبروك التخرج", category: "Graduation",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "FFD700")], isPro: true, aspectRatio: 1.0, tags: ["graduation", "congrats"]),
        
        // TikTok
        Template(name: "TikTok Viral", nameAr: "تيك توك فايرال", category: "TikTok",
                 previewColors: [Color(hex: "010101"), Color(hex: "69C9D0"), Color(hex: "EE1D52")], isPro: false, aspectRatio: 0.5625, tags: ["tiktok", "viral"]),
        Template(name: "TikTok Dark", nameAr: "تيك توك داكن", category: "TikTok",
                 previewColors: [Color(hex: "0A0A0A"), Color(hex: "161823")], isPro: true, aspectRatio: 0.5625, tags: ["tiktok", "dark"]),
        
        // Logo
        Template(name: "Modern Logo", nameAr: "شعار حديث", category: "Logo",
                 previewColors: [Color(hex: "1A1A2E"), Color(hex: "D4A853")], isPro: true, aspectRatio: 1.0, tags: ["logo", "modern"]),
        Template(name: "Simple Logo", nameAr: "شعار بسيط", category: "Logo",
                 previewColors: [Color(hex: "FFFFFF"), Color(hex: "333333")], isPro: false, aspectRatio: 1.0, tags: ["logo", "simple"]),
        
        // WhatsApp
        Template(name: "WhatsApp Status", nameAr: "حالة واتساب", category: "WhatsApp",
                 previewColors: [Color(hex: "075E54"), Color(hex: "25D366")], isPro: false, aspectRatio: 0.5625, tags: ["whatsapp", "status"]),
        
        // Snapchat
        Template(name: "Snap Filter", nameAr: "فلتر سناب", category: "Snapchat",
                 previewColors: [Color(hex: "FFFC00"), Color(hex: "FF6600")], isPro: false, aspectRatio: 0.5625, tags: ["snapchat", "filter"]),
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
        CanvasPreset(name: "Instagram Post", nameAr: "بوست انستغرام", icon: "square", width: 1080, height: 1080),
        CanvasPreset(name: "Instagram Story", nameAr: "ستوري انستغرام", icon: "rectangle.portrait", width: 1080, height: 1920),
        CanvasPreset(name: "Facebook Post", nameAr: "بوست فيسبوك", icon: "rectangle", width: 1200, height: 630),
        CanvasPreset(name: "TikTok Video", nameAr: "فيديو تيك توك", icon: "play.rectangle", width: 1080, height: 1920),
        CanvasPreset(name: "Snapchat", nameAr: "سناب شات", icon: "camera.viewfinder", width: 1080, height: 1920),
        CanvasPreset(name: "WhatsApp Status", nameAr: "حالة واتساب", icon: "message", width: 1080, height: 1920),
        CanvasPreset(name: "Twitter Post", nameAr: "بوست تويتر", icon: "text.bubble", width: 1600, height: 900),
        CanvasPreset(name: "YouTube Thumb", nameAr: "صورة يوتيوب", icon: "play.rectangle.fill", width: 1280, height: 720),
        CanvasPreset(name: "Logo", nameAr: "شعار", icon: "crown", width: 1000, height: 1000),
        CanvasPreset(name: "A4 Portrait", nameAr: "A4 عمودي", icon: "doc", width: 2480, height: 3508),
        CanvasPreset(name: "Business Card", nameAr: "بطاقة عمل", icon: "rectangle.fill", width: 1050, height: 600),
    ]
}
