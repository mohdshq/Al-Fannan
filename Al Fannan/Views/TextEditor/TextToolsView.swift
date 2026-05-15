import SwiftUI
import UniformTypeIdentifiers

struct TextToolsView: View {
    @Bindable var viewModel: CanvasViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var editText: String = ""
    @State private var selectedFont: String = "System"
    @State private var fontSize: CGFloat = 24
    @State private var textColor: Color = .white
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isRTL = false
    @State private var alignment: TextAlignmentOption = .center
    @State private var shadowEnabled = false
    @State private var strokeEnabled = false
    @State private var letterSpacing: CGFloat = 0
    @State private var lineSpacing: CGFloat = 4
    @State private var curveAngle: CGFloat = 0
    @State private var activeTab: TextToolTab = .edit
    @State private var fontSearch: String = ""
    @State private var fontCategory: FontItem.FontCategory? = nil
    @State private var showFontImporter = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(TextToolTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(AnimationPreset.springSnappy) { activeTab = tab }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16))
                                Text(tab.rawValue)
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(activeTab == tab ? DS.Colors.primary : DS.Colors.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.sm)
                        }
                    }
                }
                .background(DS.Colors.bgTertiary)
                
                // Tab content — each tab manages its own scrolling
                switch activeTab {
                case .edit:
                    ScrollView { editTab }
                case .font:
                    fontTab
                case .style:
                    ScrollView { styleTab }
                case .effects:
                    ScrollView { effectsTab }
                }
            }
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Text Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Toggle RTL
                        isRTL.toggle()
                        applyChanges()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isRTL ? "text.alignright" : "text.alignleft")
                            Text(isRTL ? "RTL" : "LTR")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(DS.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DS.Colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        applyChanges()
                        dismiss()
                    }
                    .foregroundColor(DS.Colors.primary)
                }
            }
            .onAppear { loadCurrentElement() }
            .fileImporter(
                isPresented: $showFontImporter,
                allowedContentTypes: [.font],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        FontManager.shared.importFont(from: url)
                        HapticManager.success()
                    }
                case .failure(let error):
                    print("Error importing font: \(error)")
                }
            }
        }
    }
    
    // MARK: - Edit Tab
    private var editTab: some View {
        VStack(spacing: DS.Spacing.md) {
            // Text input
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Text Content")
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textTertiary)
                TextEditor(text: $editText)
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
                    .padding(DS.Spacing.sm)
                    .background(DS.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                    .onChange(of: editText) { _, _ in applyChanges() }
            }
            
            // Quick presets
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Quick Text / نصوص جاهزة")
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textTertiary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.xs) {
                        quickTextButton("بسم الله الرحمن الرحيم", isAr: true)
                        quickTextButton("رمضان كريم", isAr: true)
                        quickTextButton("عيد مبارك", isAr: true)
                        quickTextButton("مبروك", isAr: true)
                        quickTextButton("Hello World", isAr: false)
                        quickTextButton("Thank You", isAr: false)
                    }
                }
            }
            
            // Alignment
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Alignment")
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textTertiary)
                HStack(spacing: DS.Spacing.xs) {
                    ForEach(TextAlignmentOption.allCases, id: \.self) { align in
                        Button {
                            alignment = align
                            applyChanges()
                        } label: {
                            Image(systemName: align == .leading ? "text.alignleft" : align == .center ? "text.aligncenter" : "text.alignright")
                                .font(.system(size: 16))
                                .foregroundColor(alignment == align ? DS.Colors.primary : DS.Colors.textTertiary)
                                .frame(width: 44, height: 36)
                                .background(alignment == align ? DS.Colors.primary.opacity(0.15) : DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
                        }
                    }
                    
                    Spacer()
                    
                    // Bold/Italic
                    Button {
                        isBold.toggle()
                        applyChanges()
                    } label: {
                        Text("B")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isBold ? DS.Colors.primary : DS.Colors.textTertiary)
                            .frame(width: 36, height: 36)
                            .background(isBold ? DS.Colors.primary.opacity(0.15) : DS.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
                    }
                    
                    Button {
                        isItalic.toggle()
                        applyChanges()
                    } label: {
                        Text("I")
                            .font(.system(size: 16, weight: .medium).italic())
                            .foregroundColor(isItalic ? DS.Colors.primary : DS.Colors.textTertiary)
                            .frame(width: 36, height: 36)
                            .background(isItalic ? DS.Colors.primary.opacity(0.15) : DS.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.xs))
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    private func quickTextButton(_ text: String, isAr: Bool) -> some View {
        Button {
            editText = text
            isRTL = isAr
            applyChanges()
        } label: {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, DS.Spacing.xs)
                .background(DS.Colors.surface)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - Font Tab
    private var fontTab: some View {
        VStack(spacing: 0) {
            // Font size slider
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text("Size")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text("\(Int(fontSize))pt")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.primary)
                }
                Slider(value: $fontSize, in: 8...200, step: 1)
                    .tint(DS.Colors.primary)
                    .onChange(of: fontSize) { _, _ in applyChanges() }
            }
            .padding(DS.Spacing.md)
            
            Divider().opacity(0.2)
            
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.xs) {
                    fontCategoryChip(nil, label: "All", labelAr: "الكل", count: FontManager.shared.allFonts.count)
                    ForEach(FontItem.FontCategory.allCases, id: \.self) { cat in
                        fontCategoryChip(cat, label: String(cat.rawValue.split(separator: "/").last ?? ""), labelAr: String(cat.rawValue.split(separator: "/").first ?? ""), count: FontManager.shared.allFonts.filter { $0.category == cat }.count)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
            }
            
            // Search & Import
            HStack(spacing: DS.Spacing.xs) {
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DS.Colors.textTertiary)
                    TextField("Search fonts...", text: $fontSearch)
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.textPrimary)
                    if !fontSearch.isEmpty {
                        Button { fontSearch = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.vertical, 8)
                .background(DS.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                
                Button {
                    showFontImporter = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.Colors.bgPrimary)
                        .frame(width: 36, height: 36)
                        .background(DS.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xs)
            
            // Font list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredFontList) { font in
                        Button {
                            selectedFont = font.name
                            applyChanges()
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: DS.Spacing.sm) {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(font.displayName)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(DS.Colors.textPrimary)
                                        Text(font.displayNameAr)
                                            .font(.system(size: 11))
                                            .foregroundColor(DS.Colors.textTertiary)
                                    }
                                    // Live preview using the actual font
                                    Text(font.previewText)
                                        .font(Font.custom(font.name, size: 20))
                                        .foregroundColor(selectedFont == font.name ? DS.Colors.primary : DS.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                if font.isPro {
                                    ProBadge()
                                }
                                if selectedFont == font.name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(DS.Colors.primary)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.vertical, DS.Spacing.sm)
                            .padding(.horizontal, DS.Spacing.md)
                            .background(selectedFont == font.name ? DS.Colors.primary.opacity(0.08) : Color.clear)
                        }
                        Divider().opacity(0.15).padding(.leading, DS.Spacing.md)
                    }
                }
            }
        }
    }
    
    private func fontCategoryChip(_ category: FontItem.FontCategory?, label: String, labelAr: String, count: Int) -> some View {
        let isActive = fontCategory == category
        return Button {
            withAnimation(AnimationPreset.springSnappy) { fontCategory = category }
        } label: {
            HStack(spacing: 4) {
                Text(label.trimmingCharacters(in: .whitespaces))
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                Text("(\(count))")
                    .font(.system(size: 9))
            }
            .foregroundColor(isActive ? DS.Colors.textInverse : DS.Colors.textSecondary)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, 6)
            .background(isActive ? DS.Colors.goldGradient : LinearGradient(colors: [DS.Colors.surface, DS.Colors.surface], startPoint: .leading, endPoint: .trailing))
            .clipShape(Capsule())
        }
    }
    
    private var filteredFontList: [FontItem] {
        var list = FontManager.shared.allFonts
        if let cat = fontCategory {
            list = list.filter { $0.category == cat }
        }
        if !fontSearch.isEmpty {
            list = list.filter {
                $0.displayName.localizedCaseInsensitiveContains(fontSearch) ||
                $0.displayNameAr.localizedCaseInsensitiveContains(fontSearch) ||
                $0.name.localizedCaseInsensitiveContains(fontSearch)
            }
        }
        return list
    }
    
    // MARK: - Style Tab
    private var styleTab: some View {
        VStack(spacing: DS.Spacing.md) {
            // Color picker
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text("Text Color")
                    .font(DS.Typography.captionSmall)
                    .foregroundColor(DS.Colors.textTertiary)
                ColorPicker("", selection: $textColor)
                    .labelsHidden()
                    .onChange(of: textColor) { _, _ in applyChanges() }
                
                // Quick colors
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.xs) {
                        let colors: [Color] = [.white, .black, DS.Colors.primary, DS.Colors.accent, .red, .blue, .green, .purple, .pink, .orange]
                        ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                            Button {
                                textColor = color
                                applyChanges()
                            } label: {
                                Circle().fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(Circle().stroke(DS.Colors.surfaceBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
            
            // Letter spacing
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text("Letter Spacing")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text(String(format: "%.1f", letterSpacing))
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.primary)
                }
                Slider(value: $letterSpacing, in: -5...20, step: 0.5)
                    .tint(DS.Colors.primary)
                    .onChange(of: letterSpacing) { _, _ in applyChanges() }
            }
            
            // Line spacing
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text("Line Spacing")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text(String(format: "%.1f", lineSpacing))
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.primary)
                }
                Slider(value: $lineSpacing, in: 0...40, step: 1)
                    .tint(DS.Colors.primary)
                    .onChange(of: lineSpacing) { _, _ in applyChanges() }
            }
            
            // Curve angle
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Image(systemName: "arrow.uturn.up")
                        .font(.system(size: 12))
                    Text("Text Curve")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text(curveAngle == 0 ? "Off" : String(format: "%.0f°", curveAngle))
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.primary)
                }
                Slider(value: $curveAngle, in: -180...180, step: 5)
                    .tint(DS.Colors.primary)
                    .onChange(of: curveAngle) { _, _ in applyChanges() }
                
                HStack(spacing: DS.Spacing.xs) {
                    ForEach([-90.0, -45.0, 0.0, 45.0, 90.0], id: \.self) { val in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                curveAngle = val
                                applyChanges()
                            }
                        } label: {
                            Text(val == 0 ? "Flat" : "\(Int(val))°")
                                .font(.system(size: 10, weight: curveAngle == val ? .bold : .regular))
                                .foregroundColor(curveAngle == val ? DS.Colors.textInverse : DS.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(curveAngle == val ? DS.Colors.primary : DS.Colors.surface)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    // MARK: - Effects Tab
    private var effectsTab: some View {
        VStack(spacing: DS.Spacing.md) {
            // Shadow
            Toggle(isOn: $shadowEnabled) {
                HStack {
                    Image(systemName: "shadow")
                    Text("Shadow")
                        .font(DS.Typography.bodyMedium)
                }
                .foregroundColor(DS.Colors.textPrimary)
            }
            .tint(DS.Colors.primary)
            .onChange(of: shadowEnabled) { _, _ in applyChanges() }
            
            // Stroke
            Toggle(isOn: $strokeEnabled) {
                HStack {
                    Image(systemName: "character.textbox")
                    Text("Stroke / Outline")
                        .font(DS.Typography.bodyMedium)
                }
                .foregroundColor(DS.Colors.textPrimary)
            }
            .tint(DS.Colors.primary)
            .onChange(of: strokeEnabled) { _, _ in applyChanges() }
        }
        .padding(DS.Spacing.md)
    }
    
    // MARK: - Helpers
    private func loadCurrentElement() {
        guard let el = viewModel.selectedElement, el.type == .text else { return }
        editText = el.text ?? ""
        if let style = el.textStyle {
            selectedFont = style.fontName
            fontSize = style.fontSize
            isBold = style.isBold
            isItalic = style.isItalic
            isRTL = style.isRTL
            alignment = style.alignment
            shadowEnabled = style.shadowEnabled
            strokeEnabled = style.strokeEnabled
            letterSpacing = style.letterSpacing
            lineSpacing = style.lineSpacing
            curveAngle = style.curveAngle
            textColor = Color(hex: style.textColor)
        }
    }
    
    private func applyChanges() {
        guard let id = viewModel.selectedElement?.id else { return }
        viewModel.updateElement(id) { el in
            el.text = editText
            el.textStyle = TextStyle(
                fontName: selectedFont,
                fontSize: fontSize,
                textColor: textColor.toHex(),
                alignment: alignment,
                letterSpacing: letterSpacing,
                lineSpacing: lineSpacing,
                isRTL: isRTL,
                isBold: isBold,
                isItalic: isItalic,
                shadowEnabled: shadowEnabled,
                strokeEnabled: strokeEnabled,
                curveAngle: curveAngle
            )
        }
    }
}

enum TextToolTab: String, CaseIterable {
    case edit = "Edit"
    case font = "Font"
    case style = "Style"
    case effects = "Effects"
    
    var icon: String {
        switch self {
        case .edit: return "pencil"
        case .font: return "textformat.size"
        case .style: return "paintpalette"
        case .effects: return "sparkles"
        }
    }
}

// MARK: - Color to Hex
extension Color {
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [1, 1, 1, 1]
        let r = Int((components[0]) * 255)
        let g = Int((components.count > 1 ? components[1] : components[0]) * 255)
        let b = Int((components.count > 2 ? components[2] : components[0]) * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
