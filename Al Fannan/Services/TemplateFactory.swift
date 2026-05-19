
import SwiftUI

/// Service that generates pre-designed template layouts for the canvas editor.
/// Each template creates a layered composition of CanvasElements: background
/// motifs, decorative frames, then typography.
struct TemplateFactory {

    // MARK: - Brand Tokens
    private static let gold        = "#D4A853"
    private static let goldSoft    = "#F0D48A"
    private static let goldDeep    = "#A8842A"
    private static let white       = "#FFFFFF"
    private static let goldGradient   = ["#D4A853", "#F0D48A", "#D4A853"]
    private static let goldGradient3  = ["#A8842A", "#F0D48A", "#A8842A"]

    // MARK: - Public Entry Point
    static func loadTemplate(_ template: Template, into viewModel: CanvasViewModel) {
        viewModel.currentProjectId = nil
        viewModel.currentProjectName = template.nameAr

        let baseSize: CGFloat = 1080
        if template.aspectRatio < 1 {
            viewModel.canvasWidth  = baseSize
            viewModel.canvasHeight = baseSize / template.aspectRatio
        } else if template.aspectRatio > 1 {
            viewModel.canvasWidth  = baseSize * template.aspectRatio
            viewModel.canvasHeight = baseSize
        } else {
            viewModel.canvasWidth  = baseSize
            viewModel.canvasHeight = baseSize
        }

        viewModel.elements.removeAll()
        viewModel.selectedElementIds.removeAll()

        if template.previewColors.count >= 2 {
            viewModel.setBackgroundGradient(colors: template.previewColors)
        } else if let first = template.previewColors.first {
            viewModel.setBackground(color: first)
        }

        let w = viewModel.canvasWidth
        let h = viewModel.canvasHeight
        let elements = build(subKey: template.subKey, w: w, h: h)
        for el in elements { viewModel.addElement(el) }
    }

    // ════════════════════════════════════════════
    // MARK: - Builder Helpers
    // ════════════════════════════════════════════

    private static func makeText(
        _ text: String,
        at point: CGPoint,
        font: String,
        size: CGFloat,
        color: String = white,
        isArabic: Bool = true,
        bold: Bool = false,
        alignment: TextAlignmentOption = .center,
        gradient: [String]? = nil,
        shadow: Bool = false,
        opacity: Double = 1.0,
        rotation: Double = 0
    ) -> CanvasElement {
        var style = TextStyle(
            fontName: font,
            fontSize: size,
            textColor: color,
            alignment: alignment,
            isRTL: isArabic,
            isBold: bold
        )
        if let g = gradient {
            style.fillType = .gradient
            style.gradientColors = g
            style.gradientAngle = 90
        }
        if shadow {
            style.shadowEnabled = true
            style.shadowColor = "#000000"
            style.shadowRadius = 8
        }
        let measured = CanvasElement.measureText(text, style: style)
        var el = CanvasElement(type: .text, name: "Text", position: point, size: measured)
        el.text = text
        el.textStyle = style
        el.opacity = opacity
        el.rotation = rotation
        return el
    }

    private static func makeDivider(at point: CGPoint, width: CGFloat, height: CGFloat = 2, color: String = "#D4A853", opacity: Double = 1.0) -> CanvasElement {
        var line = CanvasElement(type: .shape, name: "Line", position: point, size: CGSize(width: width, height: height))
        line.shapeStyle = ShapeStyleData(shapeType: .rectangle, fillColor: color)
        line.opacity = opacity
        return line
    }

    /// A double-line divider — two thin parallel lines stacked.
    private static func makeDoubleDivider(at point: CGPoint, width: CGFloat, gap: CGFloat = 8, color: String = "#D4A853") -> [CanvasElement] {
        [
            makeDivider(at: CGPoint(x: point.x, y: point.y - gap/2), width: width, height: 2, color: color),
            makeDivider(at: CGPoint(x: point.x, y: point.y + gap/2), width: width, height: 2, color: color),
        ]
    }

    private static func makeSticker(_ symbol: String, at point: CGPoint, size: CGFloat, opacity: Double = 1.0, rotation: Double = 0) -> CanvasElement {
        var s = CanvasElement.stickerElement(symbol)
        s.position = point
        s.size = CGSize(width: size, height: size)
        s.opacity = opacity
        s.rotation = rotation
        return s
    }

    /// A large faded background motif (sticker) — sits behind everything else.
    private static func backgroundMotif(_ symbol: String, at point: CGPoint, size: CGFloat, opacity: Double = 0.08) -> CanvasElement {
        makeSticker(symbol, at: point, size: size, opacity: opacity)
    }

    /// A circular gold ring (frame accent).
    private static func makeRing(at point: CGPoint, diameter: CGFloat, color: String = "#D4A853", opacity: Double = 1.0) -> CanvasElement {
        var el = CanvasElement(type: .shape, name: "Ring", position: point, size: CGSize(width: diameter, height: diameter))
        el.shapeStyle = ShapeStyleData(shapeType: .ring, fillColor: color, strokeColor: color, strokeWidth: 4)
        el.opacity = opacity
        return el
    }

