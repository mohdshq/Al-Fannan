import SwiftUI

// MARK: - Mask Shape Path Provider
/// Provides SwiftUI Shape paths for each MaskShape enum case

extension MaskShape {
    @ViewBuilder
    func clipView<Content: View>(content: Content) -> some View {
        switch self {
        case .none: content.clipShape(Rectangle())
        case .circle: content.clipShape(Circle())
        case .heart: content.clipShape(HeartShape())
        case .star: content.clipShape(StarMaskShape())
        case .roundedRect: content.clipShape(RoundedRectangle(cornerRadius: 24))
        case .diamond: content.clipShape(DiamondShape())
        case .hexagon: content.clipShape(HexagonMaskShape())
        case .leaf: content.clipShape(LeafShape())
        case .arch: content.clipShape(ArchShape())
        case .shield: content.clipShape(ShieldShape())
        case .cross: content.clipShape(CrossShape())
        }
    }
}

// Keep MaskShapeProvider for backward compat
struct MaskShapeProvider {
    @ViewBuilder
    static func clipped<Content: View>(mask: MaskShape, content: Content) -> some View {
        mask.clipView(content: content)
    }
}

// MARK: - Heart Shape
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let center = rect.midX
        
        path.move(to: CGPoint(x: center, y: h * 0.85))
        
        // Left side
        path.addCurve(
            to: CGPoint(x: w * 0.1, y: h * 0.3),
            control1: CGPoint(x: center - w * 0.05, y: h * 0.7),
            control2: CGPoint(x: w * 0.0, y: h * 0.5)
        )
        path.addCurve(
            to: CGPoint(x: center, y: h * 0.25),
            control1: CGPoint(x: w * 0.1, y: h * 0.05),
            control2: CGPoint(x: center - w * 0.05, y: h * 0.15)
        )
        
        // Right side
        path.addCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.3),
            control1: CGPoint(x: center + w * 0.05, y: h * 0.15),
            control2: CGPoint(x: w * 0.9, y: h * 0.05)
        )
        path.addCurve(
            to: CGPoint(x: center, y: h * 0.85),
            control1: CGPoint(x: w * 1.0, y: h * 0.5),
            control2: CGPoint(x: center + w * 0.05, y: h * 0.7)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Star Mask Shape (5-point)
struct StarMaskShape: Shape {
    let points: Int = 5
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        var path = Path()
        
        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Diamond Shape
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Hexagon Mask Shape
struct HexagonMaskShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0..<6 {
            let angle = (Double(i) * .pi / 3) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Leaf Shape
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control1: CGPoint(x: w * 0.85, y: h * 0.02),
            control2: CGPoint(x: w, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.8),
            control2: CGPoint(x: w * 0.85, y: h * 0.98)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control1: CGPoint(x: w * 0.15, y: h * 0.98),
            control2: CGPoint(x: 0, y: h * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * 0.15, y: h * 0.02)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Arch Shape
struct ArchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.4))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: 0, y: -h * 0.1),
            control2: CGPoint(x: w, y: -h * 0.1)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.15))
        path.addLine(to: CGPoint(x: w, y: h * 0.55))
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.78),
            control2: CGPoint(x: w * 0.7, y: h * 0.92)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.55),
            control1: CGPoint(x: w * 0.3, y: h * 0.92),
            control2: CGPoint(x: 0, y: h * 0.78)
        )
        path.addLine(to: CGPoint(x: 0, y: h * 0.15))
        path.closeSubpath()
        return path
    }
}

// MARK: - Cross Shape
struct CrossShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let t: CGFloat = 0.3 // thickness ratio
        
        path.move(to: CGPoint(x: w * t, y: 0))
        path.addLine(to: CGPoint(x: w * (1 - t), y: 0))
        path.addLine(to: CGPoint(x: w * (1 - t), y: h * t))
        path.addLine(to: CGPoint(x: w, y: h * t))
        path.addLine(to: CGPoint(x: w, y: h * (1 - t)))
        path.addLine(to: CGPoint(x: w * (1 - t), y: h * (1 - t)))
        path.addLine(to: CGPoint(x: w * (1 - t), y: h))
        path.addLine(to: CGPoint(x: w * t, y: h))
        path.addLine(to: CGPoint(x: w * t, y: h * (1 - t)))
        path.addLine(to: CGPoint(x: 0, y: h * (1 - t)))
        path.addLine(to: CGPoint(x: 0, y: h * t))
        path.addLine(to: CGPoint(x: w * t, y: h * t))
        path.closeSubpath()
        return path
    }
}
