import SwiftUI

// MARK: - Canvas Element Types
enum CanvasElementType: String, Codable, CaseIterable {
    case text = "Text"
    case image = "Image"
    case sticker = "Sticker"
    case shape = "Shape"
    case video = "Video"

    var icon: String {
        switch self {
        case .text: return "textformat"
        case .image: return "photo"
        case .sticker: return "face.smiling"
        case .shape: return "square.on.circle"
        case .video: return "video"
        }
    }
}

// MARK: - Text Fill Type
enum TextFillType: String, Codable, CaseIterable {
    case solid = "Solid"
    case gradient = "Gradient"
    case image = "Image"

    var icon: String {
        switch self {
        case .solid: return "paintbrush.fill"
        case .gradient: return "paintpalette.fill"
        case .image: return "photo.fill"
        }
    }
}

// MARK: - Text Alignment
enum TextAlignmentOption: String, Codable, CaseIterable {
    case leading, center, trailing

    var systemAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Text Style
struct TextStyle: Codable, Equatable {
    var fontName: String = "System"
    var fontSize: CGFloat = 24
    var textColor: String = "#FFFFFF"
    var alignment: TextAlignmentOption = .center
    var letterSpacing: CGFloat = 0
    var lineSpacing: CGFloat = 4
    var isRTL: Bool = false
    var isBold: Bool = false
    var isItalic: Bool = false
    var shadowEnabled: Bool = false
    var shadowColor: String = "#000000"
    var shadowRadius: CGFloat = 4
    var strokeEnabled: Bool = false
    var strokeColor: String = "#000000"
    var strokeWidth: CGFloat = 1
    var curveAngle: CGFloat = 0
    var fillType: TextFillType = .solid
    var gradientColors: [String] = ["#D4A853", "#F0D48A", "#D4A853"]
    var gradientAngle: Double = 0

    init(fontName: String = "System", fontSize: CGFloat = 24, textColor: String = "#FFFFFF",
         alignment: TextAlignmentOption = .center, letterSpacing: CGFloat = 0, lineSpacing: CGFloat = 4,
         isRTL: Bool = false, isBold: Bool = false, isItalic: Bool = false,
         shadowEnabled: Bool = false, shadowColor: String = "#000000", shadowRadius: CGFloat = 4,
         strokeEnabled: Bool = false, strokeColor: String = "#000000", strokeWidth: CGFloat = 1,
         curveAngle: CGFloat = 0, fillType: TextFillType = .solid,
         gradientColors: [String] = ["#D4A853", "#F0D48A", "#D4A853"], gradientAngle: Double = 0) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
        self.alignment = alignment
        self.letterSpacing = letterSpacing
        self.lineSpacing = lineSpacing
        self.isRTL = isRTL
        self.isBold = isBold
        self.isItalic = isItalic
        self.shadowEnabled = shadowEnabled
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.strokeEnabled = strokeEnabled
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.curveAngle = curveAngle
        self.fillType = fillType
        self.gradientColors = gradientColors
        self.gradientAngle = gradientAngle
    }
}

// MARK: - Mask Shape
enum MaskShape: String, Codable, CaseIterable {
    case none = "None"
    case circle = "Circle"
    case heart = "Heart"
    case star = "Star"
    case roundedRect = "Rounded"
    case diamond = "Diamond"
    case hexagon = "Hexagon"
    case leaf = "Leaf"
    case arch = "Arch"
    case shield = "Shield"
    case cross = "Cross"

    var icon: String {
        switch self {
        case .none: return "slash.circle"
        case .circle: return "circle.fill"
        case .heart: return "heart.fill"
        case .star: return "star.fill"
        case .roundedRect: return "rectangle.roundedtop.fill"
        case .diamond: return "diamond.fill"
        case .hexagon: return "hexagon.fill"
        case .leaf: return "leaf.fill"
        case .arch: return "archivebox.fill"
        case .shield: return "shield.fill"
        case .cross: return "cross.fill"
        }
    }
}

// MARK: - Shape Type
enum ShapeType: String, Codable, CaseIterable {
    case rectangle, circle, roundedRect, triangle, star, hexagon
    case arrow, speechBubble, banner, pentagon, cross, diamond, ring

