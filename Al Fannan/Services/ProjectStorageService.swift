import SwiftUI
import Foundation

// MARK: - Project Storage Service
@Observable
class ProjectStorageService {
    private let fileManager = FileManager.default
    private var projectsDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("AlFannan_Projects", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    func saveProject(_ project: SavedProject) throws {
        let data = try JSONEncoder().encode(project)
        let fileURL = projectsDirectory.appendingPathComponent("\(project.id.uuidString).json")
        try data.write(to: fileURL)
    }
    
    func loadProjects() -> [SavedProject] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: projectsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return [] }
        
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> SavedProject? in
                guard let data = try? Data(contentsOf: url),
                      let project = try? JSONDecoder().decode(SavedProject.self, from: data)
                else { return nil }
                return project
            }
            .sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
    
    func deleteProject(_ id: UUID) throws {
        let fileURL = projectsDirectory.appendingPathComponent("\(id.uuidString).json")
        try fileManager.removeItem(at: fileURL)
    }
    
    func saveThumbnail(_ image: UIImage, for projectId: UUID) throws {
        let thumbDir = projectsDirectory.appendingPathComponent("thumbnails", isDirectory: true)
        try? fileManager.createDirectory(at: thumbDir, withIntermediateDirectories: true)
        let fileURL = thumbDir.appendingPathComponent("\(projectId.uuidString).jpg")
        if let data = image.jpegData(compressionQuality: 0.6) {
            try data.write(to: fileURL)
        }
    }
    
    func loadThumbnail(for projectId: UUID) -> UIImage? {
        let thumbDir = projectsDirectory.appendingPathComponent("thumbnails", isDirectory: true)
        let fileURL = thumbDir.appendingPathComponent("\(projectId.uuidString).jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Saved Project (Codable version)
struct SavedProject: Codable, Identifiable {
    let id: UUID
    var name: String
    var nameAr: String
    var canvasWidth: CGFloat
    var canvasHeight: CGFloat
    var backgroundColor: CodableColor
    var gradientColors: [CodableColor]
    var elements: [SavedCanvasElement]
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        nameAr: String = "",
        canvasWidth: CGFloat,
        canvasHeight: CGFloat,
        backgroundColor: CodableColor = CodableColor(hex: "#141418"),
        gradientColors: [CodableColor] = [],
        elements: [SavedCanvasElement] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.nameAr = nameAr
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.backgroundColor = backgroundColor
        self.gradientColors = gradientColors
        self.elements = elements
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Saved Canvas Element
struct SavedCanvasElement: Codable, Identifiable {
    let id: UUID
    var type: String // text, image, sticker, shape, video
    var name: String
    var positionX: CGFloat
    var positionY: CGFloat
    var width: CGFloat
    var height: CGFloat
    var rotation: Double
    var scale: CGFloat
    var opacity: Double
    var zIndex: Int
    var text: String?
    var textStyle: SavedTextStyle?
    var imageName: String?
    var imageData: Data?        // persisted photo data
    var stickerName: String?
    var shapeStyle: SavedShapeStyle?
    var maskShape: String?
    var filterName: String?
    var filterIntensity: Float?
    var isLocked: Bool
    var isVisible: Bool
    var flipX: Bool?
    var flipY: Bool?
}

struct SavedTextStyle: Codable {
    var fontName: String
    var fontSize: CGFloat
    var textColor: String
    var alignment: String
    var letterSpacing: CGFloat
    var lineSpacing: CGFloat
    var isRTL: Bool
    var isBold: Bool
    var isItalic: Bool
    var shadowEnabled: Bool
    var shadowColor: String
    var shadowRadius: CGFloat
    var curveAngle: CGFloat?
    var fillType: String?
    var gradientColors: [String]?
}

struct SavedShapeStyle: Codable {
    var shapeType: String
    var fillColor: String
    var strokeColor: String
    var strokeWidth: CGFloat
    var cornerRadius: CGFloat
}

// MARK: - Codable Color
struct CodableColor: Codable {
    var hex: String
    
    init(hex: String) {
        self.hex = hex
    }
    
    var color: Color {
        Color(hex: hex)
    }
}

// MARK: - Conversion Helpers
extension CanvasElement {
    func toSaved() -> SavedCanvasElement {
        SavedCanvasElement(
            id: id,
            type: type.rawValue,
            name: name,
            positionX: position.x,
            positionY: position.y,
            width: size.width,
            height: size.height,
            rotation: rotation,
            scale: scale,
            opacity: opacity,
            zIndex: zIndex,
            text: text,
            textStyle: textStyle.map { ts in
                SavedTextStyle(
                    fontName: ts.fontName,
                    fontSize: ts.fontSize,
                    textColor: ts.textColor,
                    alignment: ts.alignment.rawValue,
                    letterSpacing: ts.letterSpacing,
                    lineSpacing: ts.lineSpacing,
                    isRTL: ts.isRTL,
                    isBold: ts.isBold,
                    isItalic: ts.isItalic,
                    shadowEnabled: ts.shadowEnabled,
                    shadowColor: ts.shadowColor,
                    shadowRadius: ts.shadowRadius,
                    curveAngle: ts.curveAngle,
                    fillType: ts.fillType.rawValue,
                    gradientColors: ts.gradientColors
                )
            },
            imageName: imageName,
            imageData: imageData,
            stickerName: stickerName,
            shapeStyle: shapeStyle.map { ss in
                SavedShapeStyle(
                    shapeType: ss.shapeType.rawValue,
                    fillColor: ss.fillColor,
                    strokeColor: ss.strokeColor,
                    strokeWidth: ss.strokeWidth,
                    cornerRadius: ss.cornerRadius
                )
            },
            maskShape: maskShape.rawValue,
            filterName: filterName,
            filterIntensity: filterIntensity,
            isLocked: isLocked,
            isVisible: isVisible,
            flipX: flipX,
            flipY: flipY
        )
    }
    
    static func fromSaved(_ saved: SavedCanvasElement) -> CanvasElement {
        let elementType = CanvasElementType(rawValue: saved.type) ?? .text
        var el = CanvasElement(
            type: elementType,
            name: saved.name,
            position: CGPoint(x: saved.positionX, y: saved.positionY),
            size: CGSize(width: saved.width, height: saved.height)
        )
        el.rotation = saved.rotation
        el.scale = saved.scale
        el.opacity = saved.opacity
        el.zIndex = saved.zIndex
        el.text = saved.text
        el.imageName = saved.imageName
        el.imageData = saved.imageData
        el.stickerName = saved.stickerName
        el.flipX = saved.flipX ?? false
        el.flipY = saved.flipY ?? false
        el.isLocked = saved.isLocked
        el.isVisible = saved.isVisible
        el.maskShape = MaskShape(rawValue: saved.maskShape ?? "None") ?? .none
        el.filterName = saved.filterName
        el.filterIntensity = saved.filterIntensity ?? 1.0
        
        if let sts = saved.textStyle {
            var style = TextStyle()
            style.fontName = sts.fontName
            style.fontSize = sts.fontSize
            style.textColor = sts.textColor
            style.alignment = TextAlignmentOption(rawValue: sts.alignment) ?? .center
            style.letterSpacing = sts.letterSpacing
            style.lineSpacing = sts.lineSpacing
            style.isRTL = sts.isRTL
            style.isBold = sts.isBold
            style.isItalic = sts.isItalic
            style.shadowEnabled = sts.shadowEnabled
            style.shadowColor = sts.shadowColor
            style.shadowRadius = sts.shadowRadius
            style.curveAngle = sts.curveAngle ?? 0
            style.fillType = TextFillType(rawValue: sts.fillType ?? "Solid") ?? .solid
            style.gradientColors = sts.gradientColors ?? ["#D4A853", "#F0D48A", "#D4A853"]
            el.textStyle = style
        }
        
        if let sss = saved.shapeStyle {
            var style = ShapeStyleData()
            style.shapeType = ShapeType(rawValue: sss.shapeType) ?? .rectangle
            style.fillColor = sss.fillColor
            style.strokeColor = sss.strokeColor
            style.strokeWidth = sss.strokeWidth
            style.cornerRadius = sss.cornerRadius
            el.shapeStyle = style
        }
        
        return el
    }
}
