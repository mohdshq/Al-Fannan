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
enum TextFillType: String, CaseIterable {
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

// MARK: - Text Style
struct TextStyle: Equatable {
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
    
    /// Convenience init for template building
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

enum TextAlignmentOption: String, CaseIterable {
    case leading, center, trailing
    var systemAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Mask Shape
enum MaskShape: String, CaseIterable {
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

// MARK: - Shape Style
enum ShapeType: String, CaseIterable {
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

// MARK: - Texture Background
struct TextureBackground: Identifiable, Equatable {
    let id: String
    let name: String
    let nameAr: String
    let colors: [Color]  // Used to generate procedural textures
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

struct ShapeStyleData: Equatable {
    var shapeType: ShapeType = .rectangle
    var fillColor: String = "#D4A853"
    var strokeColor: String = "#FFFFFF"
    var strokeWidth: CGFloat = 0
    var cornerRadius: CGFloat = 8
}

// MARK: - Canvas Element
struct CanvasElement: Identifiable, Equatable {
    let id: UUID
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
    var backgroundRemovedData: Data? = nil  // AI BG-removed version
    var stickerName: String? = nil
    var shapeStyle: ShapeStyleData? = nil
    var maskShape: MaskShape = .none
    var cropRect: CGRect? = nil          // Normalized 0...1 crop rect
    var filterName: String? = nil        // CIFilter name applied to image
    var filterIntensity: Float = 1.0     // Filter intensity 0...1
    var isLocked: Bool = false
    var isVisible: Bool = true
    var isSelected: Bool = false
    var enterAnimation: ElementAnimation = .none
    var animationDuration: Double = 0.5
    var useBackgroundRemoved: Bool = false
    var flipX: Bool = false   // horizontal flip
    var flipY: Bool = false   // vertical flip
    
    init(type: CanvasElementType, name: String,
         position: CGPoint = CGPoint(x: 187, y: 300),
         size: CGSize = CGSize(width: 200, height: 60)) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.position = position
        self.size = size
    }
    
    static func textElement(_ text: String, isArabic: Bool = false) -> CanvasElement {
        var el = CanvasElement(type: .text, name: "Text", size: CGSize(width: 250, height: 80))
        el.text = text
        var style = TextStyle()
        style.isRTL = isArabic
        style.fontSize = isArabic ? 28 : 24
        el.textStyle = style
        return el
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