    var icon: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .roundedRect: return "rectangle.roundedtop"
        case .triangle: return "triangle"
        case .star: return "star"
        case .hexagon: return "hexagon"
        case .arrow: return "arrow.right"
        case .speechBubble: return "bubble.right"
        case .banner: return "flag"
        case .pentagon: return "pentagon"
        case .cross: return "cross"
        case .diamond: return "diamond"
        case .ring: return "circle.dashed"
        }
    }
}

// MARK: - Shape Style
struct ShapeStyleData: Codable, Equatable {
    var shapeType: ShapeType = .rectangle
    var fillColor: String = "#D4A853"
    var strokeColor: String = "#FFFFFF"
    var strokeWidth: CGFloat = 0
    var cornerRadius: CGFloat = 8
}

// MARK: - Texture Background (NOT Codable — UI-only)
struct TextureBackground: Identifiable, Equatable {
    let id: String
    let name: String
    let nameAr: String
    let colors: [Color]
    let style: TextureStyle

    enum TextureStyle: String {
        case paper, marble, wood, fabric, concrete, linen, grain, watercolor
    }

    static let textures: [TextureBackground] = [
        TextureBackground(id: "paper_cream", name: "Cream Paper", nameAr: "ورق كريمي", colors: [Color(hex: "F5F0E8"), Color(hex: "E8E0D0")], style: .paper),
        TextureBackground(id: "paper_aged", name: "Aged Paper", nameAr: "ورق قديم", colors: [Color(hex: "D4C5A0"), Color(hex: "C4B48E")], style: .paper),
        TextureBackground(id: "marble_white", name: "White Marble", nameAr: "رخام أبيض", colors: [Color(hex: "F0EDE8"), Color(hex: "D8D0C8")], style: .marble),
        TextureBackground(id: "marble_gold", name: "Gold Marble", nameAr: "رخام ذهبي", colors: [Color(hex: "D4A853"), Color(hex: "A08040")], style: .marble),
        TextureBackground(id: "wood_light", name: "Light Wood", nameAr: "خشب فاتح", colors: [Color(hex: "C4A882"), Color(hex: "B09070")], style: .wood),
        TextureBackground(id: "wood_dark", name: "Dark Wood", nameAr: "خشب غامق", colors: [Color(hex: "5C3A1E"), Color(hex: "3E2612")], style: .wood),
        TextureBackground(id: "fabric_navy", name: "Navy Fabric", nameAr: "قماش كحلي", colors: [Color(hex: "1A237E"), Color(hex: "0D1647")], style: .fabric),
        TextureBackground(id: "concrete_grey", name: "Grey Concrete", nameAr: "خرسانة رمادي", colors: [Color(hex: "8E8E93"), Color(hex: "636366")], style: .concrete),
        TextureBackground(id: "linen_beige", name: "Beige Linen", nameAr: "كتان بيج", colors: [Color(hex: "E8DDD0"), Color(hex: "D0C4B0")], style: .linen),
        TextureBackground(id: "watercolor_blue", name: "Blue Wash", nameAr: "ألوان مائية", colors: [Color(hex: "A8D8EA"), Color(hex: "5B9BD5")], style: .watercolor),
        TextureBackground(id: "grain_dark", name: "Dark Grain", nameAr: "محبب غامق", colors: [Color(hex: "2C2C2E"), Color(hex: "1C1C1E")], style: .grain),
        TextureBackground(id: "grain_warm", name: "Warm Grain", nameAr: "محبب دافئ", colors: [Color(hex: "8B6914"), Color(hex: "5C4510")], style: .grain),
    ]
}

// MARK: - Canvas Element
struct CanvasElement: Identifiable, Codable, Equatable {
    var id: UUID
    var type: CanvasElementType
    var name: String
    var position: CGPoint
    var size: CGSize
    var rotation: Double = 0
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    var zIndex: Int = 0
    var text: String? = nil
    var textStyle: TextStyle? = nil
    var imageName: String? = nil
    var imageData: Data? = nil
    var backgroundRemovedData: Data? = nil
    var stickerName: String? = nil
    var shapeStyle: ShapeStyleData? = nil
    var maskShape: MaskShape = .none
    var cropRect: CGRect? = nil
    var filterName: String? = nil
    var filterIntensity: Float = 1.0
    var isLocked: Bool = false
    var isVisible: Bool = true
    var isSelected: Bool = false
    var enterAnimation: ElementAnimation = .none
    var animationDuration: Double = 0.5
    var useBackgroundRemoved: Bool = false
    var flipX: Bool = false
    var flipY: Bool = false

