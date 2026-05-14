import SwiftUI
import Observation

@Observable
class CanvasViewModel {
    var elements: [CanvasElement] = []
    var selectedElementIds: Set<UUID> = []
    var canvasWidth: CGFloat = 1080
    var canvasHeight: CGFloat = 1920
    var backgroundColor: Color = .white
    var backgroundGradientColors: [Color] = []
    var backgroundTexture: String? = nil
    var canvasScale: CGFloat = 1.0
    var showGrid: Bool = false
    var undoStack: [[CanvasElement]] = []
    var redoStack: [[CanvasElement]] = []
    var currentProjectId: UUID? = nil       // tracks which saved project we're editing
    var currentProjectName: String = ""     // display name for the project
    
    var selectedElement: CanvasElement? {
        guard let id = selectedElementIds.first, selectedElementIds.count == 1 else { return nil }
        return elements.first(where: { $0.id == id })
    }
    
    var sortedElements: [CanvasElement] {
        elements.sorted(by: { $0.zIndex < $1.zIndex })
    }
    
    // MARK: - Element Management
    func addElement(_ element: CanvasElement) {
        saveState()
        var newElement = element
        newElement.zIndex = (elements.map(\.zIndex).max() ?? 0) + 1
        elements.append(newElement)
        selectedElementIds = [newElement.id]
    }
    
    func addText(_ text: String, isArabic: Bool = false) {
        let element = CanvasElement.textElement(text, isArabic: isArabic)
        addElement(element)
    }
    
    func addShape(_ shapeType: ShapeType) {
        let element = CanvasElement.shapeElement(shapeType)
        addElement(element)
    }
    
    func addSticker(_ name: String) {
        let element = CanvasElement.stickerElement(name)
        addElement(element)
    }
    
    func addImage(_ image: UIImage) {
        var el = CanvasElement(
            type: .image,
            name: "Photo",
            position: CGPoint(x: canvasWidth / 2, y: canvasHeight / 2),
            size: CGSize(width: 300, height: 300)
        )
        // Scale to fit canvas while keeping aspect
        let aspect = image.size.width / image.size.height
        let maxDim: CGFloat = min(canvasWidth, canvasHeight) * 0.6
        if aspect > 1 {
            el.size = CGSize(width: maxDim, height: maxDim / aspect)
        } else {
            el.size = CGSize(width: maxDim * aspect, height: maxDim)
        }
        el.imageData = image.jpegData(compressionQuality: 0.85)
        addElement(el)
    }
    
    enum CollageLayoutType {
        case grid2x2
        case splitVertical
        case splitHorizontal
    }
    
