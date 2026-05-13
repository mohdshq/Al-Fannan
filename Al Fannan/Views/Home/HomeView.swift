import SwiftUI

struct HomeView: View {
    @State private var projectVM = ProjectViewModel()
    @Binding var showCreateSheet: Bool
    @Binding var navigateToEditor: Bool
    var canvasVM: CanvasViewModel
    @State private var showProSheet = false
    @State private var selectedCategory: TemplateCategory? = nil
    @State private var animateHero = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: DS.Spacing.xl) {
                    heroSection
                    quickActionsRow
                    recentProjectsSection
                    categoriesSection
                    featuredTemplatesSection
                    proUpgradeCard
                    Spacer(minLength: 100)
                }
                .padding(.top, DS.Spacing.sm)
            }
            .background(DS.Colors.bgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DS.Colors.goldGradient)
                            .symbolEffect(.pulse, isActive: animateHero)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Al Fannan")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(DS.Colors.textPrimary)
                            Text("الفنان")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(DS.Colors.primary)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: DS.Spacing.sm) {
                        CircleIconButton(icon: "bell", size: 36, iconSize: 15) {}
                        CircleIconButton(icon: "crown.fill", size: 36, iconSize: 15,
                                         bgColor: DS.Colors.primary.opacity(0.15),
                                         fgColor: DS.Colors.primary) {
                            showProSheet = true
                        }
                    }
                }
            }
            .onAppear {
                animateHero = true
                projectVM.loadSavedProjects()
            }
            .onChange(of: navigateToEditor) { _, newValue in
                // Reload saved projects when returning from editor
                if !newValue {
                    projectVM.loadSavedProjects()
                }
            }
        }
        .sheet(isPresented: $showProSheet) {
            ProSubscriptionView()
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1A1A2E"),
                            Color(hex: "16213E"),
                            Color(hex: "0F3460")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    ZStack {
                        // Decorative circles
                        Circle()
                            .fill(DS.Colors.primary.opacity(0.15))
                            .frame(width: 120)
                            .offset(x: 130, y: -40)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(DS.Colors.accent.opacity(0.1))
                            .frame(width: 80)
                            .offset(x: -100, y: 50)
                            .blur(radius: 15)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                Text("Design Beautifully")
                                    .font(DS.Typography.headline)
                                    .foregroundColor(.white)
                                Text("صمّم بإبداع")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(DS.Colors.primary)
                                Text("Create stunning Arabic & English content")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 2)
                                
                                GoldButton("Start Creating", icon: "plus", isCompact: true) {
                                    showCreateSheet = true
                                }
                                .padding(.top, DS.Spacing.xs)
                            }
                            Spacer()
                            
                            // Arabic calligraphy decoration
                            VStack {
                                Text("الفنان")
                                    .font(.system(size: 44, weight: .bold))
                                    .foregroundStyle(
                                        DS.Colors.goldGradient
                                    )
                                    .opacity(0.3)
                                    .rotationEffect(.degrees(-10))
                            }
                        }
                        .padding(DS.Spacing.xl)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xl))
        }
        .padding(.horizontal, DS.Spacing.md)
        .slideIn(from: .bottom, delay: 0.1)
    }
    
    // MARK: - Quick Actions
    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                quickActionItem(icon: "photo.badge.plus", title: "Photo", titleAr: "صورة", color: Color(hex: "5AC8FA")) {
                    startNewProject(width: 1080, height: 1080)
                }
                quickActionItem(icon: "square.grid.2x2", title: "Collage", titleAr: "تجميعة", color: Color(hex: "FF9500")) {
                    startNewProject(width: 1080, height: 1080)
                    canvasVM.addCollage(layout: .grid2x2)
                }
                quickActionItem(icon: "video.badge.plus", title: "Video", titleAr: "فيديو", color: Color(hex: "AF52DE")) {
                    startNewProject(width: 1080, height: 1920)
                }
                quickActionItem(icon: "rectangle.portrait", title: "Story", titleAr: "ستوري", color: Color(hex: "FF6B8A")) {
                    startNewProject(width: 1080, height: 1920)
                }
                quickActionItem(icon: "crown", title: "Logo", titleAr: "شعار", color: DS.Colors.primary) {
                    startNewProject(width: 1000, height: 1000)
                }
                quickActionItem(icon: "text.justify.left", title: "Post", titleAr: "بوست", color: Color(hex: "34C759")) {
                    startNewProject(width: 1080, height: 1080)
                }
                quickActionItem(icon: "doc.text", title: "Resume", titleAr: "سيرة", color: Color(hex: "FFB340")) {
                    startNewProject(width: 2480, height: 3508)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
        .slideIn(from: .bottom, delay: 0.2)
    }
    
    /// Helper to reset canvas for a brand-new project from the quick-action row.
    private func startNewProject(width: CGFloat, height: CGFloat) {
        canvasVM.loadNewProject(width: width, height: height)
        navigateToEditor = true
    }
    
    private func quickActionItem(icon: String, title: String, titleAr: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(color.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textPrimary)
                Text(titleAr)
                    .font(.system(size: 10))
                    .foregroundColor(DS.Colors.textTertiary)
            }
        }
    }
    
    // MARK: - Recent Projects
    private var recentProjectsSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            SectionHeader("Recent Projects", titleAr: "المشاريع الأخيرة") {}
            
            if projectVM.recentProjects.isEmpty {
                EmptyStateView(icon: "doc.badge.plus",
                               title: "No Projects Yet",
                               message: "Tap + to start your first design")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.sm) {
                        // New project card
                        Button {
                            showCreateSheet = true
                        } label: {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: DS.Radius.md)
                                        .fill(DS.Colors.surface)
                                        .frame(width: 130, height: 130)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                                .foregroundColor(DS.Colors.primary.opacity(0.4))
                                        )
                                    VStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(DS.Colors.primary)
                                        Text("New")
                                            .font(DS.Typography.captionSmall)
                                            .foregroundColor(DS.Colors.textSecondary)
                                    }
                                }
                                Text("Create New")
                                    .font(DS.Typography.captionSmall)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                        }
                        
                        ForEach(projectVM.recentProjects) { project in
                            recentProjectCard(project)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                }
            }
        }
        .slideIn(from: .bottom, delay: 0.3)
    }
    
    private func recentProjectCard(_ project: Project) -> some View {
        Button {
            canvasVM.loadExistingProject(project)
            navigateToEditor = true
        } label: {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(
                            LinearGradient(
                                colors: [DS.Colors.bgElevated, DS.Colors.bgTertiary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 130, height: 130)
                    
                    if let thumb = projectVM.loadThumbnail(for: project.id) {
                        Image(uiImage: thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 24))
                                .foregroundColor(DS.Colors.primary.opacity(0.5))
                            Text(project.nameAr)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                }
                .frame(width: 130, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                .contextMenu {
                    Button(role: .destructive) {
                        projectVM.deleteProject(project.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textPrimary)
                        .lineLimit(1)
                    Text(project.createdAt.formatted(.dateTime.month().day()))
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            SectionHeader("Categories", titleAr: "الأقسام") {}
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DS.Spacing.sm),
                GridItem(.flexible(), spacing: DS.Spacing.sm),
                GridItem(.flexible(), spacing: DS.Spacing.sm),
                GridItem(.flexible(), spacing: DS.Spacing.sm),
            ], spacing: DS.Spacing.sm) {
                ForEach(Array(TemplateCategory.allCategories.prefix(8).enumerated()), id: \.element.id) { index, cat in
                    categoryItem(cat, index: index)
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
        .slideIn(from: .bottom, delay: 0.4)
    }
    
    private func categoryItem(_ cat: TemplateCategory, index: Int) -> some View {
        Button {} label: {
            VStack(spacing: DS.Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .fill(cat.color.opacity(0.12))
                        .frame(height: 56)
                    Image(systemName: cat.icon)
                        .font(.system(size: 22))
                        .foregroundColor(cat.color)
                }
                Text(cat.nameAr)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(1)
            }
            .staggered(index: index, baseDelay: 0.3)
        }
    }
    
    // MARK: - Featured Templates
    private var featuredTemplatesSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            SectionHeader("Featured Templates", titleAr: "قوالب مميزة") {}
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(Template.sampleTemplates.prefix(6)) { template in
                        TemplateCard(template: template) {
                            TemplateFactory.loadTemplate(template, into: canvasVM)
                            navigateToEditor = true
                        }
                        .frame(width: 160)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
        }
        .slideIn(from: .bottom, delay: 0.5)
    }
    
    // MARK: - Pro Upgrade Card
    private var proUpgradeCard: some View {
        Button {
            showProSheet = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.xl)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2D1B00"), Color(hex: "1A1000")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.xl)
                            .stroke(DS.Colors.primary.opacity(0.3), lineWidth: 1)
                    )
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(DS.Colors.primary)
                            Text("Upgrade to Pro")
                                .font(DS.Typography.titleSmall)
                                .foregroundColor(DS.Colors.primary)
                        }
                        Text("Unlock all templates, fonts & features")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(DS.Colors.primary)
                }
                .padding(DS.Spacing.xl)
            }
        }
        .padding(.horizontal, DS.Spacing.md)
        .shimmer(duration: 3)
    }
}