    init(type: CanvasElementType, name: String,
         position: CGPoint = CGPoint(x: 187, y: 300),
         size: CGSize = CGSize(width: 200, height: 60)) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.position = position
        self.size = size
    }

    // Factory helpers
    static func textElement(_ text: String, isArabic: Bool = false) -> CanvasElement {
        var style = TextStyle()
        style.isRTL = isArabic
        style.fontSize = isArabic ? 28 : 24
        let size = CanvasElement.measureText(text, style: style)
        var el = CanvasElement(type: .text, name: "Text", size: size)
        el.text = text
        el.textStyle = style
        return el
    }

    /// Measures a text's rendered size in canvas coordinates.
    /// The canvas renders text at 0.4x the style's fontSize, so we measure at the same scale
    /// and divide back, giving a frame that hugs the text in canvas space.
    static func measureText(_ text: String, style: TextStyle) -> CGSize {
        let renderedFontSize = style.fontSize

        let uiFont: UIFont = {
            if let custom = UIFont(name: style.fontName, size: renderedFontSize) {
                return custom
            }
            var f = UIFont.systemFont(ofSize: renderedFontSize, weight: style.isBold ? .bold : .regular)
            if style.isItalic, let descriptor = f.fontDescriptor.withSymbolicTraits(.traitItalic) {
                f = UIFont(descriptor: descriptor, size: renderedFontSize)
            }
            return f
        }()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont,
            .kern: style.letterSpacing,
            .paragraphStyle: paragraphStyle
        ]
        let measureText = text.isEmpty ? " " : text
        let attributed = NSAttributedString(string: measureText, attributes: attributes)
        let bounding = attributed.boundingRect(
            with: CGSize(width: 2000, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics],
            context: nil
        )

        // SwiftUI Text adds extra vertical padding for ascender/descender beyond what
        // boundingRect reports. Inflate width by ~15% and height by ~40% to match.
        let widthInflation: CGFloat = 1.35
        let heightInflation: CGFloat = 1.4
        let paddingX: CGFloat = 32
        let paddingY: CGFloat = 16
        var canvasW = ceil(bounding.width * widthInflation) + paddingX
        var canvasH = ceil(bounding.height * heightInflation) + paddingY

        // Curved text: the text follows an arc, so the bounding box must grow.
        if abs(style.curveAngle) > 1 {
            let angle = min(abs(style.curveAngle), 360)
            let angleRad = angle * .pi / 180
            let textArcLength = bounding.width * widthInflation
            let textThickness = bounding.height * heightInflation
            let radius = textArcLength / angleRad

            // Conservative bounding: full diameter + glyph thickness on both sides.
            // This always contains the arc regardless of which direction it bows.
            let diameter = 2 * radius + 2 * textThickness
            canvasW = max(canvasW, ceil(diameter) + paddingX)
            canvasH = max(canvasH, ceil(diameter) + paddingY)
        }

        return CGSize(
            width: max(40, canvasW),
            height: max(30, canvasH)
        )


    }


    static func imageElement(_ name: String) -> CanvasElement {
        var el = CanvasElement(type: .image, name: "Image", size: CGSize(width: 200, height: 200))
        el.imageName = name
        return el
    }

    static func stickerElement(_ name: String) -> CanvasElement {
        var el = CanvasElement(type: .sticker, name: name, size: CGSize(width: 100, height: 100))
        el.stickerName = name
        return el
    }

    static func shapeElement(_ type: ShapeType) -> CanvasElement {
        var el = CanvasElement(type: .shape, name: type.rawValue, size: CGSize(width: 150, height: 150))
        el.shapeStyle = ShapeStyleData(shapeType: type)
        return el
    }
}