    func addCollage(layout: CollageLayoutType) {
        saveState()
        
        let w = canvasWidth
        let h = canvasHeight
        let gap: CGFloat = 20
        
        switch layout {
        case .grid2x2:
            let cellW = (w - gap * 3) / 2
            let cellH = (h - gap * 3) / 2
            
            // Top Left
            addEmptyImage(at: CGPoint(x: gap + cellW/2, y: gap + cellH/2), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            // Top Right
            addEmptyImage(at: CGPoint(x: gap*2 + cellW*1.5, y: gap + cellH/2), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            // Bottom Left
            addEmptyImage(at: CGPoint(x: gap + cellW/2, y: gap*2 + cellH*1.5), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            // Bottom Right
            addEmptyImage(at: CGPoint(x: gap*2 + cellW*1.5, y: gap*2 + cellH*1.5), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            
        case .splitVertical:
            let cellW = (w - gap * 3) / 2
            let cellH = h - gap * 2
            
            addEmptyImage(at: CGPoint(x: gap + cellW/2, y: h/2), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            addEmptyImage(at: CGPoint(x: gap*2 + cellW*1.5, y: h/2), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            
        case .splitHorizontal:
            let cellW = w - gap * 2
            let cellH = (h - gap * 3) / 2
            
            addEmptyImage(at: CGPoint(x: w/2, y: gap + cellH/2), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
            addEmptyImage(at: CGPoint(x: w/2, y: gap*2 + cellH*1.5), size: CGSize(width: cellW, height: cellH), shape: .roundedRect)
        }
    }
    
    private func addEmptyImage(at position: CGPoint, size: CGSize, shape: MaskShape) {
        var el = CanvasElement(
            type: .image,
            name: "Collage Cell",
            position: position,
            size: size
        )
        el.maskShape = shape
        
        let rect = CGRect(origin: .zero, size: CGSize(width: 400, height: 400))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        // Light gray placeholder
        UIColor(white: 0.9, alpha: 1.0).setFill()
        UIRectFill(rect)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        el.imageData = placeholderImage?.jpegData(compressionQuality: 0.8)
        addElement(el)
    }
    
    func removeElement(_ id: UUID) {
        guard !isElementLocked(id) else { return }
        saveState()
        elements.removeAll(where: { $0.id == id })
        selectedElementIds.remove(id)
    }
    
    func duplicateElement(_ id: UUID) {
        guard let element = elements.first(where: { $0.id == id }) else { return }
        guard !element.isLocked else { return }
        saveState()
        var copy = element                                      // value-type copy: all fields preserved
        copy.id = UUID()                                        // unique identity
        copy.name = element.name + " Copy"
        copy.position.x += 20
        copy.position.y += 20
        copy.zIndex = (elements.map(\.zIndex).max() ?? 0) + 1
        copy.isSelected = false                                 // never duplicate selection state
        elements.append(copy)
        selectedElementIds = [copy.id]
    }
    
    func selectElement(_ id: UUID?) {
        if let id = id {
            selectedElementIds = [id]
        } else {
            selectedElementIds.removeAll()
        }
    }
    
    func toggleSelection(_ id: UUID) {
        if selectedElementIds.contains(id) {
            selectedElementIds.remove(id)
        } else {
            selectedElementIds.insert(id)
        }
    }
    
    func updateElement(_ id: UUID, update: (inout CanvasElement) -> Void) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        guard !elements[index].isLocked else { return }

        let before = elements[index]
        update(&elements[index])
        let after = elements[index]

        // Auto-refit text frame when text content or style changed (but not when only
        // position/rotation/scale/size changed — those mean the user is moving/resizing).
        if after.type == .text {
            let textChanged = before.text != after.text
            let styleChanged = before.textStyle != after.textStyle
            let sizeUnchanged = before.size == after.size
            if (textChanged || styleChanged) && sizeUnchanged {
                if let text = after.text, let style = after.textStyle {
                    elements[index].size = CanvasElement.measureText(text, style: style)
                }
            }
        }
    }
    
    /// Re-measures a text element's frame to fit its current text and style.
    /// Call this after changing text content, font, size, weight, or letter spacing.
    func refitTextFrame(_ id: UUID) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        guard elements[idx].type == .text,
              let text = elements[idx].text,
              let style = elements[idx].textStyle else { return }
        let newSize = CanvasElement.measureText(text, style: style)
        elements[idx].size = newSize
    }
    
    // MARK: - Layer Management
    func moveElementUp(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        guard !elements[index].isLocked else { return }
        saveState()
        elements[index].zIndex += 1
    }
    
    func moveElementDown(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        guard !elements[index].isLocked else { return }
        saveState()
        elements[index].zIndex -= 1
    }
    
    func moveToFront(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        guard !elements[index].isLocked else { return }
        saveState()
        elements[index].zIndex = (elements.map(\.zIndex).max() ?? 0) + 1
    }
    
    func moveToBack(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        guard !elements[index].isLocked else { return }
        saveState()
        elements[index].zIndex = (elements.map(\.zIndex).min() ?? 0) - 1
    }
    
    func toggleVisibility(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        elements[index].isVisible.toggle()
    }
    
    func toggleLock(_ id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }
        elements[index].isLocked.toggle()
    }
    
    // MARK: - Undo/Redo
    private func saveState() {
        undoStack.append(elements)
        redoStack.removeAll()
        if undoStack.count > 30 { undoStack.removeFirst() }
    }
    
    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(elements)
        elements = previous
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(elements)
        elements = next
    }
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    // MARK: - Canvas Setup
    func setCanvasSize(preset: CanvasPreset) {
        canvasWidth = preset.width
        canvasHeight = preset.height
    }
    
    func setBackground(color: Color) {
        backgroundColor = color
        backgroundGradientColors = []
        backgroundTexture = nil
    }
    
    func setBackgroundGradient(colors: [Color]) {
        backgroundGradientColors = colors
        backgroundTexture = nil
    }
    
    func setBackgroundTexture(_ name: String) {
        backgroundTexture = name
        backgroundGradientColors = []
    }
    
    // MARK: - Element Replacement
    func replaceImage(_ id: UUID, with newImage: UIImage) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              elements[index].type == .image,
              !elements[index].isLocked else { return }
        saveState()
        let aspect = newImage.size.width / newImage.size.height
        let maxDim: CGFloat = min(canvasWidth, canvasHeight) * 0.6
        if aspect > 1 {
            elements[index].size = CGSize(width: maxDim, height: maxDim / aspect)
        } else {
            elements[index].size = CGSize(width: maxDim * aspect, height: maxDim)
        }
        elements[index].imageData = newImage.jpegData(compressionQuality: 0.85)
        elements[index].backgroundRemovedData = nil
        elements[index].useBackgroundRemoved = false
    }
    
    // MARK: - Photo Filters
    func applyFilter(_ filterName: String?, to elementId: UUID, intensity: Float = 1.0) {
        guard let index = elements.firstIndex(where: { $0.id == elementId }) else { return }
        saveState()
        
        if let filterName = filterName {
            elements[index].filterName = filterName
            elements[index].filterIntensity = intensity
            
            // Apply filter to original image data
            let sourceData = elements[index].imageData
            if let data = sourceData,
               let originalImage = UIImage(data: data),
               let filtered = PhotoFilterService.shared.applyFilter(named: filterName, to: originalImage, intensity: intensity),
               let filteredData = filtered.jpegData(compressionQuality: 0.85) {
                // Store filtered as current view, keep original in imageData
                elements[index].imageData = filteredData
            }
        } else {
            // Reset to original — restore from undo if available
            elements[index].filterName = nil
            elements[index].filterIntensity = 1.0
        }
    }
    
    // MARK: - Image Cropping
    func setCropRect(_ elementId: UUID, rect: CGRect) {
        guard let index = elements.firstIndex(where: { $0.id == elementId }) else { return }
        elements[index].cropRect = rect
    }
    
    func applyCrop(to elementId: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == elementId }),
              let cropRect = elements[index].cropRect,
              let imageData = elements[index].imageData,
              let image = UIImage(data: imageData),
              let cgImage = image.cgImage else { return }
        
        saveState()
        
        let imgW = CGFloat(cgImage.width)
        let imgH = CGFloat(cgImage.height)
        let cropCGRect = CGRect(
            x: cropRect.origin.x * imgW,
            y: cropRect.origin.y * imgH,
            width: cropRect.width * imgW,
            height: cropRect.height * imgH
        )
        
        if let croppedCG = cgImage.cropping(to: cropCGRect) {
            let croppedImage = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
            elements[index].imageData = croppedImage.jpegData(compressionQuality: 0.85)
            elements[index].cropRect = nil
            
            // Update size to match new aspect ratio
            let aspect = croppedImage.size.width / croppedImage.size.height
            let currentHeight = elements[index].size.height
            elements[index].size = CGSize(width: currentHeight * aspect, height: currentHeight)
        }
    }
    
