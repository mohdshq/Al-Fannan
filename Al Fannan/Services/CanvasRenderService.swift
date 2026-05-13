import SwiftUI

// MARK: - Canvas Render Service  
@Observable
class CanvasRenderService {
    
    /// Renders the canvas to a UIImage at the given scale
    @MainActor
    func renderCanvas(
        viewModel: CanvasViewModel,
        scale: CGFloat = 1.0,
        transparent: Bool = false
    ) -> UIImage? {
        let width = viewModel.canvasWidth
        let height = viewModel.canvasHeight
        let canvasSize = CGSize(width: width * scale, height: height * scale)
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = !transparent
        format.scale = 1.0  // We handle scaling ourselves
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.scaleBy(x: scale, y: scale)
            
            if !transparent {
                // Draw background
                if let texId = viewModel.backgroundTexture,
                   let tex = TextureBackground.textures.first(where: { $0.id == texId }) {
                    // Texture background — draw gradient
                    let colors = tex.colors.map { UIColor($0).cgColor }
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) {
                        ctx.drawLinearGradient(
                            gradient,
                            start: .zero,
                            end: CGPoint(x: width, y: height),
                            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
                        )
                    }
                } else if viewModel.backgroundGradientColors.isEmpty {
                    // Solid color
                    let uiColor = UIColor(viewModel.backgroundColor)
                    ctx.setFillColor(uiColor.cgColor)
                    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
                } else {
                    // Gradient
                    let colors = viewModel.backgroundGradientColors.map { UIColor($0).cgColor }
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) {
                        ctx.drawLinearGradient(
                            gradient,
                            start: .zero,
                            end: CGPoint(x: width, y: height),
                            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
                        )
                    }
                }
            }
            
            // Draw each visible element
            for element in viewModel.sortedElements where element.isVisible {
                ctx.saveGState()
                
                // Apply transforms
                ctx.translateBy(x: element.position.x, y: element.position.y)
                ctx.rotate(by: CGFloat(element.rotation * .pi / 180))
                ctx.scaleBy(
                    x: element.scale * (element.flipX ? -1 : 1),
                    y: element.scale * (element.flipY ? -1 : 1)
                )
                ctx.setAlpha(CGFloat(element.opacity))
                
                let drawRect = CGRect(
                    x: -element.size.width / 2,
                    y: -element.size.height / 2,
                    width: element.size.width,
                    height: element.size.height
                )
                
                switch element.type {
                case .text:
                    drawTextElement(element, in: drawRect, ctx: ctx)
                case .image:
                    drawImageElement(element, in: drawRect, ctx: ctx)
                case .shape:
                    drawShapeElement(element, in: drawRect, ctx: ctx)
                case .sticker:
                    drawStickerElement(element, in: drawRect, ctx: ctx)
                case .video:
                    break // Video frame rendering would go here
                }
                
                ctx.restoreGState()
            }
        }
    }
    
    private func drawTextElement(_ element: CanvasElement, in rect: CGRect, ctx: CGContext) {
        guard let text = element.text, let style = element.textStyle else { return }
        
        let weight: UIFont.Weight = style.isBold ? .bold : .regular
        let font: UIFont
        if style.fontName == "System" || style.fontName.isEmpty {
            font = UIFont.systemFont(ofSize: style.fontSize, weight: weight)
        } else {
            // Try the exact PostScript name first, then fall back
            font = UIFont(name: style.fontName, size: style.fontSize)
                ?? UIFont.systemFont(ofSize: style.fontSize, weight: weight)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        switch style.alignment {
        case .leading: paragraphStyle.alignment = style.isRTL ? .right : .left
        case .center: paragraphStyle.alignment = .center
        case .trailing: paragraphStyle.alignment = style.isRTL ? .left : .right
        }
        paragraphStyle.lineSpacing = style.lineSpacing
        
        // Determine text color based on fill type
        let textColor: UIColor
        if style.fillType == .gradient && style.gradientColors.count >= 2 {
            // For gradient text in Core Graphics, we draw a gradient clipped to text path
            drawGradientText(text, font: font, style: style, paragraphStyle: paragraphStyle, in: rect, ctx: ctx)
            return
        } else {
            textColor = UIColor(Color(hex: style.textColor))
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
            .kern: style.letterSpacing,
        ]
        
        let nsString = text as NSString
        nsString.draw(in: rect, withAttributes: attributes)
    }
    
    private func drawGradientText(_ text: String, font: UIFont, style: TextStyle, paragraphStyle: NSMutableParagraphStyle, in rect: CGRect, ctx: CGContext) {
        ctx.saveGState()
        
        // Create attributed string for measurement
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .kern: style.letterSpacing,
        ]
        
        // Draw text as a clipping mask
        let nsString = text as NSString
        ctx.translateBy(x: 0, y: rect.maxY + rect.minY)
        ctx.scaleBy(x: 1, y: -1)
        
        let textRect = CGRect(x: rect.minX, y: 0, width: rect.width, height: rect.height)
        ctx.setTextDrawingMode(.clip)
        nsString.draw(in: textRect, withAttributes: attributes)
        
        // Draw gradient inside clipped text
        let colors = style.gradientColors.map { UIColor(Color(hex: $0)).cgColor }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) {
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: 0),
                end: CGPoint(x: rect.maxX, y: rect.height),
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
        
        ctx.restoreGState()
    }
    
    private func drawImageElement(_ element: CanvasElement, in rect: CGRect, ctx: CGContext) {
        // Select correct image data (original or BG-removed)
        let imageData: Data?
        if element.useBackgroundRemoved {
            imageData = element.backgroundRemovedData ?? element.imageData
        } else {
            imageData = element.imageData
        }
        
        guard let data = imageData, let uiImage = UIImage(data: data) else { return }
        
        if element.maskShape != .none {
            // Apply mask clipping
            ctx.saveGState()
            let maskPath = maskPath(for: element.maskShape, in: rect)
            ctx.addPath(maskPath.cgPath)
            ctx.clip()
            uiImage.draw(in: rect)
            ctx.restoreGState()
        } else {
            uiImage.draw(in: rect)
        }
    }
    
    /// Generate UIBezierPath for each mask shape
    private func maskPath(for shape: MaskShape, in rect: CGRect) -> UIBezierPath {
        switch shape {
        case .none:
            return UIBezierPath(rect: rect)
        case .circle:
            return UIBezierPath(ovalIn: rect)
        case .roundedRect:
            return UIBezierPath(roundedRect: rect, cornerRadius: 24)
        case .heart:
            return heartPath(in: rect)
        case .star:
            return starPath(in: rect, points: 5)
        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.close()
            return path
        case .hexagon:
            return polygonPath(in: rect, sides: 6)
        case .leaf:
            return leafPath(in: rect)
        case .arch:
            return archPath(in: rect)
        case .shield:
            return shieldPath(in: rect)
        case .cross:
            return crossPath(in: rect)
        }
    }
    
    private func heartPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        let cx = ox + w * 0.5
        
        path.move(to: CGPoint(x: cx, y: oy + h * 0.85))
        path.addCurve(to: CGPoint(x: ox + w * 0.1, y: oy + h * 0.3),
                       controlPoint1: CGPoint(x: cx - w * 0.05, y: oy + h * 0.7),
                       controlPoint2: CGPoint(x: ox, y: oy + h * 0.5))
        path.addCurve(to: CGPoint(x: cx, y: oy + h * 0.25),
                       controlPoint1: CGPoint(x: ox + w * 0.1, y: oy + h * 0.05),
                       controlPoint2: CGPoint(x: cx - w * 0.05, y: oy + h * 0.15))
        path.addCurve(to: CGPoint(x: ox + w * 0.9, y: oy + h * 0.3),
                       controlPoint1: CGPoint(x: cx + w * 0.05, y: oy + h * 0.15),
                       controlPoint2: CGPoint(x: ox + w * 0.9, y: oy + h * 0.05))
        path.addCurve(to: CGPoint(x: cx, y: oy + h * 0.85),
                       controlPoint1: CGPoint(x: ox + w, y: oy + h * 0.5),
                       controlPoint2: CGPoint(x: cx + w * 0.05, y: oy + h * 0.7))
        path.close()
        return path
    }
    
    private func starPath(in rect: CGRect, points: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.4
        
        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let r = i.isMultiple(of: 2) ? outerR : innerR
            let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                             y: center.y + CGFloat(sin(angle)) * r)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.close()
        return path
    }
    
    private func polygonPath(in rect: CGRect, sides: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        
        for i in 0..<sides {
            let angle = (Double(i) * .pi * 2 / Double(sides)) - .pi / 2
            let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                             y: center.y + CGFloat(sin(angle)) * r)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.close()
        return path
    }
    
    private func leafPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        
        path.move(to: CGPoint(x: ox + w * 0.5, y: oy))
        path.addCurve(to: CGPoint(x: ox + w, y: oy + h * 0.5),
                       controlPoint1: CGPoint(x: ox + w * 0.85, y: oy + h * 0.02),
                       controlPoint2: CGPoint(x: ox + w, y: oy + h * 0.2))
        path.addCurve(to: CGPoint(x: ox + w * 0.5, y: oy + h),
                       controlPoint1: CGPoint(x: ox + w, y: oy + h * 0.8),
                       controlPoint2: CGPoint(x: ox + w * 0.85, y: oy + h * 0.98))
        path.addCurve(to: CGPoint(x: ox, y: oy + h * 0.5),
                       controlPoint1: CGPoint(x: ox + w * 0.15, y: oy + h * 0.98),
                       controlPoint2: CGPoint(x: ox, y: oy + h * 0.8))
        path.addCurve(to: CGPoint(x: ox + w * 0.5, y: oy),
                       controlPoint1: CGPoint(x: ox, y: oy + h * 0.2),
                       controlPoint2: CGPoint(x: ox + w * 0.15, y: oy + h * 0.02))
        path.close()
        return path
    }
    
    private func archPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        
        path.move(to: CGPoint(x: ox, y: oy + h))
        path.addLine(to: CGPoint(x: ox, y: oy + h * 0.4))
        path.addCurve(to: CGPoint(x: ox + w, y: oy + h * 0.4),
                       controlPoint1: CGPoint(x: ox, y: oy - h * 0.1),
                       controlPoint2: CGPoint(x: ox + w, y: oy - h * 0.1))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h))
        path.close()
        return path
    }
    
    private func shieldPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        
        path.move(to: CGPoint(x: ox + w * 0.5, y: oy))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h * 0.15))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h * 0.55))
        path.addCurve(to: CGPoint(x: ox + w * 0.5, y: oy + h),
                       controlPoint1: CGPoint(x: ox + w, y: oy + h * 0.78),
                       controlPoint2: CGPoint(x: ox + w * 0.7, y: oy + h * 0.92))
        path.addCurve(to: CGPoint(x: ox, y: oy + h * 0.55),
                       controlPoint1: CGPoint(x: ox + w * 0.3, y: oy + h * 0.92),
                       controlPoint2: CGPoint(x: ox, y: oy + h * 0.78))
        path.addLine(to: CGPoint(x: ox, y: oy + h * 0.15))
        path.close()
        return path
    }
    
    private func crossPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        let t: CGFloat = 0.3
        
        path.move(to: CGPoint(x: ox + w * t, y: oy))
        path.addLine(to: CGPoint(x: ox + w * (1-t), y: oy))
        path.addLine(to: CGPoint(x: ox + w * (1-t), y: oy + h * t))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h * t))
        path.addLine(to: CGPoint(x: ox + w, y: oy + h * (1-t)))
        path.addLine(to: CGPoint(x: ox + w * (1-t), y: oy + h * (1-t)))
        path.addLine(to: CGPoint(x: ox + w * (1-t), y: oy + h))
        path.addLine(to: CGPoint(x: ox + w * t, y: oy + h))
        path.addLine(to: CGPoint(x: ox + w * t, y: oy + h * (1-t)))
        path.addLine(to: CGPoint(x: ox, y: oy + h * (1-t)))
        path.addLine(to: CGPoint(x: ox, y: oy + h * t))
        path.addLine(to: CGPoint(x: ox + w * t, y: oy + h * t))
        path.close()
        return path
    }
    
    private func drawShapeElement(_ element: CanvasElement, in rect: CGRect, ctx: CGContext) {
        guard let style = element.shapeStyle else { return }
        let fillColor = UIColor(Color(hex: style.fillColor))
        
        ctx.setFillColor(fillColor.cgColor)
        
        switch style.shapeType {
        case .rectangle:
            ctx.fill(rect)
        case .circle:
            ctx.fillEllipse(in: rect)
        case .roundedRect:
            let path = UIBezierPath(roundedRect: rect, cornerRadius: style.cornerRadius)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        case .triangle:
            ctx.move(to: CGPoint(x: rect.midX, y: rect.minY))
            ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            ctx.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            ctx.closePath()
            ctx.fillPath()
        case .star:
            let path = starPath(in: rect, points: 5)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        case .hexagon:
            let path = polygonPath(in: rect, sides: 6)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        case .pentagon:
            let path = polygonPath(in: rect, sides: 5)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        case .diamond:
            ctx.move(to: CGPoint(x: rect.midX, y: rect.minY))
            ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            ctx.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            ctx.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            ctx.closePath()
            ctx.fillPath()
        case .arrow:
            drawArrowShape(in: rect, ctx: ctx, fillColor: fillColor)
        case .speechBubble:
            drawSpeechBubble(in: rect, ctx: ctx, fillColor: fillColor)
        case .banner:
            drawBannerShape(in: rect, ctx: ctx, fillColor: fillColor)
        case .cross:
            let path = crossPath(in: rect)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        case .ring:
            ctx.strokeEllipse(in: rect.insetBy(dx: 4, dy: 4))
            ctx.setStrokeColor(fillColor.cgColor)
            ctx.setLineWidth(8)
            ctx.strokeEllipse(in: rect.insetBy(dx: 4, dy: 4))
        }
        
        // Draw stroke if needed
        if style.strokeWidth > 0 {
            ctx.setStrokeColor(UIColor(Color(hex: style.strokeColor)).cgColor)
            ctx.setLineWidth(style.strokeWidth)
        }
    }
    
    private func drawArrowShape(in rect: CGRect, ctx: CGContext, fillColor: UIColor) {
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        let shaftH = h * 0.35
        
        ctx.move(to: CGPoint(x: ox, y: oy + (h - shaftH) / 2))
        ctx.addLine(to: CGPoint(x: ox + w * 0.6, y: oy + (h - shaftH) / 2))
        ctx.addLine(to: CGPoint(x: ox + w * 0.6, y: oy))
        ctx.addLine(to: CGPoint(x: ox + w, y: oy + h / 2))
        ctx.addLine(to: CGPoint(x: ox + w * 0.6, y: oy + h))
        ctx.addLine(to: CGPoint(x: ox + w * 0.6, y: oy + (h + shaftH) / 2))
        ctx.addLine(to: CGPoint(x: ox, y: oy + (h + shaftH) / 2))
        ctx.closePath()
        ctx.fillPath()
    }
    
    private func drawSpeechBubble(in rect: CGRect, ctx: CGContext, fillColor: UIColor) {
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        let bodyH = h * 0.75
        let r: CGFloat = 16
        
        let bodyRect = CGRect(x: ox, y: oy, width: w, height: bodyH)
        let path = UIBezierPath(roundedRect: bodyRect, cornerRadius: r)
        
        // Tail
        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: ox + w * 0.2, y: oy + bodyH))
        tailPath.addLine(to: CGPoint(x: ox + w * 0.15, y: oy + h))
        tailPath.addLine(to: CGPoint(x: ox + w * 0.4, y: oy + bodyH))
        tailPath.close()
        
        path.append(tailPath)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }
    
    private func drawBannerShape(in rect: CGRect, ctx: CGContext, fillColor: UIColor) {
        let w = rect.width; let h = rect.height
        let ox = rect.minX; let oy = rect.minY
        let notch: CGFloat = w * 0.12
        
        ctx.move(to: CGPoint(x: ox, y: oy))
        ctx.addLine(to: CGPoint(x: ox + w, y: oy))
        ctx.addLine(to: CGPoint(x: ox + w, y: oy + h))
        ctx.addLine(to: CGPoint(x: ox + w / 2, y: oy + h - notch))
        ctx.addLine(to: CGPoint(x: ox, y: oy + h))
        ctx.closePath()
        ctx.fillPath()
    }
    
    private func drawStickerElement(_ element: CanvasElement, in rect: CGRect, ctx: CGContext) {
        guard let name = element.stickerName else { return }
        
        var imageToDraw: UIImage?
        
        if let customAsset = UIImage(named: name) {
            imageToDraw = customAsset.withTintColor(UIColor(DS.Colors.primary), renderingMode: .alwaysOriginal)
        } else if let sysImage = UIImage(systemName: name) {
            imageToDraw = sysImage.withTintColor(UIColor(DS.Colors.primary), renderingMode: .alwaysOriginal)
        }
        
        imageToDraw?.draw(in: rect)
    }
}