    /// A filled diamond ornament.
    private static func makeDiamond(at point: CGPoint, size: CGFloat, color: String = "#D4A853", opacity: Double = 1.0) -> CanvasElement {
        var el = CanvasElement(type: .shape, name: "Diamond", position: point, size: CGSize(width: size, height: size))
        el.shapeStyle = ShapeStyleData(shapeType: .diamond, fillColor: color)
        el.opacity = opacity
        return el
    }

    /// A small filled circle dot.
    private static func makeDot(at point: CGPoint, diameter: CGFloat, color: String = "#D4A853", opacity: Double = 1.0) -> CanvasElement {
        var el = CanvasElement(type: .shape, name: "Dot", position: point, size: CGSize(width: diameter, height: diameter))
        el.shapeStyle = ShapeStyleData(shapeType: .circle, fillColor: color)
        el.opacity = opacity
        return el
    }

    /// A decorative divider: gold dot ─── diamond ─── gold dot, centered.
    private static func ornamentDivider(at point: CGPoint, width: CGFloat, color: String = "#D4A853") -> [CanvasElement] {
        let halfWidth = width / 2
        let lineWidth = (width - 60) / 2
        return [
            makeDivider(at: CGPoint(x: point.x - halfWidth + lineWidth/2, y: point.y), width: lineWidth, color: color),
            makeDiamond(at: point, size: 14, color: color),
            makeDivider(at: CGPoint(x: point.x + halfWidth - lineWidth/2, y: point.y), width: lineWidth, color: color),
            makeDot(at: CGPoint(x: point.x - halfWidth + lineWidth + 18, y: point.y), diameter: 6, color: color),
            makeDot(at: CGPoint(x: point.x + halfWidth - lineWidth - 18, y: point.y), diameter: 6, color: color),
        ]
    }

    /// A rectangular outline frame inset from the canvas edges.
    private static func makeFrame(canvasW: CGFloat, canvasH: CGFloat, inset: CGFloat, thickness: CGFloat = 3, color: String = "#D4A853", opacity: Double = 1.0) -> [CanvasElement] {
        let cx = canvasW / 2
        let cy = canvasH / 2
        let w = canvasW - 2 * inset
        let h = canvasH - 2 * inset
        let top    = makeDivider(at: CGPoint(x: cx, y: inset), width: w, height: thickness, color: color, opacity: opacity)
        let bottom = makeDivider(at: CGPoint(x: cx, y: canvasH - inset), width: w, height: thickness, color: color, opacity: opacity)
        var left  = CanvasElement(type: .shape, name: "Frame L", position: CGPoint(x: inset, y: cy), size: CGSize(width: thickness, height: h))
        left.shapeStyle = ShapeStyleData(shapeType: .rectangle, fillColor: color)
        left.opacity = opacity
        var right = CanvasElement(type: .shape, name: "Frame R", position: CGPoint(x: canvasW - inset, y: cy), size: CGSize(width: thickness, height: h))
        right.shapeStyle = ShapeStyleData(shapeType: .rectangle, fillColor: color)
        right.opacity = opacity
        return [top, bottom, left, right]
    }

    /// Four diamond corner accents at the corners of a frame.
    private static func cornerDiamonds(canvasW: CGFloat, canvasH: CGFloat, inset: CGFloat, size: CGFloat = 22, color: String = "#D4A853") -> [CanvasElement] {
        [
            makeDiamond(at: CGPoint(x: inset, y: inset), size: size, color: color),
            makeDiamond(at: CGPoint(x: canvasW - inset, y: inset), size: size, color: color),
            makeDiamond(at: CGPoint(x: inset, y: canvasH - inset), size: size, color: color),
            makeDiamond(at: CGPoint(x: canvasW - inset, y: canvasH - inset), size: size, color: color),
        ]
    }

    /// A pill-shaped (rounded rectangle) badge with optional border.
    private static func makeBadge(at point: CGPoint, width: CGFloat, height: CGFloat, fillColor: String, cornerRadius: CGFloat = 28, opacity: Double = 1.0) -> CanvasElement {
        var el = CanvasElement(type: .shape, name: "Badge", position: point, size: CGSize(width: width, height: height))
        el.shapeStyle = ShapeStyleData(shapeType: .roundedRect, fillColor: fillColor, cornerRadius: cornerRadius)
        el.opacity = opacity
        return el
    }

    // ════════════════════════════════════════════
    // MARK: - Dispatcher
    // ════════════════════════════════════════════

