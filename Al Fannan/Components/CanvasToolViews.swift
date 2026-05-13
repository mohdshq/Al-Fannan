import SwiftUI
import CoreText
import UIKit

// MARK: - Curved Arabic Text (CoreText-based)
/// Uses CTFontDrawGlyphs to draw shaped glyphs along an arc.
/// This preserves Arabic ligatures because CoreText shapes the full string first.
struct CurvedTextView: View {
    let text: String
    let curveAngle: CGFloat  // degrees — positive = smile (top arc), negative = frown (bottom arc)
    let font: Font
    let uiFont: UIFont
    let color: Color
    
    var body: some View {
        CurvedTextCanvas(
            text: text,
            curveAngle: curveAngle,
            uiFont: uiFont,
            color: UIColor(color)
        )
    }
}

/// UIViewRepresentable wrapper for CoreText glyph drawing on an arc
private struct CurvedTextCanvas: UIViewRepresentable {
    let text: String
    let curveAngle: CGFloat
    let uiFont: UIFont
    let color: UIColor
    
    func makeUIView(context: Context) -> CurvedArabicTextUIView {
        let view = CurvedArabicTextUIView()
        view.isOpaque = false
        view.backgroundColor = .clear
        view.contentMode = .redraw
        return view
    }
    
    func updateUIView(_ uiView: CurvedArabicTextUIView, context: Context) {
        uiView.text = text
        uiView.curveAngle = curveAngle
        uiView.textFont = uiFont
        uiView.textColor = color
        uiView.setNeedsDisplay()
    }
}

/// Core UIView that draws Arabic text on a curve using CTFontDrawGlyphs
final class CurvedArabicTextUIView: UIView {
    var text: String = ""
    var textColor: UIColor = .white
    var textFont: UIFont = .systemFont(ofSize: 24)
    var curveAngle: CGFloat = 0  // degrees
    
