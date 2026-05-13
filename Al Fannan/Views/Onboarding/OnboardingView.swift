import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateContent = false
    var onFinish: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "paintpalette.fill",
            title: "Design Beautifully",
            titleAr: "صمّم بإبداع",
            subtitle: "Create stunning Arabic & English designs with professional tools",
            accentColor: Color(hex: "D4A853"),
            bgColors: [Color(hex: "1A1000"), Color(hex: "0D0D0F")]
        ),
        OnboardingPage(
            icon: "character.textbox",
            title: "Arabic First",
            titleAr: "العربية أولاً",
            subtitle: "Full RTL support, Arabic calligraphy fonts, and smart text tools",
            accentColor: Color(hex: "5AC8FA"),
            bgColors: [Color(hex: "001A2E"), Color(hex: "0D0D0F")]
        ),
        OnboardingPage(
            icon: "square.grid.2x2.fill",
            title: "Ready-Made Templates",
            titleAr: "قوالب جاهزة",
            subtitle: "Hundreds of templates for Ramadan, Eid, business, social media & more",
            accentColor: Color(hex: "AF52DE"),
            bgColors: [Color(hex: "1A0026"), Color(hex: "0D0D0F")]
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Start Creating",
            titleAr: "ابدأ الإبداع",
            subtitle: "Your creative journey begins now. Design photos, videos & stories",
            accentColor: Color(hex: "34C759"),
            bgColors: [Color(hex: "001A0D"), Color(hex: "0D0D0F")]
        ),
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                colors: pages[currentPage].bgColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: currentPage)
            
            // Decorative blurred circles
            Circle()
                .fill(pages[currentPage].accentColor.opacity(0.12))
                .frame(width: 260)
                .blur(radius: 60)
                .offset(x: animateContent ? 60 : -60, y: -180)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateContent)
            
            Circle()
                .fill(pages[currentPage].accentColor.opacity(0.08))
                .frame(width: 200)
                .blur(radius: 50)
                .offset(x: animateContent ? -40 : 80, y: 200)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateContent)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            onFinish()
                        } label: {
                            Text("Skip")
                                .font(DS.Typography.bodyMedium)
                                .foregroundColor(DS.Colors.textTertiary)
                                .padding(.horizontal, DS.Spacing.md)
                                .padding(.vertical, DS.Spacing.xs)
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .frame(height: 44)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingContent(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)
                
                Spacer()
                
                // Bottom section
                VStack(spacing: DS.Spacing.xl) {
                    // Page indicators
                    HStack(spacing: DS.Spacing.xs) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? pages[currentPage].accentColor : Color.white.opacity(0.2))
                                .frame(width: currentPage == index ? 28 : 8, height: 8)
                                .animation(AnimationPreset.springSnappy, value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(AnimationPreset.springSmooth) {
                                currentPage += 1
                            }
                        } else {
                            onFinish()
                        }
                    } label: {
                        HStack(spacing: DS.Spacing.xs) {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: currentPage == pages.count - 1 ? "arrow.right" : "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(DS.Colors.textInverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            currentPage == pages.count - 1 ?
                            AnyShapeStyle(DS.Colors.goldGradient) :
                            AnyShapeStyle(pages[currentPage].accentColor)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
                        .shadow(color: pages[currentPage].accentColor.opacity(0.3), radius: 15, y: 6)
                    }
                    .padding(.horizontal, DS.Spacing.xl)
                }
                .padding(.bottom, DS.Spacing.huge)
            }
        }
        .onAppear { animateContent = true }
    }
    
    private func onboardingContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: DS.Spacing.xxl) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                
                ZStack {
                    Circle()
                        .fill(page.accentColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 52, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.accentColor, page.accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse, isActive: true)
                }
            }
            .floating()
            
            // Text content
            VStack(spacing: DS.Spacing.md) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.titleAr)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(page.accentColor)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, DS.Spacing.xl)
            }
        }
        .padding(.horizontal, DS.Spacing.md)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let titleAr: String
    let subtitle: String
    let accentColor: Color
    let bgColors: [Color]
}
