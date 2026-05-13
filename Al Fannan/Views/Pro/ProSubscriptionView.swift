import SwiftUI

struct ProSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var animateFeatures = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0D0D0F"), Color(hex: "1A1000"), Color(hex: "0D0D0F")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative elements
            Circle()
                .fill(DS.Colors.primary.opacity(0.08))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(y: -200)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.xxl) {
                    // Close button
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    
                    // Crown icon with glow
                    ZStack {
                        Circle()
                            .fill(DS.Colors.primary.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(DS.Colors.goldGradient)
                            .glow(color: DS.Colors.primary, radius: 20)
                    }
                    .floating()
                    
                    // Title
                    VStack(spacing: DS.Spacing.xs) {
                        Text("Al Fannan Pro")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(DS.Colors.primary)
                        Text("الفنان برو")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DS.Colors.primaryLight)
                        Text("Unlock the full power of creative freedom")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features list
                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        proFeatureRow(icon: "square.grid.2x2.fill", text: "All premium templates", color: DS.Colors.accent)
                        proFeatureRow(icon: "textformat.size", text: "Complete font library", color: DS.Colors.info)
                        proFeatureRow(icon: "face.smiling.fill", text: "Exclusive sticker packs", color: Color(hex: "34C759"))
                        proFeatureRow(icon: "wand.and.stars", text: "Advanced animations & effects", color: Color(hex: "AF52DE"))
                        proFeatureRow(icon: "person.crop.rectangle.badge.minus", text: "AI Background Remover", color: Color(hex: "FF6B8A"))
                        proFeatureRow(icon: "rectangle.badge.xmark", text: "Ad-free experience", color: DS.Colors.warning)
                    }
                    .padding(.horizontal, DS.Spacing.xl)
                    
                    // Plan selection
                    VStack(spacing: DS.Spacing.sm) {
                        planCard(.yearly)
                        planCard(.monthly)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    
                    // Subscribe button
                    Button {
                        // StoreKit subscription
                    } label: {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Start Free Trial")
                                .fontWeight(.bold)
                        }
                        .font(DS.Typography.title)
                        .foregroundColor(DS.Colors.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(DS.Colors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .shadow(color: DS.Colors.primary.opacity(0.4), radius: 15, y: 6)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .shimmer(duration: 3)
                    
                    // Terms
                    VStack(spacing: 4) {
                        Text("3-day free trial, then \(selectedPlan == .yearly ? "$29.99/year" : "$4.99/month")")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.textTertiary)
                        Text("Cancel anytime • Restore Purchases")
                            .font(.system(size: 11))
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    
                    Spacer(minLength: DS.Spacing.huge)
                }
            }
        }
    }
    
    private func proFeatureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)
            Text(text)
                .font(DS.Typography.bodyMedium)
                .foregroundColor(DS.Colors.textPrimary)
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DS.Colors.success)
        }
    }
    
    private func planCard(_ plan: SubscriptionPlan) -> some View {
        Button {
            withAnimation(AnimationPreset.springSnappy) {
                selectedPlan = plan
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.title)
                            .font(DS.Typography.titleSmall)
                            .foregroundColor(DS.Colors.textPrimary)
                        if plan == .yearly {
                            Text("SAVE 50%")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(DS.Colors.textInverse)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DS.Colors.success)
                                .clipShape(Capsule())
                        }
                    }
                    Text(plan.subtitle)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(DS.Typography.title)
                        .foregroundColor(DS.Colors.primary)
                    Text(plan.period)
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(selectedPlan == plan ? DS.Colors.primary.opacity(0.1) : DS.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.md)
                            .stroke(selectedPlan == plan ? DS.Colors.primary : DS.Colors.surfaceBorder, lineWidth: selectedPlan == plan ? 2 : 1)
                    )
            )
        }
    }
}

enum SubscriptionPlan {
    case monthly, yearly
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var subtitle: String {
        switch self {
        case .monthly: return "Billed monthly"
        case .yearly: return "Billed annually • Best Value"
        }
    }
    
    var price: String {
        switch self {
        case .monthly: return "$4.99"
        case .yearly: return "$29.99"
        }
    }
    
    var period: String {
        switch self {
        case .monthly: return "/month"
        case .yearly: return "/year"
        }
    }
}