    override func draw(_ rect: CGRect) {
        guard !text.isEmpty else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let para = NSMutableParagraphStyle()
        para.baseWritingDirection = isPredominantlyRTL(text) ? .rightToLeft : .leftToRight
        
        let attributed = NSAttributedString(string: text, attributes: [
            .font: textFont,
            .foregroundColor: textColor.cgColor,
            .kern: 0, // Default tracking
            .paragraphStyle: para
        ])
        let line = CTLineCreateWithAttributedString(attributed)
        
        var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
        let lineWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        guard lineWidth > 0 else { return }
        
        // Dead-zone: very small angles draw as a straight, centered line.
        if abs(curveAngle) < 1 {
            ctx.saveGState()
            ctx.textMatrix = .identity
            ctx.translateBy(x: (bounds.width - lineWidth) / 2,
                            y: bounds.height / 2 + ascent / 2)
            ctx.scaleBy(x: 1, y: -1)
            CTLineDraw(line, ctx)
            ctx.restoreGState()
            return
        }
        
        // Sign convention:
        //   curveAngle > 0  → smile  (arc opens downward, text on TOP of circle)
        //   curveAngle < 0  → frown  (arc opens upward,   text on BOTTOM of circle)
        let sweep = curveAngle * .pi / 180
        let absSweep = abs(sweep)
        let radius = lineWidth / absSweep
        let smile = sweep > 0
        
        // Anchor the MIDPOINT of the text at the view's center. The circle's center
        // is then `radius` away from that anchor — below for smile, above for frown.
        let anchor = CGPoint(x: bounds.midX, y: bounds.midY)
        let center = CGPoint(
            x: anchor.x,
            y: smile ? anchor.y + radius : anchor.y - radius
        )
        
        ctx.saveGState()
        ctx.textMatrix = .identity
        
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        for run in runs {
            let glyphCount = CTRunGetGlyphCount(run)
            guard glyphCount > 0 else { continue }
            
            var glyphs    = [CGGlyph](repeating: 0, count: glyphCount)
            var positions = [CGPoint](repeating: .zero, count: glyphCount)
            var advances  = [CGSize](repeating: .zero, count: glyphCount)
            CTRunGetGlyphs(run, CFRangeMake(0, 0), &glyphs)
            CTRunGetPositions(run, CFRangeMake(0, 0), &positions)
            CTRunGetAdvances(run, CFRangeMake(0, 0), &advances)
            
            let runAttrs = CTRunGetAttributes(run) as! [NSAttributedString.Key: Any]
            let runFont  = (runAttrs[.font] as? UIFont) ?? textFont
            if let fg = runAttrs[.foregroundColor] {
                ctx.setFillColor(fg as! CGColor)
            }
            
            for i in 0..<glyphCount {
                // Distance along the (straight) baseline from its left edge to this
                // glyph's horizontal center.
                let distance = positions[i].x + advances[i].width / 2
                let t = distance / lineWidth          // 0…1, left → right
                // Signed angular offset around the circle from the anchor point.
                // Positive = clockwise on screen.
                let theta = (t - 0.5) * absSweep
                
                let cx: CGFloat
                let cy: CGFloat
                let rotation: CGFloat
                
                if smile {
                    // Anchor sits at top of circle. Walking clockwise from there:
                    //   x = center.x + r*sin(θ)
                    //   y = center.y - r*cos(θ)           (above center)
                    // Tangent direction at θ: rotate baseline by θ.
                    cx = center.x + radius * sin(theta)
                    cy = center.y - radius * cos(theta)
                    rotation = theta
                } else {
                    // Anchor sits at bottom of circle. We want the text to read in
                    // the same left-to-right order along the baseline, but with the
                    // arc bowing downward. Walk counter-clockwise from the bottom:
                    //   x = center.x + r*sin(θ)           (same horizontal mapping)
                    //   y = center.y + r*cos(θ)           (below center)
                    // Tangent here points the opposite way along the arc, so we
                    // rotate by -θ — NO π flip, NO order reversal.
                    cx = center.x + radius * sin(theta)
                    cy = center.y + radius * cos(theta)
                    rotation = -theta
                }
                
                ctx.saveGState()
                ctx.translateBy(x: cx, y: cy)
                ctx.rotate(by: rotation)
                ctx.scaleBy(x: 1, y: -1)                          // CG text flip
                ctx.translateBy(x: -advances[i].width / 2, y: 0)  // center glyph on its anchor
                var g = glyphs[i]
                var p = CGPoint.zero
                CTFontDrawGlyphs(runFont as CTFont, &g, &p, 1, ctx)
                ctx.restoreGState()
            }
        }
        
        ctx.restoreGState()
    }
    
    private func isPredominantlyRTL(_ s: String) -> Bool {
        for scalar in s.unicodeScalars {
            switch scalar.value {
            case 0x0590...0x08FF, 0xFB50...0xFDFF, 0xFE70...0xFEFF:
                return true
            default: continue
            }
        }
        return false
    }
}

// MARK: - Image Crop Overlay View
/// An interactive crop tool overlay for images
struct ImageCropOverlayView: View {
    @Binding var cropRect: CGRect  // Normalized 0...1
    let imageSize: CGSize
    let onApply: () -> Void
    let onCancel: () -> Void
    
    @State private var topLeft: CGPoint = .zero
    @State private var bottomRight: CGPoint = .zero
    @State private var activeHandle: CropHandle? = nil
    
    enum CropHandle {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
    }
    
