import SwiftUI

struct FontLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: FontItem.FontCategory? = nil
    @State private var showImportSheet = false
    
    private var filteredFonts: [FontItem] {
        var fonts = FontItem.sampleFonts
        if let cat = selectedCategory {
            fonts = fonts.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            fonts = fonts.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.displayNameAr.contains(searchText)
            }
        }
        return fonts
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.xs) {
                        categoryChip("All (\(FontItem.sampleFonts.count))", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(FontItem.FontCategory.allCases, id: \.self) { cat in
                            categoryChip("\(cat.rawValue) (\(FontItem.fonts(for: cat).count))", isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.sm)
                }
                
                Divider().opacity(0.2)
                
                // Font list
                ScrollView {
                    LazyVStack(spacing: DS.Spacing.xs) {
                        ForEach(Array(filteredFonts.enumerated()), id: \.element.id) { index, font in
                            fontRow(font)
                                .staggered(index: index)
                        }
                    }
                    .padding(DS.Spacing.md)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Fonts")
            .searchable(text: $searchText, prompt: "Search fonts...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showImportSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(DS.Colors.primary)
                    }
                }
            }
            .alert("Import Custom Font", isPresented: $showImportSheet) {
                Button("Choose OTF/TTF File") {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Import your own OTF or TTF font files to use in your designs.")
            }
        }
    }
    
    private func categoryChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(AnimationPreset.springSnappy) { action() }
        }) {
            Text(title)
                .font(DS.Typography.captionSmall)
                .foregroundColor(isSelected ? DS.Colors.textInverse : DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(isSelected ? AnyShapeStyle(DS.Colors.goldGradient) : AnyShapeStyle(DS.Colors.surface))
                .clipShape(Capsule())
        }
    }
    
    private func fontRow(_ font: FontItem) -> some View {
        HStack(spacing: DS.Spacing.md) {
            // Language indicator
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(font.isArabic ? DS.Colors.primary.opacity(0.15) : DS.Colors.info.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(font.isArabic ? "ع" : "A")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(font.isArabic ? DS.Colors.primary : DS.Colors.info)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(font.displayName)
                        .font(DS.Typography.bodyMedium)
                        .foregroundColor(DS.Colors.textPrimary)
                    Text(font.displayNameAr)
                        .font(.system(size: 12))
                        .foregroundColor(DS.Colors.textTertiary)
                    if font.isPro {
                        ProBadge()
                    }
                }
                Text(font.previewText)
                    .font(Font.custom(font.name, size: 18))
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(font.category.rawValue)
                .font(.system(size: 10))
                .foregroundColor(DS.Colors.textTertiary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DS.Colors.surface)
                .clipShape(Capsule())
        }
        .padding(DS.Spacing.sm)
        .background(DS.Colors.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }
}