    private static func build(subKey: String, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        let cx = w / 2
        let cy = h / 2
        switch subKey {
        case "ramadan_kareem":   return ramadanKareem(cx: cx, cy: cy, w: w, h: h)
        case "ramadan_greeting": return ramadanGreeting(cx: cx, cy: cy, w: w, h: h)
        case "ramadan_iftar":    return ramadanIftar(cx: cx, cy: cy, w: w, h: h)
        case "ramadan_suhoor":   return ramadanSuhoor(cx: cx, cy: cy, w: w, h: h)
        case "eid_mubarak_gold": return eidMubarakGold(cx: cx, cy: cy, w: w, h: h)
        case "eid_fitr":         return eidFitr(cx: cx, cy: cy, w: w, h: h)
        case "eid_adha":         return eidAdha(cx: cx, cy: cy, w: w, h: h)
        case "eid_greeting":     return eidGreeting(cx: cx, cy: cy, w: w, h: h)
        case "wedding_classic":     return weddingClassic(cx: cx, cy: cy, w: w, h: h)
        case "wedding_save_date":   return weddingSaveDate(cx: cx, cy: cy, w: w, h: h)
        case "wedding_engagement":  return weddingEngagement(cx: cx, cy: cy, w: w, h: h)
        case "wedding_thanks":      return weddingThanks(cx: cx, cy: cy, w: w, h: h)
        case "business_card":         return businessCard(cx: cx, cy: cy, w: w, h: h)
        case "business_quote":        return businessQuote(cx: cx, cy: cy, w: w, h: h)
        case "business_announcement": return businessAnnouncement(cx: cx, cy: cy, w: w, h: h)
        case "business_contact":      return businessContact(cx: cx, cy: cy, w: w, h: h)
        case "quote_quran":      return quoteQuran(cx: cx, cy: cy, w: w, h: h)
        case "quote_hadith":     return quoteHadith(cx: cx, cy: cy, w: w, h: h)
        case "quote_proverb":    return quoteProverb(cx: cx, cy: cy, w: w, h: h)
        case "quote_motivation": return quoteMotivation(cx: cx, cy: cy, w: w, h: h)
        default:                 return []
        }
    }

    // ════════════════════════════════════════════
    // MARK: Ramadan
    // ════════════════════════════════════════════