    // MARK: - Project Lifecycle

    /// Start editing a brand-new project. Resets all canvas state and ensures
    /// the next save creates a new file rather than overwriting an existing one.
    func loadNewProject(preset: CanvasPreset) {
        canvasWidth = preset.width
        canvasHeight = preset.height
        resetCanvasState()
        currentProjectId = nil
        currentProjectName = ""
    }

    /// Start editing a brand-new project with explicit dimensions.
    /// Convenience for the Home quick-action buttons.
    func loadNewProject(width: CGFloat, height: CGFloat) {
        canvasWidth = width
        canvasHeight = height
        resetCanvasState()
        currentProjectId = nil
        currentProjectName = ""
    }

    /// Load an existing saved project into the canvas for editing.
    /// Preserves the project's id so subsequent saves update the same file.
    func loadExistingProject(_ project: Project) {
        canvasWidth = project.canvasWidth
        canvasHeight = project.canvasHeight
        resetCanvasState()
        elements = project.elements
        backgroundColor = Color(hex: project.backgroundColor)
        currentProjectId = project.id
        currentProjectName = project.name
    }

    /// Internal helper: clears everything *except* canvas size and project identity.
    private func resetCanvasState() {
        elements.removeAll()
        selectedElementIds.removeAll()
        backgroundColor = .white
        backgroundGradientColors = []
        backgroundTexture = nil
        canvasScale = 1.0
        undoStack.removeAll()
        redoStack.removeAll()
    }
    // MARK: - Lock Helpers

    /// Returns true if the element with this id exists and is locked.
    private func isElementLocked(_ id: UUID) -> Bool {
        elements.first(where: { $0.id == id })?.isLocked ?? false
    }
}
