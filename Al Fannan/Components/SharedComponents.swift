import SwiftUI

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat
    
    init(cornerRadius: CGFloat = DS.Radius.lg, padding: CGFloat = DS.Spacing.md,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DS.Colors.surfaceBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Gold Button
struct GoldButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isCompact: Bool = false
    
    init(_ title: String, icon: String? = nil, isCompact: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isCompact = isCompact
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                }
                Text(title)
                    .font(isCompact ? DS.Typography.captionSmall : DS.Typography.bodyMedium)
                    .fontWeight(.semibold)
            }
            .foregroundColor(DS.Colors.textInverse)
            .padding(.horizontal, isCompact ? DS.Spacing.md : DS.Spacing.xl)
            .padding(.vertical, isCompact ? DS.Spacing.xs : DS.Spacing.sm)
            .background(DS.Colors.goldGradient)
            .clipShape(Capsule())
            .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - Icon Circle Button
struct CircleIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 18
    var bgColor: Color = DS.Colors.surface
    var fgColor: Color = DS.Colors.textPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(fgColor)
                .frame(width: size, height: size)
                .background(bgColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(DS.Colors.surfaceBorder, lineWidth: 1))
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let titleAr: String?
    var action: (() -> Void)? = nil
    var actionLabel: String = "See All"
    
    init(_ title: String, titleAr: String? = nil, actionLabel: String = "See All", action: (() -> Void)? = nil) {
        self.title = title
        self.titleAr = titleAr
        self.action = action
        self.actionLabel = actionLabel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.titleSmall)
                    .foregroundColor(DS.Colors.textPrimary)
                if let ar = titleAr {
                    Text(ar)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
            Spacer()
            if let action {
                Button(action: action) {
                    Text(actionLabel)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.primary)
                }
            }
        }
        .padding(.horizontal, DS.Spacing.md)
    }
}

// MARK: - Pro Badge
struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.system(size: 9, weight: .black))
            .foregroundColor(DS.Colors.textInverse)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(DS.Colors.goldGradient)
            .clipShape(Capsule())
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBG: View {
    @State private var animateGradient = false
    let colors: [Color]
    
    init(colors: [Color] = [DS.Colors.primary.opacity(0.3), DS.Colors.accent.opacity(0.2), DS.Colors.bgPrimary]) {
        self.colors = colors
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: Template
    let onTap: () -> Void
    @AppStorage("favoriteTemplateIds") private var favoriteIdsString: String = ""
    
    private var isFavorite: Bool {
        favoriteIdsString.contains(template.id.uuidString)
    }
    
    private func toggleFavorite() {
        var ids = Set(favoriteIdsString.split(separator: ",").map(String.init))
        let key = template.id.uuidString
        if ids.contains(key) {
            ids.remove(key)
        } else {
            ids.insert(key)
        }
        favoriteIdsString = ids.joined(separator: ",")
        HapticManager.selection()
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Preview
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: template.previewColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(template.aspectRatio, contentMode: .fill)
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 4) {
                            Text(template.nameAr)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                            Text(template.name)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                
                // Top-right badges
                VStack(spacing: 6) {
                    if template.isPro {
                        ProBadge()
                    }
                    
                    // Favorite heart
                    Button {
                        withAnimation(AnimationPreset.springBouncy) {
                            toggleFavorite()
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isFavorite ? .red : .white.opacity(0.8))
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(8)
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: TemplateCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                Text(category.name)
                    .font(DS.Typography.captionSmall)
            }
            .foregroundColor(isSelected ? DS.Colors.textInverse : DS.Colors.textSecondary)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xs)
            .background(
                isSelected ?
                AnyShapeStyle(DS.Colors.goldGradient) :
                AnyShapeStyle(DS.Colors.surface)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : DS.Colors.surfaceBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.textTertiary)
                .floating()
            Text(title)
                .font(DS.Typography.titleSmall)
                .foregroundColor(DS.Colors.textPrimary)
            Text(message)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DS.Spacing.xxl)
    }
}
