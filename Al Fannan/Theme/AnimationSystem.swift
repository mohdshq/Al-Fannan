import SwiftUI

// MARK: - Animation Presets
struct AnimationPreset {
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0)
    static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    static let easeOutQuick = Animation.easeOut(duration: 0.25)
    static let easeOutMedium = Animation.easeOut(duration: 0.4)
    static let easeInOutSmooth = Animation.easeInOut(duration: 0.35)
    static let gentleBounce = Animation.interpolatingSpring(stiffness: 200, damping: 15)
}

// MARK: - View Modifiers for Animations

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    let bounce: Bool
    
    init(duration: Double = 2.0, bounce: Bool = false) {
        self.duration = duration
        self.bounce = bounce
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.12),
                            .white.opacity(0.2),
                            .white.opacity(0.12),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width * 1.6 - geometry.size.width * 0.3)
                    .blendMode(.overlay)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
                ) {
                    phase = 1
                }
            }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let minScale: CGFloat
    let duration: Double
    
    init(minScale: CGFloat = 0.95, duration: Double = 1.5) {
        self.minScale = minScale
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.0 : minScale)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    let offset: CGFloat
    let duration: Double
    
    init(offset: CGFloat = 6, duration: Double = 2.0) {
        self.offset = offset
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear { isFloating = true }
    }
}

struct GlowEffect: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isGlowing ? 0.6 : 0.2), radius: isGlowing ? radius : radius * 0.5)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear { isGlowing = true }
    }
}

struct SlideInEffect: ViewModifier {
    let edge: Edge
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(
                x: isVisible ? 0 : (edge == .leading ? -30 : edge == .trailing ? 30 : 0),
                y: isVisible ? 0 : (edge == .top ? -30 : edge == .bottom ? 30 : 0)
            )
            .onAppear {
                withAnimation(AnimationPreset.springSmooth.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct StaggeredAppearance: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                withAnimation(
                    AnimationPreset.springSmooth.delay(baseDelay + Double(index) * 0.06)
                ) {
                    isVisible = true
                }
            }
    }
}

// MARK: - View Extensions
extension View {
    func shimmer(duration: Double = 2.0) -> some View {
        modifier(ShimmerEffect(duration: duration))
    }
    
    func pulse(minScale: CGFloat = 0.95, duration: Double = 1.5) -> some View {
        modifier(PulseEffect(minScale: minScale, duration: duration))
    }
    
    func floating(offset: CGFloat = 6, duration: Double = 2.0) -> some View {
        modifier(FloatingEffect(offset: offset, duration: duration))
    }
    
    func glow(color: Color = DS.Colors.primary, radius: CGFloat = 15) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
    
    func slideIn(from edge: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(SlideInEffect(edge: edge, delay: delay))
    }
    
    func staggered(index: Int, baseDelay: Double = 0.1) -> some View {
        modifier(StaggeredAppearance(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Canvas Element Animations
enum ElementAnimation: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case fadeIn = "Fade In"
    case fadeOut = "Fade Out"
    case slideUp = "Slide Up"
    case slideDown = "Slide Down"
    case slideLeft = "Slide Left"
    case slideRight = "Slide Right"
    case zoomIn = "Zoom In"
    case zoomOut = "Zoom Out"
    case bounce = "Bounce"
    case spin = "Spin"
    case shake = "Shake"
    case dissolve = "Dissolve"
    case flip = "Flip"
    case pulse = "Pulse"
    case typewriter = "Typewriter"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .none: return "circle.slash"
        case .fadeIn, .fadeOut: return "circle.dotted"
        case .slideUp: return "arrow.up"
        case .slideDown: return "arrow.down"
        case .slideLeft: return "arrow.left"
        case .slideRight: return "arrow.right"
        case .zoomIn: return "arrow.up.left.and.arrow.down.right"
        case .zoomOut: return "arrow.down.right.and.arrow.up.left"
        case .bounce: return "arrow.up.arrow.down"
        case .spin: return "arrow.trianglehead.2.clockwise"
        case .shake: return "waveform"
        case .dissolve: return "sparkles"
        case .flip: return "arrow.left.arrow.right"
        case .pulse: return "heart"
        case .typewriter: return "character.cursor.ibeam"
        }
    }
}