    private static func ramadanKareem(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Background motif
        els.append(backgroundMotif("moon.stars.fill", at: CGPoint(x: cx, y: cy), size: w * 0.95, opacity: 0.06))
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 60, thickness: 2, color: gold, opacity: 0.85))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 60, size: 24, color: gold))
        // Top crescent
        els.append(makeSticker("moon.stars.fill", at: CGPoint(x: cx, y: h * 0.20), size: 140, opacity: 0.95))
        // Small ornament dots
        els.append(makeDot(at: CGPoint(x: cx - 130, y: h * 0.20), diameter: 8, opacity: 0.7))
        els.append(makeDot(at: CGPoint(x: cx + 130, y: h * 0.20), diameter: 8, opacity: 0.7))
        // Headline
        els.append(makeText("رمضان كريم", at: CGPoint(x: cx, y: cy - 20),
                            font: "ArefRuqaa-Regular", size: 200, gradient: goldGradient3, shadow: true))
        // English subtitle
        els.append(makeText("RAMADAN KAREEM", at: CGPoint(x: cx, y: cy + 110),
                            font: "Cairo-Regular", size: 44, color: white, isArabic: false, bold: true))
        // Ornament divider
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 170), width: w * 0.45))
        // Bottom blessing
        els.append(makeText("كل عام وأنتم بخير", at: CGPoint(x: cx, y: h * 0.82),
                            font: "Amiri-Regular", size: 56, color: goldSoft))
        return els
    }

    private static func ramadanGreeting(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        els.append(backgroundMotif("sparkles", at: CGPoint(x: cx, y: cy), size: w * 0.85, opacity: 0.05))
        // Side sparkle accents
        els.append(makeSticker("sparkle", at: CGPoint(x: w * 0.18, y: h * 0.18), size: 60, opacity: 0.5))
        els.append(makeSticker("sparkle", at: CGPoint(x: w * 0.82, y: h * 0.18), size: 60, opacity: 0.5))
        els.append(makeSticker("sparkle", at: CGPoint(x: w * 0.18, y: h * 0.82), size: 50, opacity: 0.5))
        els.append(makeSticker("sparkle", at: CGPoint(x: w * 0.82, y: h * 0.82), size: 50, opacity: 0.5))
        // Decorative top crescent inside a ring
        els.append(makeRing(at: CGPoint(x: cx, y: h * 0.22), diameter: 180, opacity: 0.6))
        els.append(makeSticker("moon.fill", at: CGPoint(x: cx, y: h * 0.22), size: 90, opacity: 0.95))
        // Headline
        els.append(makeText("أهلاً رمضان", at: CGPoint(x: cx, y: cy + 20),
                            font: "Amiri-Bold", size: 220, gradient: goldGradient3, shadow: true))
        // Subtitle
        els.append(makeText("شهر الرحمة والمغفرة", at: CGPoint(x: cx, y: cy + 150),
                            font: "Amiri-Regular", size: 58, color: white))
        // Bottom ornament
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.86), width: w * 0.5))
        els.append(makeText("تقبل الله صيامكم وقيامكم", at: CGPoint(x: cx, y: h * 0.92),
                            font: "Amiri-Regular", size: 44, color: goldSoft))
        return els
    }

    private static func ramadanIftar(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 50, thickness: 2, color: goldSoft, opacity: 0.7))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 50, size: 20, color: gold))
        // Top motif: pair of small crescents flanking a sparkle
        els.append(makeSticker("moon.fill", at: CGPoint(x: cx - 70, y: h * 0.14), size: 38, opacity: 0.9, rotation: -20))
        els.append(makeSticker("sparkles", at: CGPoint(x: cx, y: h * 0.14), size: 50, opacity: 0.95))
        els.append(makeSticker("moon.fill", at: CGPoint(x: cx + 70, y: h * 0.14), size: 38, opacity: 0.9, rotation: 20))
        // Header
        els.append(makeText("دعوة إفطار", at: CGPoint(x: cx, y: h * 0.22),
                            font: "ArefRuqaa-Regular", size: 90, color: gold, bold: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.29), width: w * 0.35))
        // Body
        els.append(makeText("يسرنا دعوتكم لتناول", at: CGPoint(x: cx, y: h * 0.37),
                            font: "Amiri-Regular", size: 50, color: white))
        els.append(makeText("طعام الإفطار", at: CGPoint(x: cx, y: cy + 10),
                            font: "Amiri-Bold", size: 150, gradient: goldGradient3, shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 110), width: w * 0.3))
        // Date badge
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.74), width: w * 0.5, height: 70, fillColor: gold, cornerRadius: 35, opacity: 0.18))
        els.append(makeText("الجمعة ١٥ رمضان", at: CGPoint(x: cx, y: h * 0.74),
                            font: "Cairo-Regular", size: 52, color: goldSoft, bold: true))
        els.append(makeText("بعد صلاة المغرب", at: CGPoint(x: cx, y: h * 0.83),
                            font: "Amiri-Regular", size: 42, color: white))
        els.append(makeText("منزل العائلة الكريمة", at: CGPoint(x: cx, y: h * 0.90),
                            font: "Amiri-Regular", size: 38, color: goldSoft))
        return els
    }

    private static func ramadanSuhoor(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Large background moon
        els.append(backgroundMotif("moon.fill", at: CGPoint(x: w * 0.85, y: h * 0.18), size: w * 0.55, opacity: 0.08))
        els.append(backgroundMotif("star.fill", at: CGPoint(x: w * 0.15, y: h * 0.30), size: w * 0.10, opacity: 0.10))
        els.append(backgroundMotif("star.fill", at: CGPoint(x: w * 0.20, y: h * 0.78), size: w * 0.06, opacity: 0.10))
        // Foreground moon
        els.append(makeSticker("moon.stars.fill", at: CGPoint(x: cx, y: h * 0.22), size: 130, opacity: 0.95))
        // Headline
        els.append(makeText("لا تنسوا السحور", at: CGPoint(x: cx, y: cy - 20),
                            font: "Amiri-Bold", size: 160, gradient: goldGradient3, shadow: true))
        // Hadith
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 70), width: w * 0.4))
        els.append(makeText("«تسحروا فإن في السحور بركة»", at: CGPoint(x: cx, y: cy + 130),
                            font: "Amiri-Regular", size: 50, color: white))
        els.append(makeText("— رواه البخاري", at: CGPoint(x: cx, y: cy + 200),
                            font: "Amiri-Regular", size: 38, color: goldSoft))
        return els
    }

    // ════════════════════════════════════════════
    // MARK: Eid
    // ════════════════════════════════════════════

    private static func eidMubarakGold(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Background motif (large faded star)
        els.append(backgroundMotif("star.fill", at: CGPoint(x: cx, y: cy), size: w * 0.90, opacity: 0.05))
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 55, thickness: 2, color: gold, opacity: 0.7))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 55, size: 22, color: gold))
        // Top sparkles cluster
        els.append(makeSticker("sparkles", at: CGPoint(x: w * 0.25, y: h * 0.20), size: 70, opacity: 0.7))
        els.append(makeSticker("sparkle", at: CGPoint(x: cx, y: h * 0.15), size: 50, opacity: 0.8))
        els.append(makeSticker("sparkles", at: CGPoint(x: w * 0.75, y: h * 0.20), size: 70, opacity: 0.7))
        // Headline
        els.append(makeText("عيد مبارك", at: CGPoint(x: cx, y: cy - 10),
                            font: "ArefRuqaa-Regular", size: 230, gradient: goldGradient3, shadow: true))
        // English
        els.append(makeText("EID MUBARAK", at: CGPoint(x: cx, y: cy + 120),
                            font: "Cairo-Regular", size: 46, color: white, isArabic: false, bold: true))
        // Bottom ornament
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.84), width: w * 0.45))
        els.append(makeText("تقبل الله منا ومنكم صالح الأعمال", at: CGPoint(x: cx, y: h * 0.90),
                            font: "Amiri-Regular", size: 42, color: goldSoft))
        return els
    }

    private static func eidFitr(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Background ring
        els.append(makeRing(at: CGPoint(x: cx, y: cy - 30), diameter: w * 0.78, opacity: 0.2))
        els.append(makeRing(at: CGPoint(x: cx, y: cy - 30), diameter: w * 0.68, opacity: 0.35))
        // Top label
        els.append(makeText("عيد الفطر", at: CGPoint(x: cx, y: h * 0.22),
                            font: "ArefRuqaa-Regular", size: 75, color: goldSoft))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.30), width: w * 0.3))
        // Big word inside the rings
        els.append(makeText("سعيد", at: CGPoint(x: cx, y: cy - 30),
                            font: "Amiri-Bold", size: 280, gradient: goldGradient3, shadow: true))
        // Bottom
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.74), width: w * 0.4))
        els.append(makeText("كل عام وأنتم بخير", at: CGPoint(x: cx, y: h * 0.81),
                            font: "Amiri-Regular", size: 54, color: white))
        els.append(makeText("Happy Eid al-Fitr", at: CGPoint(x: cx, y: h * 0.89),
                            font: "Cairo-Regular", size: 36, color: goldSoft, isArabic: false))
        return els
    }

    private static func eidAdha(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 60, thickness: 2, color: gold, opacity: 0.6))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 60, size: 22, color: gold))
        // Top crescent + small star ornaments
        els.append(makeSticker("moon.stars.fill", at: CGPoint(x: cx, y: h * 0.20), size: 130, opacity: 0.95))
        els.append(makeDot(at: CGPoint(x: cx - 160, y: h * 0.20), diameter: 10, opacity: 0.7))
        els.append(makeDot(at: CGPoint(x: cx + 160, y: h * 0.20), diameter: 10, opacity: 0.7))
        // Title
        els.append(makeText("عيد الأضحى", at: CGPoint(x: cx, y: cy - 40),
                            font: "ArefRuqaa-Regular", size: 200, gradient: goldGradient3, shadow: true))
        // Accent word
        els.append(makeText("المبارك", at: CGPoint(x: cx, y: cy + 100),
                            font: "Amiri-Bold", size: 130, color: goldSoft, bold: true))
        // Bottom
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.82), width: w * 0.4))
        els.append(makeText("تقبل الله طاعاتكم", at: CGPoint(x: cx, y: h * 0.88),
                            font: "Amiri-Regular", size: 50, color: white))
        return els
    }

    private static func eidGreeting(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Background sparkle cluster
        els.append(backgroundMotif("sparkles", at: CGPoint(x: w * 0.20, y: h * 0.25), size: w * 0.25, opacity: 0.08))
        els.append(backgroundMotif("sparkles", at: CGPoint(x: w * 0.80, y: h * 0.75), size: w * 0.25, opacity: 0.08))
        // Top label
        els.append(makeText("بطاقة معايدة", at: CGPoint(x: cx, y: h * 0.16),
                            font: "Cairo-Regular", size: 48, color: goldSoft))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.22), width: w * 0.30))
        // First headline (smaller, contrasting)
        els.append(makeText("كل عام", at: CGPoint(x: cx, y: cy - 130),
                            font: "Amiri-Bold", size: 140, color: white))
        // Second headline (large gradient)
        els.append(makeText("وأنتم بخير", at: CGPoint(x: cx, y: cy + 30),
                            font: "ArefRuqaa-Regular", size: 200, gradient: goldGradient3, shadow: true))
        // Bottom ornament
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.82), width: w * 0.35))
        els.append(makeText("مع أطيب التهاني", at: CGPoint(x: cx, y: h * 0.88),
                            font: "Amiri-Regular", size: 48, color: goldSoft))
        return els
    }

    // ════════════════════════════════════════════
    // MARK: Wedding
    // ════════════════════════════════════════════

    private static func weddingClassic(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let rose = "#C9A96E"
        // Outer + inner frame for elegance
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 50, thickness: 2, color: rose, opacity: 0.8))
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 65, thickness: 1, color: rose, opacity: 0.4))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 50, size: 20, color: rose))
        // Top label
        els.append(makeText("دعوة زفاف", at: CGPoint(x: cx, y: h * 0.16),
                            font: "Cairo-Regular", size: 48, color: rose))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.22), width: w * 0.32, color: rose))
        // Intro
        els.append(makeText("يسعدنا دعوتكم لحضور حفل زفاف", at: CGPoint(x: cx, y: h * 0.30),
                            font: "Amiri-Regular", size: 44, color: white))
        // Names
        els.append(makeText("محمد و سارة", at: CGPoint(x: cx, y: cy + 20),
                            font: "ArefRuqaa-Regular", size: 200,
                            gradient: ["#C9A96E", "#F0D48A", "#C9A96E"], shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 125), width: w * 0.3, color: rose))
        // Date
        els.append(makeText("الجمعة ١٥ رمضان ١٤٤٧ هـ", at: CGPoint(x: cx, y: h * 0.79),
                            font: "Cairo-Regular", size: 42, color: white, bold: true))
        els.append(makeText("فندق الريتز كارلتون · الرياض", at: CGPoint(x: cx, y: h * 0.87),
                            font: "Amiri-Regular", size: 38, color: goldSoft))
        return els
    }

    private static func weddingSaveDate(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let blush = "#F4C2C2"
        // Background hearts faded
        els.append(backgroundMotif("heart.fill", at: CGPoint(x: w * 0.18, y: h * 0.30), size: 120, opacity: 0.07))
        els.append(backgroundMotif("heart.fill", at: CGPoint(x: w * 0.85, y: h * 0.75), size: 100, opacity: 0.07))
        // Top heart inside ring
        els.append(makeRing(at: CGPoint(x: cx, y: h * 0.18), diameter: 140, color: blush, opacity: 0.7))
        els.append(makeSticker("heart.fill", at: CGPoint(x: cx, y: h * 0.18), size: 72, opacity: 0.95))
        // English header
        els.append(makeText("Save the Date", at: CGPoint(x: cx, y: h * 0.32),
                            font: "Cairo-Regular", size: 56, color: blush, isArabic: false, bold: true))
        // Arabic headline
        els.append(makeText("احفظ التاريخ", at: CGPoint(x: cx, y: cy + 30),
                            font: "ArefRuqaa-Regular", size: 200,
                            gradient: ["#F4C2C2", "#FFD1DC", "#F4C2C2"], shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 150), width: w * 0.35, color: blush))
        // Date badge
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.80), width: w * 0.6, height: 90, fillColor: blush, cornerRadius: 45, opacity: 0.15))
        els.append(makeText("١٥ · ٠٧ · ٢٠٢٦", at: CGPoint(x: cx, y: h * 0.80),
                            font: "Cairo-Regular", size: 72, color: white, isArabic: false, bold: true))
        // Footer
        els.append(makeText("التفاصيل قريباً", at: CGPoint(x: cx, y: h * 0.90),
                            font: "Amiri-Regular", size: 40, color: blush))
        return els
    }

    private static func weddingEngagement(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let pink = "#FFB6C1"
        // Background sparkles
        els.append(backgroundMotif("sparkles", at: CGPoint(x: cx, y: cy), size: w * 0.7, opacity: 0.06))
        // Top: small heart between two diamonds
        els.append(makeDiamond(at: CGPoint(x: cx - 80, y: h * 0.18), size: 14, color: pink))
        els.append(makeSticker("heart.fill", at: CGPoint(x: cx, y: h * 0.18), size: 70, opacity: 0.95))
        els.append(makeDiamond(at: CGPoint(x: cx + 80, y: h * 0.18), size: 14, color: pink))
        // Big headline
        els.append(makeText("خطوبة", at: CGPoint(x: cx, y: cy - 80),
                            font: "ArefRuqaa-Regular", size: 230,
                            gradient: ["#FFB6C1", "#FFC9D6", "#FFB6C1"], shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 30), width: w * 0.3, color: pink))
        // Body
        els.append(makeText("بمشيئة الله نُعلن عن خطوبة", at: CGPoint(x: cx, y: cy + 90),
                            font: "Amiri-Regular", size: 48, color: white))
        // Names
        els.append(makeText("أحمد و نورا", at: CGPoint(x: cx, y: h * 0.82),
                            font: "Amiri-Bold", size: 110, color: white, bold: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.92), width: w * 0.25, color: pink))
        return els
    }

    private static func weddingThanks(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let rose = "#C9A96E"
        let textBrown = "#5C3A21"
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 55, thickness: 2, color: rose, opacity: 0.7))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 55, size: 22, color: rose))
        // Top motif
        els.append(makeRing(at: CGPoint(x: cx, y: h * 0.20), diameter: 150, color: rose, opacity: 0.6))
        els.append(makeSticker("heart.fill", at: CGPoint(x: cx, y: h * 0.20), size: 80, opacity: 0.95))
        // Headline
        els.append(makeText("شكراً لكم", at: CGPoint(x: cx, y: cy + 10),
                            font: "ArefRuqaa-Regular", size: 230,
                            gradient: ["#C9A96E", "#F0D48A", "#C9A96E"], shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 130), width: w * 0.35, color: rose))
        // Body
        els.append(makeText("على حضوركم وتشريفكم", at: CGPoint(x: cx, y: h * 0.78),
                            font: "Amiri-Regular", size: 48, color: textBrown))
        els.append(makeText("Thank You for Joining Us", at: CGPoint(x: cx, y: h * 0.87),
                            font: "Cairo-Regular", size: 38, color: "#8B6B3F", isArabic: false))
        return els
    }

    // ════════════════════════════════════════════
    // MARK: Business
    // ════════════════════════════════════════════

    private static func businessCard(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let blue = "#5AC8FA"
        // Left accent bar
        els.append(makeDivider(at: CGPoint(x: 20, y: cy), width: 6, height: h * 0.7, color: blue))
        // Company name
        els.append(makeText("شركة الخليج", at: CGPoint(x: cx, y: h * 0.20),
                            font: "Cairo-Regular", size: 78, color: blue, bold: true))
        els.append(makeText("للاستثمار", at: CGPoint(x: cx, y: h * 0.30),
                            font: "Cairo-Regular", size: 56, color: white))
        // Underline
        els.append(makeDivider(at: CGPoint(x: cx, y: h * 0.38), width: w * 0.3, height: 2, color: blue))
        // Person
        els.append(makeText("أحمد محمد العلي", at: CGPoint(x: cx, y: cy + 30),
                            font: "Amiri-Bold", size: 90, color: white, bold: true))
        els.append(makeText("المدير التنفيذي · CEO", at: CGPoint(x: cx, y: cy + 115),
                            font: "Cairo-Regular", size: 42, color: blue))
        // Bottom badge with contact
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.85), width: w * 0.8, height: 130, fillColor: blue, cornerRadius: 16, opacity: 0.10))
        els.append(makeDivider(at: CGPoint(x: cx, y: h * 0.78), width: w * 0.5, height: 1, color: blue, opacity: 0.5))
        els.append(makeText("+966 55 123 4567", at: CGPoint(x: cx, y: h * 0.83),
                            font: "Cairo-Regular", size: 40, color: white, isArabic: false))
        els.append(makeText("ahmed@gulf-invest.com", at: CGPoint(x: cx, y: h * 0.90),
                            font: "Cairo-Regular", size: 34, color: "#AAB7C4", isArabic: false))
        return els
    }

    private static func businessQuote(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Giant background quote marks
        els.append(makeText("\u{201C}", at: CGPoint(x: w * 0.18, y: h * 0.30),
                            font: "Cairo-Regular", size: 320, color: gold, isArabic: false, opacity: 0.18))
        els.append(makeText("\u{201D}", at: CGPoint(x: w * 0.82, y: h * 0.70),
                            font: "Cairo-Regular", size: 320, color: gold, isArabic: false, opacity: 0.18))
        // Top label
        els.append(makeText("اقتباس اليوم", at: CGPoint(x: cx, y: h * 0.18),
                            font: "Cairo-Regular", size: 46, color: gold))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.24), width: w * 0.25))
        // Quote
        els.append(makeText("«النجاح هو الانتقال من فشل إلى فشل دون أن تفقد حماسك»",
                            at: CGPoint(x: cx, y: cy),
                            font: "Amiri-Bold", size: 100, color: white, bold: true))
        // Author
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.78), width: w * 0.25))
        els.append(makeText("ونستون تشرشل", at: CGPoint(x: cx, y: h * 0.85),
                            font: "Amiri-Regular", size: 46, color: gold))
        return els
    }

    private static func businessAnnouncement(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let orange = "#FF6B35"
        // Top accent stripe
        els.append(makeDivider(at: CGPoint(x: cx, y: 60), width: w, height: 10, color: orange))
        // Label inside small badge
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.18), width: 220, height: 60, fillColor: orange, cornerRadius: 30, opacity: 0.95))
        els.append(makeText("إعلان", at: CGPoint(x: cx, y: h * 0.18),
                            font: "Cairo-Regular", size: 44, color: white, bold: true))
        // Headline
        els.append(makeText("أطلقنا خدمتنا", at: CGPoint(x: cx, y: cy - 90),
                            font: "Amiri-Bold", size: 140, color: white, bold: true))
        els.append(makeText("الجديدة", at: CGPoint(x: cx, y: cy + 30),
                            font: "ArefRuqaa-Regular", size: 200,
                            gradient: ["#FF6B35", "#FFB18A", "#FF6B35"], shadow: true))
        // Bottom CTA
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.82), width: w * 0.6, height: 80, fillColor: orange, cornerRadius: 40, opacity: 1.0))
        els.append(makeText("اكتشف المزيد", at: CGPoint(x: cx, y: h * 0.82),
                            font: "Cairo-Regular", size: 42, color: white, bold: true))
        els.append(makeText("www.example.com", at: CGPoint(x: cx, y: h * 0.92),
                            font: "Cairo-Regular", size: 36, color: orange, isArabic: false))
        return els
    }

    private static func businessContact(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let blue = "#5AC8FA"
        // Background dot pattern (3 faded large rings)
        els.append(makeRing(at: CGPoint(x: w * 0.15, y: h * 0.85), diameter: 180, color: blue, opacity: 0.10))
        els.append(makeRing(at: CGPoint(x: w * 0.90, y: h * 0.15), diameter: 220, color: blue, opacity: 0.10))
        // Header
        els.append(makeText("تواصل معنا", at: CGPoint(x: cx, y: h * 0.16),
                            font: "Cairo-Regular", size: 80, color: blue, bold: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.24), width: w * 0.3, color: blue))
        // Icon + text rows
        let rows: [(String, String, Bool)] = [
            ("phone.fill",        "+966 55 123 4567",              false),
            ("envelope.fill",     "info@company.sa",               false),
            ("globe",             "www.company.sa",                false),
            ("mappin.and.ellipse","الرياض، المملكة العربية السعودية", true),
        ]
        let startY = h * 0.40
        let stepY: CGFloat = h * 0.12
        for (i, row) in rows.enumerated() {
            let y = startY + CGFloat(i) * stepY
            els.append(makeSticker(row.0, at: CGPoint(x: w * 0.22, y: y), size: 50, opacity: 0.9))
            els.append(makeText(row.1, at: CGPoint(x: w * 0.58, y: y),
                                font: row.2 ? "Amiri-Regular" : "Cairo-Regular",
                                size: row.2 ? 44 : 46,
                                color: white, isArabic: row.2,
                                alignment: row.2 ? .trailing : .leading))
        }
        return els
    }

    // ════════════════════════════════════════════
    // MARK: Quotes
    // ════════════════════════════════════════════

    private static func quoteQuran(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Background mosque-like motif using crescent
        els.append(backgroundMotif("moon.fill", at: CGPoint(x: cx, y: h * 0.30), size: w * 0.55, opacity: 0.05))
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 55, thickness: 2, color: gold, opacity: 0.6))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 55, size: 20, color: gold))
        // Ornate brackets
        els.append(makeText("﴿", at: CGPoint(x: w * 0.20, y: cy - 20),
                            font: "Amiri-Bold", size: 280, color: gold, isArabic: false, opacity: 0.95))
        els.append(makeText("﴾", at: CGPoint(x: w * 0.80, y: cy - 20),
                            font: "Amiri-Bold", size: 280, color: gold, isArabic: false, opacity: 0.95))
        // Verse
        els.append(makeText("إِنَّ مَعَ الْعُسْرِ يُسْرًا", at: CGPoint(x: cx, y: cy - 20),
                            font: "Amiri-Bold", size: 160, gradient: goldGradient3, shadow: true))
        // Source badge
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.78), width: w * 0.35))
        els.append(makeText("سورة الشرح · الآية ٦", at: CGPoint(x: cx, y: h * 0.85),
                            font: "Amiri-Regular", size: 50, color: goldSoft))
        return els
    }

    private static func quoteHadith(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        // Frame
        els.append(contentsOf: makeFrame(canvasW: w, canvasH: h, inset: 55, thickness: 2, color: gold, opacity: 0.6))
        els.append(contentsOf: cornerDiamonds(canvasW: w, canvasH: h, inset: 55, size: 20, color: gold))
        // Top label badge
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.16), width: 280, height: 64, fillColor: gold, cornerRadius: 32, opacity: 0.18))
        els.append(makeText("حديث شريف", at: CGPoint(x: cx, y: h * 0.16),
                            font: "Cairo-Regular", size: 46, color: goldSoft, bold: true))
        // First line
        els.append(makeText("«إنما الأعمال بالنيات»", at: CGPoint(x: cx, y: cy - 50),
                            font: "Amiri-Bold", size: 130, gradient: goldGradient3, shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 30), width: w * 0.3))
        // Second line
        els.append(makeText("«وإنما لكل امرئ ما نوى»", at: CGPoint(x: cx, y: cy + 110),
                            font: "Amiri-Regular", size: 80, color: white))
        // Source
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.85), width: w * 0.25))
        els.append(makeText("— رواه البخاري ومسلم", at: CGPoint(x: cx, y: h * 0.91),
                            font: "Amiri-Regular", size: 40, color: goldSoft))
        return els
    }

    private static func quoteProverb(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let amber = "#E8C547"
        // Background diamond pattern (4 small diamonds)
        els.append(makeDiamond(at: CGPoint(x: w * 0.15, y: h * 0.30), size: 30, color: amber, opacity: 0.20))
        els.append(makeDiamond(at: CGPoint(x: w * 0.85, y: h * 0.30), size: 30, color: amber, opacity: 0.20))
        els.append(makeDiamond(at: CGPoint(x: w * 0.15, y: h * 0.70), size: 30, color: amber, opacity: 0.20))
        els.append(makeDiamond(at: CGPoint(x: w * 0.85, y: h * 0.70), size: 30, color: amber, opacity: 0.20))
        // Header
        els.append(makeText("مثل عربي", at: CGPoint(x: cx, y: h * 0.18),
                            font: "Cairo-Regular", size: 50, color: amber))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.25), width: w * 0.28, color: amber))
        // Headline
        els.append(makeText("الصبر مفتاح الفرج", at: CGPoint(x: cx, y: cy),
                            font: "ArefRuqaa-Regular", size: 200,
                            gradient: ["#E8C547", "#F5DC7A", "#E8C547"], shadow: true))
        // Source
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: h * 0.80), width: w * 0.25, color: amber))
        els.append(makeText("من الحكمة العربية", at: CGPoint(x: cx, y: h * 0.87),
                            font: "Amiri-Regular", size: 44, color: white))
        return els
    }

    private static func quoteMotivation(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [CanvasElement] {
        var els: [CanvasElement] = []
        let amber = "#FFB340"
        // Background bolt motif
        els.append(backgroundMotif("bolt.fill", at: CGPoint(x: w * 0.78, y: h * 0.22), size: w * 0.40, opacity: 0.10))
        els.append(backgroundMotif("bolt.fill", at: CGPoint(x: w * 0.22, y: h * 0.78), size: w * 0.25, opacity: 0.10))
        // Label
        els.append(makeBadge(at: CGPoint(x: cx, y: h * 0.16), width: 220, height: 64, fillColor: amber, cornerRadius: 32, opacity: 0.95))
        els.append(makeText("تحفيز", at: CGPoint(x: cx, y: h * 0.16),
                            font: "Cairo-Regular", size: 44, color: white, bold: true))
        // Big headline
        els.append(makeText("ابدأ الآن", at: CGPoint(x: cx, y: cy - 80),
                            font: "Amiri-Bold", size: 240,
                            gradient: ["#FFB340", "#FFD18A", "#FFB340"], shadow: true))
        els.append(contentsOf: ornamentDivider(at: CGPoint(x: cx, y: cy + 50), width: w * 0.3, color: amber))
        // Subtitle lines
        els.append(makeText("لا تنتظر اللحظة المثالية", at: CGPoint(x: cx, y: cy + 130),
                            font: "Amiri-Regular", size: 56, color: white))
        els.append(makeText("اصنعها بنفسك", at: CGPoint(x: cx, y: cy + 220),
                            font: "Amiri-Bold", size: 70, color: amber, bold: true))
        return els
    }
}
