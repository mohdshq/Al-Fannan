import SwiftUI

// MARK: - Selection Handles Overlay
/// Draws resize handles and rotation handle as an overlay on the selected element.
/// Uses `.offset()` from center so handles align correctly with the element.
struct SelectionHandlesOverlay: View {
    let width: CGFloat
    let height: CGFloat
    let onResizeCorner: (HandleCorner, CGSize) -> Void   // corner, translation
    let onResizeEnd: (HandleCorner, CGSize) -> Void       // corner, final translation
    let onRotateDelta: (Angle) -> Void
    let onRotateEnd: (Angle) -> Void
    
    enum HandleCorner: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    private let handleSize: CGFloat = 14
    
    var body: some View {
        ZStack {
            // Bounding box
            Rectangle()
                .strokeBorder(Color.red, lineWidth: 1.0)
                .frame(width: width, height: height)
            
            // Corner handles
            ForEach(HandleCorner.allCases, id: \.self) { corner in
                cornerHandleView(corner)
            }
            
            // Rotation handle at top
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle().strokeBorder(Color.red.opacity(0.5), lineWidth: 0.5)
                    )
                    .overlay(
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(Color.red)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2)
                    .gesture(rotateGesture)
                
                Rectangle()
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 1, height: 12)
            }
            .offset(y: -(height / 2 + 20))
        }
    }
    
    private func cornerHandleView(_ corner: HandleCorner) -> some View {
        let xOff: CGFloat = (corner == .topLeft || corner == .bottomLeft) ? -width / 2 : width / 2
        let yOff: CGFloat = (corner == .topLeft || corner == .topRight) ? -height / 2 : height / 2
        
        return Circle()
            .fill(Color.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Circle().strokeBorder(Color.red.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 2)
            .offset(x: xOff, y: yOff)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onResizeCorner(corner, value.translation)
                    }
                    .onEnded { value in
                        onResizeEnd(corner, value.translation)
                    }
            )
    }
    
    private var rotateGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                // Use horizontal drag distance as rotation (more intuitive on phone)
                let angle = Angle.degrees(Double(value.translation.width) * 0.5)
                onRotateDelta(angle)
            }
            .onEnded { value in
                let angle = Angle.degrees(Double(value.translation.width) * 0.5)
                onRotateEnd(angle)
            }
    }
}

// MARK: - Quick Action Toolbar (appears above selected element)
struct ElementQuickActions: View {
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onFlipH: () -> Void
    let onFlipV: () -> Void
    let onLock: () -> Void
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            quickButton(icon: "doc.on.doc", tip: "Copy") { onDuplicate() }
                .disabled(isLocked)
                .opacity(isLocked ? 0.35 : 1)
            quickButton(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", tip: "Flip H") { onFlipH() }
                .disabled(isLocked)
                .opacity(isLocked ? 0.35 : 1)
            quickButton(icon: "arrow.up.and.down.righttriangle.up.righttriangle.down", tip: "Flip V") { onFlipV() }
                .disabled(isLocked)
                .opacity(isLocked ? 0.35 : 1)
            quickButton(icon: isLocked ? "lock.fill" : "lock.open", tip: isLocked ? "Unlock" : "Lock") { onLock() }
            Divider().frame(height: 16).opacity(0.3)
            quickButton(icon: "trash", tip: "Delete", isDestructive: true) { onDelete() }
                .disabled(isLocked)
                .opacity(isLocked ? 0.35 : 1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
    
    private func quickButton(icon: String, tip: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isDestructive ? .red : .white)
                .frame(width: 30, height: 30)
        }
    }
}
