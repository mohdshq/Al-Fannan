import SwiftUI
import PhotosUI

struct CanvasEditorView: View {
    @Bindable var viewModel: CanvasViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var activeToolPanel: EditorToolPanel? = nil
    @State private var showLayersPanel = false
    @State private var showExportSheet = false
    @State private var showTextEditor = false
    @State private var showPhotoPicker = false
    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var draggingElementId: UUID? = nil
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @GestureState private var currentMagnification: CGFloat = 1.0
    @GestureState private var currentRotation: Angle = .zero
    @State private var resizeCorner: SelectionHandlesOverlay.HandleCorner? = nil
    @State private var resizeTranslation: CGSize = .zero
    @State private var handleRotation: Angle = .zero
    @State private var showSaveConfirm = false
    @State private var selectedElementOpacity: Double = 1.0
    @State private var showReplacePicker = false
    @State private var replacePhotoItems: [PhotosPickerItem] = []
    @State private var showCropOverlay = false
    @State private var cropRect: CGRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
    @State private var showAlignH = false
    @State private var showAlignV = false
    private let storageService = ProjectStorageService()
    private let bgRemovalService = BackgroundRemovalService()
    
    var body: some View {
        ZStack {
            // Background
            DS.Colors.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Toolbar
                editorTopBar
                
                // Canvas Area
                canvasArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom Panel
                if let panel = activeToolPanel {
                    toolPanel(panel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Tool Bar
                editorBottomToolbar
            }
        }
        .sheet(isPresented: $showLayersPanel) {
            LayersPanelView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTextEditor) {
            TextToolsView(viewModel: viewModel)
                .presentationDetents([.fraction(0.4), .medium, .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: selectedPhotoItems) { _, newItems in
            guard let item = newItems.first else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.addImage(image)
                    }
                }
                selectedPhotoItems = []
            }
        }
        .photosPicker(
            isPresented: $showReplacePicker,
            selection: $replacePhotoItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: replacePhotoItems) { _, newItems in
            guard let item = newItems.first,
                  let id = viewModel.selectedElement?.id else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.replaceImage(id, with: image)
                        HapticManager.success()
                    }
                }
                replacePhotoItems = []
            }
        }
        .fullScreenCover(isPresented: $showCropOverlay) {
            if let id = viewModel.selectedElement?.id,
               let element = viewModel.selectedElement,
               let imageData = element.imageData,
               let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                    
                    ImageCropOverlayView(
                        cropRect: $cropRect,
                        imageSize: uiImage.size,
                        onApply: {
                            viewModel.setCropRect(id, rect: cropRect)
                            viewModel.applyCrop(to: id)
                            showCropOverlay = false
                            HapticManager.success()
                        },
                        onCancel: {
                            showCropOverlay = false
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Top Bar
    private var editorTopBar: some View {
        HStack(spacing: DS.Spacing.sm) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(DS.Colors.surface)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Undo/Redo
            HStack(spacing: DS.Spacing.xxs) {
                Button {
                    viewModel.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 15))
                        .foregroundColor(viewModel.canUndo ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                        .frame(width: 36, height: 36)
                }
                .disabled(!viewModel.canUndo)
                
                Button {
                    viewModel.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 15))
                        .foregroundColor(viewModel.canRedo ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                        .frame(width: 36, height: 36)
                }
                .disabled(!viewModel.canRedo)
            }
            .padding(.horizontal, DS.Spacing.xxs)
            .background(DS.Colors.surface)
            .clipShape(Capsule())
            
            Spacer()
            
            HStack(spacing: DS.Spacing.xs) {
                // Layers
                Button {
                    showLayersPanel = true
                    HapticManager.softTap()
                } label: {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 16))
                        .foregroundColor(DS.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(DS.Colors.surface)
                        .clipShape(Circle())
                }
                
                // Save
                Button {
                    saveProject()
                } label: {
                    Image(systemName: showSaveConfirm ? "checkmark" : "square.and.arrow.down")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(showSaveConfirm ? DS.Colors.success : DS.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(showSaveConfirm ? DS.Colors.success.opacity(0.15) : DS.Colors.surface)
                        .clipShape(Circle())
                        .animation(AnimationPreset.springSnappy, value: showSaveConfirm)
                }
                
                // Export
                GoldButton("Export", icon: "arrow.up.circle.fill", isCompact: true) {
                    showExportSheet = true
                    HapticManager.tap()
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.xs)
        .background(DS.Colors.bgSecondary)
    }
    
    // MARK: - Canvas Area
    private var canvasArea: some View {
        GeometryReader { geometry in
            let canvasAspect = viewModel.canvasWidth / viewModel.canvasHeight
            let availableWidth = geometry.size.width - 32
            let availableHeight = geometry.size.height - 32
            let displayWidth: CGFloat = canvasAspect > availableWidth / availableHeight ? availableWidth : availableHeight * canvasAspect
            let displayHeight: CGFloat = canvasAspect > availableWidth / availableHeight ? availableWidth / canvasAspect : availableHeight
            
            ZStack {
                // Checkerboard pattern hint
                DS.Colors.bgTertiary
                
                // Canvas
                ZStack {
                    // Background
                    if let texId = viewModel.backgroundTexture,
                       let tex = TextureBackground.textures.first(where: { $0.id == texId }) {
                        ZStack {
                            LinearGradient(
                                colors: tex.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            // Texture overlay
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .opacity(tex.style == .grain ? 0.35 : 0.12)
                        }
                    } else if viewModel.backgroundGradientColors.isEmpty {
                        Rectangle().fill(viewModel.backgroundColor)
                    } else {
                        LinearGradient(
                            colors: viewModel.backgroundGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    
                    // Elements
                    ForEach(viewModel.sortedElements.filter(\.isVisible)) { element in
                        canvasElementView(element, displayWidth: displayWidth, displayHeight: displayHeight)
                    }
                    
                    // Quick action toolbar for selected element
                    if let element = viewModel.selectedElement,
                       draggingElementId == nil {
                        let scaleX = displayWidth / viewModel.canvasWidth
                        let scaleY = displayHeight / viewModel.canvasHeight
                        let elH = element.size.height * scaleY * element.scale
                        
                        ElementQuickActions(
                            onDuplicate: {
                                viewModel.duplicateElement(element.id)
                                HapticManager.softTap()
                            },
                            onDelete: {
                                viewModel.removeElement(element.id)
                                HapticManager.softTap()
                            },
                            onFlipH: {
                                viewModel.updateElement(element.id) { el in
                                    el.flipX.toggle()
                                }
                                HapticManager.selection()
                            },
                            onFlipV: {
                                viewModel.updateElement(element.id) { el in
                                    el.flipY.toggle()
                                }
                                HapticManager.selection()
                            },
                            onLock: {
                                viewModel.toggleLock(element.id)
                                HapticManager.selection()
                            },
                            isLocked: element.isLocked
                        )
                        .position(
                            x: element.position.x * scaleX,
                            y: max(30, element.position.y * scaleY - elH / 2 - 70)
                        )
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(9999)
                    }
                    
                    // Alignment guides overlay
                    AlignmentGuideOverlay(showHorizontal: showAlignH, showVertical: showAlignV)
                        .animation(.easeInOut(duration: 0.15), value: showAlignH)
                        .animation(.easeInOut(duration: 0.15), value: showAlignV)
                }
                .frame(width: displayWidth, height: displayHeight)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
                .onTapGesture {
                    viewModel.selectElement(nil)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func canvasElementView(_ element: CanvasElement, displayWidth: CGFloat, displayHeight: CGFloat) -> some View {
        let scaleX = displayWidth / viewModel.canvasWidth
        let scaleY = displayHeight / viewModel.canvasHeight
        let isSelected = viewModel.selectedElementIds.contains(element.id)
        let elW = element.size.width * scaleX
        let elH = element.size.height * scaleY
        let isDragging = draggingElementId == element.id

        // Live transforms applied to the actively-manipulated element
        let liveScale = isDragging ? currentMagnification : 1.0
        let liveRotation = isDragging ? currentRotation.degrees : 0.0
        let liveOffsetX = isDragging ? dragTranslation.width : 0
        let liveOffsetY = isDragging ? dragTranslation.height : 0

        // Live corner-resize → uniform scale from opposite corner anchor
        let baseW = elW * element.scale
        let baseH = elH * element.scale
        let halfDiag = sqrt(baseW * baseW + baseH * baseH) / 2

        let liveResizeScale: CGFloat = {
            guard let c = resizeCorner, isSelected, halfDiag > 0 else { return 1.0 }
            // Vector from element center to the dragged corner (in screen pts)
            let cornerX: CGFloat = (c == .topLeft || c == .bottomLeft) ? -baseW / 2 : baseW / 2
            let cornerY: CGFloat = (c == .topLeft || c == .topRight) ? -baseH / 2 : baseH / 2
            // New corner position after translation
            let newX = cornerX + resizeTranslation.width
            let newY = cornerY + resizeTranslation.height
            let newHalfDiag = sqrt(newX * newX + newY * newY)
            return max(0.1, min(newHalfDiag / halfDiag, 8.0))
        }()

        // Live rotation handle preview
        let liveHandleRotation = isSelected ? handleRotation.degrees : 0.0

        let dragGesture = DragGesture(minimumDistance: 0)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .updating($draggingElementId) { _, state, _ in
                state = element.id
            }
            .onChanged { value in
                let newX = element.position.x + value.translation.width / scaleX
                let newY = element.position.y + value.translation.height / scaleY
                let centerX = viewModel.canvasWidth / 2
                let centerY = viewModel.canvasHeight / 2
                let snapThreshold: CGFloat = 10
                let nextV = abs(newX - centerX) < snapThreshold
                let nextH = abs(newY - centerY) < snapThreshold
                if nextV != showAlignV { showAlignV = nextV }
                if nextH != showAlignH { showAlignH = nextH }
            }
            .onEnded { value in
                var finalX = element.position.x + value.translation.width / scaleX
                var finalY = element.position.y + value.translation.height / scaleY
                let centerX = viewModel.canvasWidth / 2
                let centerY = viewModel.canvasHeight / 2
                let snapThreshold: CGFloat = 10
                if abs(finalX - centerX) < snapThreshold {
                    finalX = centerX
                    HapticManager.selection()
                }
                if abs(finalY - centerY) < snapThreshold {
                    finalY = centerY
                    HapticManager.selection()
                }
                viewModel.updateElement(element.id) { el in
                    el.position.x = finalX
                    el.position.y = finalY
                }
                showAlignH = false
                showAlignV = false
            }

        let magnifyGesture = MagnifyGesture(minimumScaleDelta: 0.01)
            .updating($currentMagnification) { value, state, _ in
                state = value.magnification
            }
            .updating($draggingElementId) { _, state, _ in
                state = element.id
            }
            .onEnded { value in
                viewModel.updateElement(element.id) { el in
                    el.scale = max(0.1, min(el.scale * value.magnification, 5.0))
                }
            }

        let rotateGesture = RotateGesture(minimumAngleDelta: .degrees(1))
            .updating($currentRotation) { value, state, _ in
                state = value.rotation
            }
            .updating($draggingElementId) { _, state, _ in
                state = element.id
            }
            .onEnded { value in
                viewModel.updateElement(element.id) { el in
                    el.rotation += value.rotation.degrees
                    let snapped = snapAngle(el.rotation)
                    if abs(el.rotation - snapped) < 3 {
                        el.rotation = snapped
                        HapticManager.selection()
                    }
                }
            }

        return Group {
            elementContent(element)
        }
        .frame(width: elW, height: elH)
        .scaleEffect(
            x: element.scale * liveScale * liveResizeScale * (element.flipX ? -1 : 1),
            y: element.scale * liveScale * liveResizeScale * (element.flipY ? -1 : 1)
        )
        .opacity(element.opacity)
        .overlay(
            (isSelected && !element.isLocked && !isDragging) ?
            SelectionHandlesOverlay(
                width: elW * element.scale * liveResizeScale,
                height: elH * element.scale * liveResizeScale,
                onResizeCorner: { corner, translation in
                    resizeCorner = corner
                    resizeTranslation = translation
                },
                onResizeEnd: { _, _ in
                    // Commit the live scale factor we already computed
                    let finalScale = liveResizeScale
                    viewModel.updateElement(element.id) { el in
                        el.scale = max(0.1, min(el.scale * finalScale, 8.0))
                    }
                    resizeCorner = nil
                    resizeTranslation = .zero
                    HapticManager.selection()
                },
                onRotateDelta: { angle in
                    handleRotation = angle
                },
                onRotateEnd: { angle in
                    viewModel.updateElement(element.id) { el in
                        el.rotation += angle.degrees
                        let snapped = snapAngle(el.rotation)
                        if abs(el.rotation - snapped) < 3 {
                            el.rotation = snapped
                            HapticManager.selection()
                        }
                    }
                    handleRotation = .zero
                }
            )
            : nil
        )
        .rotationEffect(.degrees(element.rotation + liveRotation + liveHandleRotation))
        .position(
            x: element.position.x * scaleX + liveOffsetX,
            y: element.position.y * scaleY + liveOffsetY
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectElement(element.id)
            }
            if element.type == .text { showTextEditor = true }
        }
        .gesture(element.isLocked ? nil : dragGesture)
        .simultaneousGesture(element.isLocked ? nil : magnifyGesture)
        .simultaneousGesture(element.isLocked ? nil : rotateGesture)
    }
    
    /// Snap angle to nearest 0/90/180/270
    private func snapAngle(_ angle: Double) -> Double {
        let targets = [0.0, 90.0, 180.0, 270.0, 360.0, -90.0, -180.0, -270.0]
        return targets.min(by: { abs($0 - angle) < abs($1 - angle) }) ?? angle
    }
    
    @ViewBuilder
    private func elementContent(_ element: CanvasElement) -> some View {
        switch element.type {
        case .text:
            if let text = element.text {
                let style = element.textStyle ?? TextStyle()
                let displayFont = resolveFont(style: style, scale: 0.4)
                
                // Check for curved text
                if abs(style.curveAngle) > 1 {
                    CurvedTextView(
                        text: text,
                        curveAngle: style.curveAngle,
                        font: displayFont,
                        uiFont: resolveUIFont(style: style, scale: 0.4),
                        color: style.fillType == .solid ? Color(hex: style.textColor) : DS.Colors.primary
                    )
                } else {
                    let textView = Text(text)
                        .font(displayFont)
                        .multilineTextAlignment(style.alignment.systemAlignment)
                        .tracking(style.letterSpacing)
                        .lineSpacing(style.lineSpacing * 0.3)
                        .environment(\.layoutDirection, style.isRTL ? .rightToLeft : .leftToRight)
                
                // Apply fill type
                switch style.fillType {
                case .solid:
                    textView
                        .foregroundColor(Color(hex: style.textColor))
                        .shadow(
                            color: style.shadowEnabled ? Color(hex: style.shadowColor).opacity(0.5) : .clear,
                            radius: style.shadowRadius * 0.3, x: 0, y: 2
                        )
                case .gradient:
                    textView
                        .foregroundStyle(
                            LinearGradient(
                                colors: style.gradientColors.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: style.shadowEnabled ? Color(hex: style.shadowColor).opacity(0.5) : .clear,
                            radius: style.shadowRadius * 0.3, x: 0, y: 2
                        )
                case .image:
                    textView
                        .foregroundColor(Color(hex: style.textColor))
                }
                } // end of else (non-curved)
            }
        case .image:
            if let imageData = element.useBackgroundRemoved ? element.backgroundRemovedData ?? element.imageData : element.imageData,
               let uiImage = UIImage(data: imageData) {
                let imageView = Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                if element.maskShape != .none {
                    element.maskShape.clipView(content: imageView)
                } else {
                    imageView
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            } else if let imageName = element.imageName {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(DS.Colors.textSecondary)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DS.Colors.surface)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(DS.Colors.textTertiary)
                    )
            }
        case .sticker:
            if let stickerName = element.stickerName {
                if UIImage(named: stickerName) != nil {
                    Image(stickerName)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(DS.Colors.primary)
                } else {
                    Image(systemName: stickerName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(DS.Colors.primary)
                }
            }
        case .shape:
            if let style = element.shapeStyle {
                shapeView(style)
            }
        case .video:
            RoundedRectangle(cornerRadius: 8)
                .fill(DS.Colors.bgElevated)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DS.Colors.textTertiary)
                )
        }
    }
    
    @ViewBuilder
    private func shapeView(_ style: ShapeStyleData) -> some View {
        switch style.shapeType {
        case .rectangle:
            Rectangle().fill(Color(hex: style.fillColor))
        case .circle:
            Circle().fill(Color(hex: style.fillColor))
        case .roundedRect:
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(Color(hex: style.fillColor))
        case .triangle:
            Triangle().fill(Color(hex: style.fillColor))
        case .star:
            Image(systemName: "star.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .hexagon:
            Image(systemName: "hexagon.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .arrow:
            Image(systemName: "arrowshape.right.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .speechBubble:
            Image(systemName: "bubble.right.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .banner:
            Image(systemName: "flag.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .pentagon:
            Image(systemName: "pentagon.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .cross:
            Image(systemName: "cross.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .diamond:
            Image(systemName: "diamond.fill")
                .resizable()
                .foregroundColor(Color(hex: style.fillColor))
        case .ring:
            Circle()
                .strokeBorder(Color(hex: style.fillColor), lineWidth: 6)
        }
    }
    
    // MARK: - Bottom Toolbar
    private var editorBottomToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.lg) {
                editorToolButton(icon: "textformat", label: "Text", panel: .text)
                editorToolButton(icon: "photo", label: "Photo", panel: .photo)
                editorToolButton(icon: "face.smiling", label: "Stickers", panel: .stickers)
                editorToolButton(icon: "square.on.circle", label: "Shapes", panel: .shapes)
                editorToolButton(icon: "paintbrush", label: "Background", panel: .background)
                editorToolButton(icon: "wand.and.stars", label: "Filters", panel: .filters)
                editorToolButton(icon: "sparkles", label: "Effects", panel: .effects)
                
                if !viewModel.selectedElementIds.isEmpty {
                    Divider().frame(height: 30).opacity(0.3)
                    
                    // Opacity
                    Button {
                        withAnimation(AnimationPreset.springSnappy) {
                            activeToolPanel = activeToolPanel == .opacity ? nil : .opacity
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "circle.lefthalf.filled")
                                .font(.system(size: 20))
                            Text("Opacity")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(activeToolPanel == .opacity ? DS.Colors.primary : DS.Colors.textSecondary)
                    }
                    
                    // Mask (for images only)
                    if viewModel.selectedElement?.type == .image {
                        Button {
                            withAnimation(AnimationPreset.springSnappy) {
                                activeToolPanel = activeToolPanel == .mask ? nil : .mask
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "heart.circle.fill")
                                    .font(.system(size: 20))
                                Text("Mask")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(activeToolPanel == .mask ? DS.Colors.primary : DS.Colors.textSecondary)
                        }
                        
                        // Remove BG
                        Button {
                            removeBackgroundFromSelected()
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Image(systemName: bgRemovalService.isProcessing ? "progress.indicator" : "person.crop.rectangle")
                                        .font(.system(size: 20))
                                    if bgRemovalService.isProcessing {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                    }
                                }
                                Text("Remove BG")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(DS.Colors.accent)
                        }
                        .disabled(bgRemovalService.isProcessing)
                        
                        // Replace image
                        Button {
                            showReplacePicker = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.system(size: 20))
                                Text("Replace")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(DS.Colors.textSecondary)
                        }
                        
                        // Crop
                        Button {
                            cropRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
                            showCropOverlay = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "crop")
                                    .font(.system(size: 20))
                                Text("Crop")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                    
                    // Text Fill (for text only)
                    if viewModel.selectedElement?.type == .text {
                        Button {
                            withAnimation(AnimationPreset.springSnappy) {
                                activeToolPanel = activeToolPanel == .textFill ? nil : .textFill
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 20))
                                Text("Fill")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(activeToolPanel == .textFill ? DS.Colors.primary : DS.Colors.textSecondary)
                        }
                    }
                    
                    // Copy
                    Button {
                        for id in viewModel.selectedElementIds {
                            viewModel.duplicateElement(id)
                        }
                        HapticManager.softTap()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "plus.square.on.square")
                                .font(.system(size: 20))
                            Text("Copy")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(DS.Colors.info)
                    }
                    
                    // Delete
                    Button {
                        withAnimation {
                            for id in viewModel.selectedElementIds {
                                viewModel.removeElement(id)
                            }
                        }
                        HapticManager.notification(.warning)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                            Text("Delete")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(DS.Colors.error)
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
        .padding(.vertical, DS.Spacing.sm)
        .background(
            DS.Colors.bgSecondary
                .overlay(alignment: .top) { Divider().opacity(0.2) }
        )
    }
    
    private func editorToolButton(icon: String, label: String, panel: EditorToolPanel) -> some View {
        Button {
            withAnimation(AnimationPreset.springSnappy) {
                if activeToolPanel == panel {
                    activeToolPanel = nil
                } else {
                    activeToolPanel = panel
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(activeToolPanel == panel ? DS.Colors.primary : DS.Colors.textSecondary)
        }
    }
    
    // MARK: - Tool Panels
    @ViewBuilder
    private func toolPanel(_ panel: EditorToolPanel) -> some View {
        VStack(spacing: 0) {
            // Panel drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(DS.Colors.textTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, DS.Spacing.xs)
            
            switch panel {
            case .text:
                textToolPanel
            case .photo:
                photoToolPanel
            case .stickers:
                stickerToolPanel
            case .shapes:
                shapesToolPanel
            case .background:
                backgroundToolPanel
            case .filters:
                filtersToolPanel
            case .effects:
                effectsToolPanel
            case .opacity:
                opacityToolPanel
            case .mask:
                maskToolPanel
            case .textFill:
                textFillToolPanel
            }
        }
        .frame(height: 200)
        .background(DS.Colors.bgSecondary)
    }
    
    // Tool panel content implementations
    private var textToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.sm) {
                Button {
                    viewModel.addText("Your Text Here")
                    showTextEditor = true
                } label: {
                    textPresetCard(title: "Add Text", titleAr: "أضف نص", icon: "textformat")
                }
                Button {
                    viewModel.addText("أدخل النص هنا", isArabic: true)
                    showTextEditor = true
                } label: {
                    textPresetCard(title: "Arabic Text", titleAr: "نص عربي", icon: "character")
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(["Heading", "Subheading", "Body", "Caption"], id: \.self) { style in
                        Button {
                            let fontSize: CGFloat = style == "Heading" ? 36 : style == "Subheading" ? 28 : style == "Body" ? 20 : 14
                            var el = CanvasElement.textElement(style)
                            el.textStyle?.fontSize = fontSize
                            el.textStyle?.isBold = style == "Heading"
                            viewModel.addElement(el)
                        } label: {
                            Text(style)
                                .font(style == "Heading" ? .title3.bold() : style == "Subheading" ? .headline : .body)
                                .foregroundColor(DS.Colors.textPrimary)
                                .padding(.horizontal, DS.Spacing.md)
                                .padding(.vertical, DS.Spacing.sm)
                                .background(DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
        .padding(.top, DS.Spacing.sm)
    }
    
    private func textPresetCard(title: String, titleAr: String, icon: String) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(DS.Colors.primary)
            Text(title)
                .font(DS.Typography.captionSmall)
                .foregroundColor(DS.Colors.textPrimary)
            Text(titleAr)
                .font(.system(size: 10))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.md)
        .background(DS.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
    }
    
    private var photoToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack(spacing: DS.Spacing.sm) {
                photoSourceButton(icon: "photo.on.rectangle", title: "Gallery", titleAr: "المعرض", color: DS.Colors.info) {
                    showPhotoPicker = true
                }
                photoSourceButton(icon: "camera", title: "Camera", titleAr: "كاميرا", color: DS.Colors.accent) {
                    // Camera integration (requires UIImagePickerController)
                }
                photoSourceButton(icon: "photo.stack", title: "Stock", titleAr: "مكتبة", color: DS.Colors.success) {
                    // Stock photo browser
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.top, DS.Spacing.sm)
            Spacer()
        }
    }
    
    private func photoSourceButton(icon: String, title: String, titleAr: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                Text(title)
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textPrimary)
                Text(titleAr)
                    .font(.system(size: 9))
                    .foregroundColor(DS.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.lg)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        }
    }
    
    private var stickerToolPanel: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.sm), count: 6), spacing: DS.Spacing.sm) {
                ForEach(StickerItem.sampleStickers) { sticker in
                    Button {
                        viewModel.addSticker(sticker.systemIcon)
                    } label: {
                        Group {
                            if UIImage(named: sticker.systemIcon) != nil {
                                Image(sticker.systemIcon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: sticker.systemIcon)
                            }
                        }
                        .font(.system(size: 28))
                        .foregroundColor(DS.Colors.primary)
                        .frame(width: 48, height: 48)
                        .background(DS.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
                    }
                }
            }
            .padding(DS.Spacing.md)
        }
    }
    
    private var shapesToolPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(ShapeType.allCases, id: \.self) { shape in
                    Button {
                        viewModel.addShape(shape)
                    } label: {
                        VStack(spacing: DS.Spacing.xs) {
                            Image(systemName: shape.icon)
                                .font(.system(size: 30))
                                .foregroundColor(DS.Colors.primary)
                                .frame(width: 60, height: 60)
                                .background(DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            Text(shape.rawValue)
                                .font(.system(size: 10))
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                }
            }
            .padding(DS.Spacing.md)
        }
    }
    
    private var backgroundToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            // Tab selector: Colors | Textures
            HStack(spacing: DS.Spacing.sm) {
                bgTabButton("Colors", icon: "paintbrush.fill", isActive: bgTab == .colors)
                bgTabButton("Gradients", icon: "paintpalette.fill", isActive: bgTab == .gradients)
                bgTabButton("Textures", icon: "rectangle.dashed", isActive: bgTab == .textures)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.top, DS.Spacing.sm)
            
            ScrollView(.horizontal, showsIndicators: false) {
                switch bgTab {
                case .colors:
                    HStack(spacing: DS.Spacing.sm) {
                        let colors: [Color] = [
                            DS.Colors.bgPrimary, .white, .black,
                            Color(hex: "D4A853"), Color(hex: "E8734A"),
                            Color(hex: "5AC8FA"), Color(hex: "34C759"),
                            Color(hex: "AF52DE"), Color(hex: "FF6B8A"),
                            Color(hex: "1A237E"), Color(hex: "2E7D32"),
                            Color(hex: "F5F5DC"), Color(hex: "8B4513"),
                            Color(hex: "4A0E4E"), Color(hex: "0C2340"),
                        ]
                        ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                            Button {
                                viewModel.setBackground(color: color)
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(DS.Colors.surfaceBorder, lineWidth: 2))
                            }
                        }
                    }
                    .padding(DS.Spacing.md)
                    
                case .gradients:
                    HStack(spacing: DS.Spacing.sm) {
                        let gradients: [[Color]] = [
                            [Color(hex: "D4A853"), Color(hex: "8B6914")],
                            [Color(hex: "667eea"), Color(hex: "764ba2")],
                            [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                            [Color(hex: "43e97b"), Color(hex: "38f9d7")],
                            [Color(hex: "141E30"), Color(hex: "243B55")],
                            [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                            [Color(hex: "ff9a9e"), Color(hex: "fecfef")],
                            [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
                            [Color(hex: "ffecd2"), Color(hex: "fcb69f")],
                        ]
                        ForEach(Array(gradients.enumerated()), id: \.offset) { _, g in
                            Button {
                                viewModel.setBackgroundGradient(colors: g)
                            } label: {
                                Circle()
                                    .fill(LinearGradient(colors: g, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(DS.Colors.surfaceBorder, lineWidth: 2))
                            }
                        }
                    }
                    .padding(DS.Spacing.md)
                    
                case .textures:
                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(TextureBackground.textures) { tex in
                            let isActive = viewModel.backgroundTexture == tex.id
                            Button {
                                viewModel.setBackgroundTexture(tex.id)
                            } label: {
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(
                                            colors: tex.colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 56, height: 44)
                                        .overlay(
                                            // Simulated texture noise pattern
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.ultraThinMaterial)
                                                .opacity(tex.style == .grain ? 0.4 : 0.15)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(isActive ? DS.Colors.primary : Color.clear, lineWidth: 2)
                                        )
                                    Text(tex.name)
                                        .font(.system(size: 8))
                                        .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textTertiary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(DS.Spacing.md)
                }
            }
        }
    }
    
    @State private var bgTab: BgTabType = .colors
    
    enum BgTabType { case colors, gradients, textures }
    
    private func bgTabButton(_ label: String, icon: String, isActive: Bool) -> some View {
        Button {
            withAnimation(AnimationPreset.springSnappy) {
                switch label {
                case "Colors": bgTab = .colors
                case "Gradients": bgTab = .gradients
                default: bgTab = .textures
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
            }
            .foregroundColor(isActive ? DS.Colors.textInverse : DS.Colors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? DS.Colors.goldGradient : LinearGradient(colors: [DS.Colors.surface, DS.Colors.surface], startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
        }
    }
    
    private var filtersToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            if viewModel.selectedElement?.type == .image {
                HStack {
                    Image(systemName: "camera.filters")
                        .foregroundColor(DS.Colors.primary)
                    Text("Photo Filters")
                        .font(DS.Typography.bodyMedium)
                        .foregroundColor(DS.Colors.textPrimary)
                    Spacer()
                    if viewModel.selectedElement?.filterName != nil {
                        Button {
                            if let id = viewModel.selectedElement?.id {
                                viewModel.applyFilter(nil, to: id)
                                HapticManager.selection()
                            }
                        } label: {
                            Text("Reset")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DS.Colors.accent)
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.sm)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.sm) {
                        ForEach(PhotoFilter.filters) { filter in
                            let isActive = viewModel.selectedElement?.filterName == filter.ciFilterName
                            Button {
                                if let id = viewModel.selectedElement?.id {
                                    viewModel.applyFilter(filter.ciFilterName, to: id)
                                    HapticManager.selection()
                                }
                            } label: {
                                VStack(spacing: DS.Spacing.xs) {
                                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                                        .fill(
                                            filter.ciFilterName == nil
                                                ? LinearGradient(colors: [DS.Colors.surface, DS.Colors.surface], startPoint: .top, endPoint: .bottom)
                                                : LinearGradient(colors: [DS.Colors.surface, DS.Colors.bgElevated], startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: filter.ciFilterName == nil ? "photo" : "camera.filters")
                                                .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textTertiary)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                                .strokeBorder(isActive ? DS.Colors.primary : Color.clear, lineWidth: 2)
                                        )
                                    Text(filter.name)
                                        .font(.system(size: 10))
                                        .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textSecondary)
                                }
                            }
                        }
                        
                        // Extra filters not in the default list
                        ForEach([
                            ("Bloom", "CIBloom"),
                            ("Vignette", "CIVignette"),
                            ("Sharpen", "CISharpenLuminance"),
                            ("Blur", "CIGaussianBlur"),
                            ("Invert", "CIColorInvert"),
                            ("Comic", "CIComicEffect"),
                            ("Poster", "CIColorPosterize"),
                            ("Edges", "CIEdges"),
                            ("Crystal", "CICrystallize"),
                        ], id: \.0) { name, ciName in
                            let isActive = viewModel.selectedElement?.filterName == ciName
                            Button {
                                if let id = viewModel.selectedElement?.id {
                                    viewModel.applyFilter(ciName, to: id)
                                    HapticManager.selection()
                                }
                            } label: {
                                VStack(spacing: DS.Spacing.xs) {
                                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                                        .fill(LinearGradient(colors: [DS.Colors.surface, DS.Colors.bgElevated], startPoint: .top, endPoint: .bottom))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "camera.filters")
                                                .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textTertiary)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                                .strokeBorder(isActive ? DS.Colors.primary : Color.clear, lineWidth: 2)
                                        )
                                    Text(name)
                                        .font(.system(size: 10))
                                        .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                }
            } else {
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "photo.badge.arrow.down")
                        .font(.system(size: 36))
                        .foregroundColor(DS.Colors.textTertiary)
                    Text("Select an image to apply filters")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var effectsToolPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(ElementAnimation.allCases) { anim in
                    Button {
                        if let id = viewModel.selectedElement?.id {
                            viewModel.updateElement(id) { $0.enterAnimation = anim }
                        }
                    } label: {
                        VStack(spacing: DS.Spacing.xs) {
                            Image(systemName: anim.icon)
                                .font(.system(size: 22))
                                .foregroundColor(DS.Colors.primary)
                                .frame(width: 50, height: 50)
                                .background(DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            Text(anim.rawValue)
                                .font(.system(size: 9))
                                .foregroundColor(DS.Colors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(DS.Spacing.md)
        }
    }
    
    // MARK: - Save Project
    private func saveProject() {
        let projectId = viewModel.currentProjectId ?? UUID()
        let projectName = viewModel.currentProjectName.isEmpty
            ? "Design \(Date().formatted(.dateTime.month(.abbreviated).day()))"
            : viewModel.currentProjectName
        
        print("[SAVE] Starting save: id=\(projectId), elements=\(viewModel.elements.count)")
        
        let savedElements = viewModel.elements.map { $0.toSaved() }
        let project = SavedProject(
            id: projectId,
            name: projectName,
            nameAr: "تصميم",
            canvasWidth: viewModel.canvasWidth,
            canvasHeight: viewModel.canvasHeight,
            backgroundColor: CodableColor(hex: viewModel.backgroundColor.toHex()),
            gradientColors: viewModel.backgroundGradientColors.map { CodableColor(hex: $0.toHex()) },
            elements: savedElements,
            createdAt: viewModel.currentProjectId == nil ? Date() : Date(), // first save vs update
            modifiedAt: Date()
        )
        
        do {
            try storageService.saveProject(project)
            
            // Remember the project ID for future saves in this session
            viewModel.currentProjectId = projectId
            viewModel.currentProjectName = projectName
            
            print("[SAVE] ✅ Project saved: \(projectId) with \(savedElements.count) elements")
            
            // Generate and save thumbnail
            let renderService = CanvasRenderService()
            if let thumbnail = renderService.renderCanvas(viewModel: viewModel, scale: 0.15) {
                try? storageService.saveThumbnail(thumbnail, for: projectId)
                print("[SAVE] ✅ Thumbnail saved")
            }
            
            HapticManager.success()
            withAnimation(AnimationPreset.springSnappy) {
                showSaveConfirm = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showSaveConfirm = false }
            }
        } catch {
            print("[SAVE] ❌ ERROR: \(error)")
            HapticManager.error()
        }
    }
    
    // MARK: - Opacity Tool Panel
    private var opacityToolPanel: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                    .foregroundColor(DS.Colors.primary)
                Text("Element Opacity")
                    .font(DS.Typography.bodyMedium)
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
                Text("\(Int(selectedElementOpacity * 100))%")
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.primary)
                    .monospacedDigit()
            }
            
            Slider(value: $selectedElementOpacity, in: 0...1, step: 0.01)
                .tint(DS.Colors.primary)
                .onChange(of: selectedElementOpacity) { _, newVal in
                    if let id = viewModel.selectedElement?.id {
                        viewModel.updateElement(id) { el in
                            el.opacity = newVal
                        }
                    }
                }
                .onAppear {
                    selectedElementOpacity = viewModel.selectedElement?.opacity ?? 1.0
                }
            
            // Quick presets
            HStack(spacing: DS.Spacing.sm) {
                ForEach([1.0, 0.75, 0.5, 0.25, 0.0], id: \.self) { val in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedElementOpacity = val
                        }
                    } label: {
                        Text("\(Int(val * 100))%")
                            .font(.system(size: 12, weight: selectedElementOpacity == val ? .bold : .regular))
                            .foregroundColor(selectedElementOpacity == val ? DS.Colors.textInverse : DS.Colors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedElementOpacity == val ? DS.Colors.primary : DS.Colors.surface)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    // MARK: - Mask Tool Panel
    private var maskToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(DS.Colors.primary)
                Text("Photo Mask")
                    .font(DS.Typography.bodyMedium)
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
                
                // Toggle BG removed
                if viewModel.selectedElement?.backgroundRemovedData != nil {
                    Button {
                        if let id = viewModel.selectedElement?.id {
                            viewModel.updateElement(id) { el in
                                el.useBackgroundRemoved.toggle()
                            }
                            HapticManager.selection()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.selectedElement?.useBackgroundRemoved == true ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 14))
                            Text("No BG")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(DS.Colors.accent)
                    }
                }
            }
            
            // Mask shape grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(MaskShape.allCases, id: \.self) { mask in
                        let isSelected = viewModel.selectedElement?.maskShape == mask
                        Button {
                            if let id = viewModel.selectedElement?.id {
                                viewModel.updateElement(id) { el in
                                    el.maskShape = mask
                                }
                                HapticManager.selection()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? DS.Colors.primary.opacity(0.15) : DS.Colors.surface)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: mask.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
                                }
                                Text(mask.rawValue)
                                    .font(.system(size: 9))
                                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.textTertiary)
                            }
                        }
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    // MARK: - Text Fill Tool Panel
    private var textFillToolPanel: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(DS.Colors.primary)
                Text("Text Fill")
                    .font(DS.Typography.bodyMedium)
                    .foregroundColor(DS.Colors.textPrimary)
                Spacer()
            }
            
            // Fill type selector
            HStack(spacing: DS.Spacing.sm) {
                ForEach(TextFillType.allCases, id: \.self) { fillType in
                    let isActive = viewModel.selectedElement?.textStyle?.fillType == fillType
                    Button {
                        if let id = viewModel.selectedElement?.id {
                            viewModel.updateElement(id) { el in
                                el.textStyle?.fillType = fillType
                            }
                            HapticManager.selection()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: fillType.icon)
                                .font(.system(size: 14))
                            Text(fillType.rawValue)
                                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                        }
                        .foregroundColor(isActive ? DS.Colors.textInverse : DS.Colors.textSecondary)
                        .padding(.horizontal, DS.Spacing.sm)
                        .padding(.vertical, 8)
                        .background(isActive ? DS.Colors.goldGradient : LinearGradient(colors: [DS.Colors.surface, DS.Colors.surface], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Gradient presets (shown when gradient is selected)
            if viewModel.selectedElement?.textStyle?.fillType == .gradient {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.sm) {
                        gradientPresetButton("Gold", colors: ["#D4A853", "#F0D48A", "#D4A853"])
                        gradientPresetButton("Rose", colors: ["#FF6B8A", "#FFB88C", "#FF6B8A"])
                        gradientPresetButton("Ocean", colors: ["#667eea", "#764ba2"])
                        gradientPresetButton("Sunset", colors: ["#f093fb", "#f5576c"])
                        gradientPresetButton("Emerald", colors: ["#11998e", "#38ef7d"])
                        gradientPresetButton("Silver", colors: ["#bdc3c7", "#ecf0f1", "#bdc3c7"])
                        gradientPresetButton("Fire", colors: ["#f12711", "#f5af19"])
                        gradientPresetButton("Royal", colors: ["#141E30", "#D4A853"])
                        gradientPresetButton("Ice", colors: ["#a1c4fd", "#c2e9fb"])
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    private func gradientPresetButton(_ name: String, colors: [String]) -> some View {
        let isActive = viewModel.selectedElement?.textStyle?.gradientColors == colors
        return Button {
            if let id = viewModel.selectedElement?.id {
                viewModel.updateElement(id) { el in
                    el.textStyle?.fillType = .gradient
                    el.textStyle?.gradientColors = colors
                }
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: colors.map { Color(hex: $0) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isActive ? DS.Colors.primary : Color.clear, lineWidth: 2)
                    )
                Text(name)
                    .font(.system(size: 9))
                    .foregroundColor(isActive ? DS.Colors.primary : DS.Colors.textTertiary)
            }
        }
    }
    
    // MARK: - AI Background Removal
    private func removeBackgroundFromSelected() {
        guard let id = viewModel.selectedElement?.id,
              let element = viewModel.selectedElement,
              element.type == .image,
              let imageData = element.imageData,
              let uiImage = UIImage(data: imageData) else { return }
        
        HapticManager.softTap()
        
        Task {
            var resultImage: UIImage?
            
            if #available(iOS 17.0, *) {
                // Use subject lifting for better results on any object
                resultImage = await bgRemovalService.removeBackgroundSubjectLifting(from: uiImage)
            }
            
            // Fallback to person segmentation
            if resultImage == nil {
                resultImage = await bgRemovalService.removeBackground(from: uiImage, quality: .accurate)
            }
            
            if let result = resultImage, let pngData = result.pngData() {
                await MainActor.run {
                    viewModel.updateElement(id) { el in
                        el.backgroundRemovedData = pngData
                        el.useBackgroundRemoved = true
                    }
                    HapticManager.success()
                }
            } else {
                await MainActor.run {
                    HapticManager.error()
                }
            }
        }
    }
    
    // MARK: - Font Resolver
    /// Converts a TextStyle's fontName + fontSize into a proper SwiftUI Font
    private func resolveFont(style: TextStyle, scale: CGFloat) -> Font {
        let size = style.fontSize * scale
        if style.fontName == "System" || style.fontName.isEmpty {
            return .system(size: size, weight: style.isBold ? .bold : .regular, design: .default)
        }
        // Use Font.custom for named fonts
        var font = Font.custom(style.fontName, size: size)
        if style.isBold {
            font = font.bold()
        }
        if style.isItalic {
            font = font.italic()
        }
        return font
    }
    
    /// Converts a TextStyle into a UIFont for measurement (used by CurvedTextView)
    private func resolveUIFont(style: TextStyle, scale: CGFloat) -> UIFont {
        let size = style.fontSize * scale
        if style.fontName == "System" || style.fontName.isEmpty {
            return UIFont.systemFont(ofSize: size, weight: style.isBold ? .bold : .regular)
        }
        if let font = UIFont(name: style.fontName, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size)
    }
}

// MARK: - Conditional View Modifier
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Editor Tool Panel Enum
enum EditorToolPanel: Equatable {
    case text, photo, stickers, shapes, background, filters, effects
    case opacity, mask, textFill
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

