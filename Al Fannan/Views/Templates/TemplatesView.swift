import SwiftUI

struct TemplatesView: View {
    @Binding var navigateToEditor: Bool
    var canvasVM: CanvasViewModel
    @State private var selectedCategory: TemplateCategory? = nil
    @State private var searchText = ""
    @State private var showFilterSheet = false
    @State private var showFavoritesOnly = false
    @AppStorage("favoriteTemplateIds") private var favoriteIdsString: String = ""
    
    private var filteredTemplates: [Template] {
        var templates = Template.sampleTemplates
        if showFavoritesOnly {
            let favIds = Set(favoriteIdsString.split(separator: ",").map(String.init))
            templates = templates.filter { favIds.contains($0.id.uuidString) }
        }
        if let cat = selectedCategory {
            templates = templates.filter { $0.category == cat.name }
        }
        if !searchText.isEmpty {
            templates = templates.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.nameAr.contains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        return templates
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.xs) {
                        // Favorites toggle
                        Button {
                            withAnimation(AnimationPreset.springSnappy) {
                                showFavoritesOnly.toggle()
                                if showFavoritesOnly { selectedCategory = nil }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                                    .font(.system(size: 13))
                                Text("Favorites")
                                    .font(DS.Typography.captionSmall)
                            }
                            .foregroundColor(showFavoritesOnly ? DS.Colors.textInverse : DS.Colors.textSecondary)
                            .padding(.horizontal, DS.Spacing.sm)
                            .padding(.vertical, DS.Spacing.xs)
                            .background(
                                showFavoritesOnly ?
                                AnyShapeStyle(LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)) :
                                AnyShapeStyle(DS.Colors.surface)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(showFavoritesOnly ? Color.clear : DS.Colors.surfaceBorder, lineWidth: 1)
                            )
                        }
                        
                        CategoryPill(
                            category: TemplateCategory(name: "All", nameAr: "الكل", icon: "square.grid.2x2", color: DS.Colors.primary, templateCount: 0),
                            isSelected: selectedCategory == nil && !showFavoritesOnly
                        ) {
                            withAnimation(AnimationPreset.springSnappy) {
                                selectedCategory = nil
                                showFavoritesOnly = false
                            }
                        }
                        ForEach(TemplateCategory.allCategories) { cat in
                            CategoryPill(category: cat, isSelected: selectedCategory?.id == cat.id) {
                                withAnimation(AnimationPreset.springSnappy) {
                                    selectedCategory = cat
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.xs)
                }
                
                Divider().opacity(0.2)
                
                // Templates Grid
                ScrollView {
                    if filteredTemplates.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Templates Found",
                            message: "Try a different category or search term"
                        )
                        .padding(.top, DS.Spacing.huge)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: DS.Spacing.sm),
                            GridItem(.flexible(), spacing: DS.Spacing.sm),
                        ], spacing: DS.Spacing.sm) {
                            ForEach(Array(filteredTemplates.enumerated()), id: \.element.id) { index, template in
                                TemplateCard(template: template) {
                                    TemplateFactory.loadTemplate(template, into: canvasVM)
                                    navigateToEditor = true
                                }
                                .staggered(index: index)
                            }
                        }
                        .padding(DS.Spacing.md)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Templates")
            .searchable(text: $searchText, prompt: "Search templates...")
        }
    }
}
