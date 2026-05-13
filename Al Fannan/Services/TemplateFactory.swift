import SwiftUI

/// Service that generates pre-designed template layouts for the canvas editor.
/// Each template creates a set of CanvasElements that form a complete design.
struct TemplateFactory {
    
    /// Load a template into the canvas ViewModel
    static func loadTemplate(_ template: Template, into viewModel: CanvasViewModel) {
        // Reset project identity — templates always create new projects
        viewModel.currentProjectId = nil
        viewModel.currentProjectName = template.nameAr
        
        // Set canvas dimensions based on template aspect ratio
        let baseSize: CGFloat = 1080
        if template.aspectRatio < 1 {
            viewModel.canvasWidth = baseSize
            viewModel.canvasHeight = baseSize / template.aspectRatio
        } else if template.aspectRatio > 1 {
            viewModel.canvasWidth = baseSize * template.aspectRatio
            viewModel.canvasHeight = baseSize
        } else {
            viewModel.canvasWidth = baseSize
            viewModel.canvasHeight = baseSize
        }
        
        // Clear existing elements
        viewModel.elements.removeAll()
        viewModel.selectedElementIds.removeAll()
        
        // Set background from template colors
        if template.previewColors.count >= 2 {
            viewModel.setBackgroundGradient(colors: template.previewColors)
        } else if let first = template.previewColors.first {
            viewModel.setBackground(color: first)
        }
        
        // Generate elements based on template category
        let elements = generateElements(for: template, canvasWidth: viewModel.canvasWidth, canvasHeight: viewModel.canvasHeight)
        for el in elements {
            viewModel.addElement(el)
        }
    }
    
