import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showCreateSheet = false
    @State private var navigateToEditor = false
    @State private var canvasVM = CanvasViewModel()
    @Namespace private var tabAnimation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        showCreateSheet: $showCreateSheet,
                        navigateToEditor: $navigateToEditor,
                        canvasVM: canvasVM
                    )
                case .templates:
                    TemplatesView(
                        navigateToEditor: $navigateToEditor,
                        canvasVM: canvasVM
                    )
                case .create:
                    EmptyView()
                case .fonts:
                    FontLibraryView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            customTabBar
        }
        .background(DS.Colors.bgPrimary)
        .fullScreenCover(isPresented: $navigateToEditor) {
            CanvasEditorView(viewModel: canvasVM)
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateProjectSheet(
                navigateToEditor: $navigateToEditor,
                canvasVM: canvasVM
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                if tab == .create {
                    createButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.top, DS.Spacing.xs)
        .padding(.bottom, DS.Spacing.xxs)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(DS.Colors.bgSecondary.opacity(0.8))
                )
                .overlay(alignment: .top) {
                    Divider().opacity(0.3)
                }
                .ignoresSafeArea()
        )
    }
    
    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(AnimationPreset.springSnappy) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(DS.Colors.primary.opacity(0.15))
                            .frame(width: 52, height: 28)
                            .matchedGeometryEffect(id: "tabIndicator", in: tabAnimation)
                    }
                    Image(systemName: selectedTab == tab ? tab.iconSelected : tab.icon)
                        .font(.system(size: 18, weight: selectedTab == tab ? .semibold : .regular))
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                
                Text(tab.title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
            }
            .foregroundColor(selectedTab == tab ? DS.Colors.primary : DS.Colors.textTertiary)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var createButton: some View {
        Button {
            showCreateSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(DS.Colors.goldGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: DS.Colors.primary.opacity(0.4), radius: 10, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(DS.Colors.textInverse)
            }
            .offset(y: -12)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - App Tabs
enum AppTab: String, CaseIterable {
    case home, templates, create, fonts, settings
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .templates: return "Templates"
        case .create: return "Create"
        case .fonts: return "Fonts"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .templates: return "square.grid.2x2"
        case .create: return "plus"
        case .fonts: return "textformat.size"
        case .settings: return "gearshape"
        }
    }
    
    var iconSelected: String {
        switch self {
        case .home: return "house.fill"
        case .templates: return "square.grid.2x2.fill"
        case .create: return "plus"
        case .fonts: return "textformat.size"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    ContentView()
}