    var body: some View {
        ZStack {
            // Dimmed overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                // Clear crop area
                Rectangle()
                    .fill(.clear)
                    .frame(
                        width: (cropRect.width) * w,
                        height: (cropRect.height) * h
                    )
                    .position(
                        x: (cropRect.origin.x + cropRect.width / 2) * w,
                        y: (cropRect.origin.y + cropRect.height / 2) * h
                    )
                    .blendMode(.destinationOut)
                
                // Crop border
                Rectangle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(
                        width: cropRect.width * w,
                        height: cropRect.height * h
                    )
                    .position(
                        x: (cropRect.origin.x + cropRect.width / 2) * w,
                        y: (cropRect.origin.y + cropRect.height / 2) * h
                    )
                
                // Grid lines (rule of thirds)
                let cropX = cropRect.origin.x * w
                let cropY = cropRect.origin.y * h
                let cropW = cropRect.width * w
                let cropH = cropRect.height * h
                
                ForEach(1..<3) { i in
                    // Vertical
                    Path { path in
                        let x = cropX + cropW * CGFloat(i) / 3
                        path.move(to: CGPoint(x: x, y: cropY))
                        path.addLine(to: CGPoint(x: x, y: cropY + cropH))
                    }
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    
                    // Horizontal
                    Path { path in
                        let y = cropY + cropH * CGFloat(i) / 3
                        path.move(to: CGPoint(x: cropX, y: y))
                        path.addLine(to: CGPoint(x: cropX + cropW, y: y))
                    }
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                }
                
                // Corner handles
                cornerHandle(at: CGPoint(x: cropRect.minX * w, y: cropRect.minY * h), geo: geo, handle: .topLeft)
                cornerHandle(at: CGPoint(x: cropRect.maxX * w, y: cropRect.minY * h), geo: geo, handle: .topRight)
                cornerHandle(at: CGPoint(x: cropRect.minX * w, y: cropRect.maxY * h), geo: geo, handle: .bottomLeft)
                cornerHandle(at: CGPoint(x: cropRect.maxX * w, y: cropRect.maxY * h), geo: geo, handle: .bottomRight)
            }
            .compositingGroup()
            
            // Action buttons
            VStack {
                Spacer()
                HStack(spacing: 40) {
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: onApply) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(DS.Colors.goldGradient)
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
    
    private func cornerHandle(at point: CGPoint, geo: GeometryProxy, handle: CropHandle) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 20, height: 20)
            .shadow(color: .black.opacity(0.4), radius: 3)
            .position(point)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let w = geo.size.width
                        let h = geo.size.height
                        let nx = min(max(value.location.x / w, 0), 1)
                        let ny = min(max(value.location.y / h, 0), 1)
                        
                        var newRect = cropRect
                        let minSize: CGFloat = 0.1
                        
                        switch handle {
                        case .topLeft:
                            newRect.origin.x = min(nx, cropRect.maxX - minSize)
                            newRect.origin.y = min(ny, cropRect.maxY - minSize)
                            newRect.size.width = cropRect.maxX - newRect.origin.x
                            newRect.size.height = cropRect.maxY - newRect.origin.y
                        case .topRight:
                            newRect.size.width = max(nx - cropRect.origin.x, minSize)
                            newRect.origin.y = min(ny, cropRect.maxY - minSize)
                            newRect.size.height = cropRect.maxY - newRect.origin.y
                        case .bottomLeft:
                            newRect.origin.x = min(nx, cropRect.maxX - minSize)
                            newRect.size.width = cropRect.maxX - newRect.origin.x
                            newRect.size.height = max(ny - cropRect.origin.y, minSize)
                        case .bottomRight:
                            newRect.size.width = max(nx - cropRect.origin.x, minSize)
                            newRect.size.height = max(ny - cropRect.origin.y, minSize)
                        default:
                            break
                        }
                        
                        cropRect = newRect
                    }
            )
    }
}

// MARK: - Alignment Guide View
/// Shows snap-to-center guide lines during element dragging
struct AlignmentGuideOverlay: View {
    let showHorizontal: Bool
    let showVertical: Bool
    
    var body: some View {
        ZStack {
            if showVertical {
                Rectangle()
                    .fill(Color.cyan.opacity(0.8))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
            }
            
            if showHorizontal {
                Rectangle()
                    .fill(Color.cyan.opacity(0.8))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .allowsHitTesting(false)
    }
}