    private static func generateElements(for template: Template, canvasWidth: CGFloat, canvasHeight: CGFloat) -> [CanvasElement] {
        let cx = canvasWidth / 2
        let cy = canvasHeight / 2
        
        switch template.category {
        case "Ramadan":
            return ramadanTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Eid":
            return eidTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Wedding":
            return weddingTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Business":
            return businessTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Instagram":
            return instagramTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Stories":
            return storyTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Quotes":
            return quoteTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Real Estate":
            return realEstateTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Sports":
            return sportsTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "National Day":
            return nationalDayTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Graduation":
            return graduationTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        case "Fashion":
            return fashionTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight)
        default:
            return genericTemplate(cx: cx, cy: cy, w: canvasWidth, h: canvasHeight, name: template.name, nameAr: template.nameAr)
        }
    }
    
    // MARK: - Template Generators
    
    private static func ramadanTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        // Moon sticker
        var moon = CanvasElement.stickerElement("moon.stars.fill")
        moon.position = CGPoint(x: cx, y: h * 0.2)
        moon.size = CGSize(width: 200, height: 200)
        elements.append(moon)
        
        // Main Arabic title
        var title = CanvasElement.textElement("رمضان كريم", isArabic: true)
        title.position = CGPoint(x: cx, y: cy - 40)
        title.size = CGSize(width: w * 0.8, height: 120)
        title.textStyle = TextStyle(fontName: "System", fontSize: 72, textColor: "#F0D48A",
                                    alignment: .center, isRTL: true, isBold: true,
                                    fillType: .gradient, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"])
        elements.append(title)
        
        // English subtitle
        var subtitle = CanvasElement.textElement("Ramadan Kareem", isArabic: false)
        subtitle.position = CGPoint(x: cx, y: cy + 60)
        subtitle.size = CGSize(width: w * 0.6, height: 50)
        subtitle.textStyle = TextStyle(fontName: "System", fontSize: 28, textColor: "#FFFFFF",
                                       alignment: .center, isBold: false)
        elements.append(subtitle)
        
        // Star decorations
        for i in 0..<3 {
            var star = CanvasElement.stickerElement("star.fill")
            star.position = CGPoint(x: w * 0.2 + CGFloat(i) * w * 0.3, y: h * 0.75)
            star.size = CGSize(width: 40, height: 40)
            star.opacity = 0.4
            elements.append(star)
        }
        
        // Bottom text
        var bottom = CanvasElement.textElement("كل عام وأنتم بخير", isArabic: true)
        bottom.position = CGPoint(x: cx, y: h * 0.85)
        bottom.size = CGSize(width: w * 0.7, height: 40)
        bottom.textStyle = TextStyle(fontName: "System", fontSize: 22, textColor: "#D4A853",
                                     alignment: .center, isRTL: true)
        elements.append(bottom)
        
        return elements
    }
    
    private static func eidTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var title = CanvasElement.textElement("عيد مبارك", isArabic: true)
        title.position = CGPoint(x: cx, y: cy - 60)
        title.size = CGSize(width: w * 0.8, height: 120)
        title.textStyle = TextStyle(fontName: "System", fontSize: 80, textColor: "#F0D48A",
                                    alignment: .center, isRTL: true, isBold: true,
                                    fillType: .gradient, gradientColors: ["#FFD700", "#F0D48A", "#FFD700"])
        elements.append(title)
        
        var sub = CanvasElement.textElement("Eid Mubarak", isArabic: false)
        sub.position = CGPoint(x: cx, y: cy + 40)
        sub.size = CGSize(width: w * 0.5, height: 40)
        sub.textStyle = TextStyle(fontName: "System", fontSize: 24, textColor: "#FFFFFF", alignment: .center)
        elements.append(sub)
        
        var sparkle = CanvasElement.stickerElement("sparkles")
        sparkle.position = CGPoint(x: cx, y: h * 0.2)
        sparkle.size = CGSize(width: 120, height: 120)
        elements.append(sparkle)
        
        var msg = CanvasElement.textElement("تقبل الله منا ومنكم", isArabic: true)
        msg.position = CGPoint(x: cx, y: h * 0.82)
        msg.size = CGSize(width: w * 0.7, height: 40)
        msg.textStyle = TextStyle(fontName: "System", fontSize: 20, textColor: "#F0D48A",
                                  alignment: .center, isRTL: true)
        elements.append(msg)
        
        return elements
    }
    
    private static func weddingTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var heart = CanvasElement.stickerElement("heart.fill")
        heart.position = CGPoint(x: cx, y: h * 0.15)
        heart.size = CGSize(width: 80, height: 80)
        elements.append(heart)
        
        var invite = CanvasElement.textElement("دعوة زفاف", isArabic: true)
        invite.position = CGPoint(x: cx, y: h * 0.28)
        invite.size = CGSize(width: w * 0.6, height: 50)
        invite.textStyle = TextStyle(fontName: "System", fontSize: 32, textColor: "#FF6B8A",
                                     alignment: .center, isRTL: true, isBold: true)
        elements.append(invite)
        
        var names = CanvasElement.textElement("محمد و سارة", isArabic: true)
        names.position = CGPoint(x: cx, y: cy)
        names.size = CGSize(width: w * 0.7, height: 80)
        names.textStyle = TextStyle(fontName: "System", fontSize: 56, textColor: "#FFFFFF",
                                    alignment: .center, isRTL: true, isBold: true,
                                    fillType: .gradient, gradientColors: ["#FF6B8A", "#FFB6C1", "#FF6B8A"])
        elements.append(names)
        
        var date = CanvasElement.textElement("يوم الجمعة ١٥ رمضان ١٤٤٧", isArabic: true)
        date.position = CGPoint(x: cx, y: cy + 80)
        date.size = CGSize(width: w * 0.7, height: 40)
        date.textStyle = TextStyle(fontName: "System", fontSize: 20, textColor: "#FFFFFF",
                                   alignment: .center, isRTL: true)
        elements.append(date)
        
        var venue = CanvasElement.textElement("فندق الريتز كارلتون - الرياض", isArabic: true)
        venue.position = CGPoint(x: cx, y: h * 0.75)
        venue.size = CGSize(width: w * 0.8, height: 36)
        venue.textStyle = TextStyle(fontName: "System", fontSize: 18, textColor: "#FFB6C1",
                                    alignment: .center, isRTL: true)
        elements.append(venue)
        
        return elements
    }
    
    private static func businessTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var logo = CanvasElement.stickerElement("building.2.fill")
        logo.position = CGPoint(x: w * 0.15, y: h * 0.35)
        logo.size = CGSize(width: 80, height: 80)
        elements.append(logo)
        
        var name = CanvasElement.textElement("شركة الخليج للاستثمار", isArabic: true)
        name.position = CGPoint(x: cx, y: h * 0.35)
        name.size = CGSize(width: w * 0.6, height: 50)
        name.textStyle = TextStyle(fontName: "System", fontSize: 28, textColor: "#FFFFFF",
                                   alignment: .leading, isRTL: true, isBold: true)
        elements.append(name)
        
        var person = CanvasElement.textElement("أحمد محمد العلي", isArabic: true)
        person.position = CGPoint(x: cx, y: h * 0.5)
        person.size = CGSize(width: w * 0.7, height: 40)
        person.textStyle = TextStyle(fontName: "System", fontSize: 22, textColor: "#5AC8FA",
                                     alignment: .center, isRTL: true)
        elements.append(person)
        
        var title = CanvasElement.textElement("المدير التنفيذي | CEO", isArabic: true)
        title.position = CGPoint(x: cx, y: h * 0.55)
        title.size = CGSize(width: w * 0.5, height: 30)
        title.textStyle = TextStyle(fontName: "System", fontSize: 14, textColor: "#AAAAAA",
                                    alignment: .center, isRTL: true)
        elements.append(title)
        
        // Divider line
        var line = CanvasElement(type: .shape, name: "Line",
                                 position: CGPoint(x: cx, y: h * 0.62),
                                 size: CGSize(width: w * 0.8, height: 2))
        line.shapeStyle = ShapeStyleData(shapeType: .rectangle, fillColor: "#5AC8FA")
        elements.append(line)
        
        var contact = CanvasElement.textElement("+966 55 123 4567\nahmed@gulf-invest.com", isArabic: false)
        contact.position = CGPoint(x: cx, y: h * 0.72)
        contact.size = CGSize(width: w * 0.7, height: 50)
        contact.textStyle = TextStyle(fontName: "System", fontSize: 14, textColor: "#CCCCCC",
                                      alignment: .center)
        elements.append(contact)
        
        return elements
    }
    
    private static func instagramTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var title = CanvasElement.textElement("عرض خاص", isArabic: true)
        title.position = CGPoint(x: cx, y: h * 0.3)
        title.size = CGSize(width: w * 0.7, height: 80)
        title.textStyle = TextStyle(fontName: "System", fontSize: 56, textColor: "#FFFFFF",
                                    alignment: .center, isRTL: true, isBold: true)
        elements.append(title)
        
        var discount = CanvasElement.textElement("50%", isArabic: false)
        discount.position = CGPoint(x: cx, y: cy + 20)
        discount.size = CGSize(width: w * 0.5, height: 120)
        discount.textStyle = TextStyle(fontName: "System", fontSize: 96, textColor: "#D4A853",
                                       alignment: .center, isBold: true,
                                       fillType: .gradient, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"])
        elements.append(discount)
        
        var cta = CanvasElement.textElement("تسوق الآن", isArabic: true)
        cta.position = CGPoint(x: cx, y: h * 0.75)
        cta.size = CGSize(width: 200, height: 50)
        cta.textStyle = TextStyle(fontName: "System", fontSize: 24, textColor: "#000000",
                                  alignment: .center, isRTL: true, isBold: true)
        elements.append(cta)
        
        // CTA background
        var ctaBg = CanvasElement(type: .shape, name: "CTA BG",
                                   position: CGPoint(x: cx, y: h * 0.75),
                                   size: CGSize(width: 220, height: 56))
        ctaBg.shapeStyle = ShapeStyleData(shapeType: .roundedRect, fillColor: "#D4A853", cornerRadius: 28)
        ctaBg.zIndex = -1
        elements.append(ctaBg)
        
        return elements
    }
    
    private static func storyTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var main = CanvasElement.textElement("أضف عنوانك هنا", isArabic: true)
        main.position = CGPoint(x: cx, y: h * 0.4)
        main.size = CGSize(width: w * 0.8, height: 80)
        main.textStyle = TextStyle(fontName: "System", fontSize: 48, textColor: "#FFFFFF",
                                   alignment: .center, isRTL: true, isBold: true)
        elements.append(main)
        
        var sub = CanvasElement.textElement("Add your subtitle here", isArabic: false)
        sub.position = CGPoint(x: cx, y: h * 0.48)
        sub.size = CGSize(width: w * 0.7, height: 30)
        sub.textStyle = TextStyle(fontName: "System", fontSize: 16, textColor: "#CCCCCC",
                                  alignment: .center)
        elements.append(sub)
        
        var swipe = CanvasElement.textElement("⬆ Swipe Up", isArabic: false)
        swipe.position = CGPoint(x: cx, y: h * 0.9)
        swipe.size = CGSize(width: 150, height: 30)
        swipe.textStyle = TextStyle(fontName: "System", fontSize: 14, textColor: "#FFFFFF",
                                    alignment: .center)
        elements.append(swipe)
        
        return elements
    }
    
    private static func quoteTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var quoteMark = CanvasElement.textElement("\"", isArabic: false)
        quoteMark.position = CGPoint(x: w * 0.15, y: h * 0.25)
        quoteMark.size = CGSize(width: 80, height: 120)
        quoteMark.textStyle = TextStyle(fontName: "System", fontSize: 120, textColor: "#D4A853",
                                        alignment: .center, isBold: true)
        quoteMark.opacity = 0.3
        elements.append(quoteMark)
        
        var quote = CanvasElement.textElement("إن مع العسر يسراً", isArabic: true)
        quote.position = CGPoint(x: cx, y: cy - 20)
        quote.size = CGSize(width: w * 0.75, height: 80)
        quote.textStyle = TextStyle(fontName: "System", fontSize: 42, textColor: "#FFFFFF",
                                    alignment: .center, isRTL: true, isBold: true)
        elements.append(quote)
        
        var source = CanvasElement.textElement("— سورة الشرح", isArabic: true)
        source.position = CGPoint(x: cx, y: cy + 60)
        source.size = CGSize(width: w * 0.5, height: 30)
        source.textStyle = TextStyle(fontName: "System", fontSize: 18, textColor: "#D4A853",
                                     alignment: .center, isRTL: true)
        elements.append(source)
        
        return elements
    }
    
    private static func realEstateTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        return genericTemplate(cx: cx, cy: cy, w: w, h: h, name: "للبيع - فيلا فاخرة", nameAr: "For Sale - Luxury Villa")
    }
    
    private static func sportsTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        return genericTemplate(cx: cx, cy: cy, w: w, h: h, name: "Game Day!", nameAr: "يوم المباراة")
    }
    
    private static func nationalDayTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var flag = CanvasElement.stickerElement("flag.fill")
        flag.position = CGPoint(x: cx, y: h * 0.2)
        flag.size = CGSize(width: 100, height: 100)
        elements.append(flag)
        
        var title = CanvasElement.textElement("اليوم الوطني", isArabic: true)
        title.position = CGPoint(x: cx, y: cy)
        title.size = CGSize(width: w * 0.8, height: 80)
        title.textStyle = TextStyle(fontName: "System", fontSize: 56, textColor: "#FFFFFF",
                                    alignment: .center, isRTL: true, isBold: true)
        elements.append(title)
        
        var sub = CanvasElement.textElement("National Day", isArabic: false)
        sub.position = CGPoint(x: cx, y: cy + 60)
        sub.size = CGSize(width: w * 0.5, height: 40)
        sub.textStyle = TextStyle(fontName: "System", fontSize: 24, textColor: "#00C851",
                                  alignment: .center, isBold: true)
        elements.append(sub)
        
        return elements
    }
    
    private static func graduationTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var cap = CanvasElement.stickerElement("graduationcap.fill")
        cap.position = CGPoint(x: cx, y: h * 0.2)
        cap.size = CGSize(width: 120, height: 120)
        elements.append(cap)
        
        var congrats = CanvasElement.textElement("مبروك التخرج!", isArabic: true)
        congrats.position = CGPoint(x: cx, y: cy)
        congrats.size = CGSize(width: w * 0.8, height: 80)
        congrats.textStyle = TextStyle(fontName: "System", fontSize: 48, textColor: "#FFD700",
                                       alignment: .center, isRTL: true, isBold: true)
        elements.append(congrats)
        
        var name = CanvasElement.textElement("اسم الخريج هنا", isArabic: true)
        name.position = CGPoint(x: cx, y: cy + 70)
        name.size = CGSize(width: w * 0.6, height: 40)
        name.textStyle = TextStyle(fontName: "System", fontSize: 24, textColor: "#FFFFFF",
                                   alignment: .center, isRTL: true)
        elements.append(name)
        
        return elements
    }
    
    private static func fashionTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        return genericTemplate(cx: cx, cy: cy, w: w, h: h, name: "New Collection", nameAr: "مجموعة جديدة")
    }
    
    private static func genericTemplate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat, name: String, nameAr: String) -> [CanvasElement] {
        var elements: [CanvasElement] = []
        
        var title = CanvasElement.textElement(nameAr, isArabic: true)
        title.position = CGPoint(x: cx, y: cy - 30)
        title.size = CGSize(width: w * 0.8, height: 80)
        title.textStyle = TextStyle(fontName: "System", fontSize: 48, textColor: "#FFFFFF",
                                    alignment: .center, isRTL: true, isBold: true)
        elements.append(title)
        
        var sub = CanvasElement.textElement(name, isArabic: false)
        sub.position = CGPoint(x: cx, y: cy + 40)
        sub.size = CGSize(width: w * 0.6, height: 40)
        sub.textStyle = TextStyle(fontName: "System", fontSize: 22, textColor: "#CCCCCC",
                                  alignment: .center)
        elements.append(sub)
        
        return elements
    }
}
