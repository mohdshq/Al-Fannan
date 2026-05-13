import SwiftUI

struct CreateProjectSheet: View {
    @Binding var navigateToEditor: Bool
    var canvasVM: CanvasViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPreset: CanvasPreset? = nil
    @State private var customWidth: String = "1080"
    @State private var customHeight: String = "1920"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.xl) {
                    // Header
                    VStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "plus.rectangle.on.rectangle")
                            .font(.system(size: 40))
                            .foregroundStyle(DS.Colors.goldGradient)
                            .floating()
                        Text("New Design")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.textPrimary)
                        Text("تصميم جديد")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.Colors.primary)
                        Text("Choose a canvas size to get started")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    .padding(.top, DS.Spacing.md)
                    
                    // Social Media
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Social Media")
                            .font(DS.Typography.bodyMedium)
                            .foregroundColor(DS.Colors.textSecondary)
                            .padding(.horizontal, DS.Spacing.md)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: DS.Spacing.sm) {
                            ForEach(CanvasPreset.presets.prefix(8)) { preset in
                                presetCard(preset)
                            }
                        }
                        .padding(.horizontal, DS.Spacing.md)
                    }
                    
                    // Print & Other
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Print & Other")
                            .font(DS.Typography.bodyMedium)
                            .foregroundColor(DS.Colors.textSecondary)
                            .padding(.horizontal, DS.Spacing.md)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: DS.Spacing.sm) {
                            ForEach(CanvasPreset.presets.suffix(3)) { preset in
                                presetCard(preset)
                            }
                        }
                        .padding(.horizontal, DS.Spacing.md)
                    }
                    
                    // Custom Size
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("Custom Size")
                            .font(DS.Typography.bodyMedium)
                            .foregroundColor(DS.Colors.textSecondary)
                            .padding(.horizontal, DS.Spacing.md)
                        
                        HStack(spacing: DS.Spacing.sm) {
                            TextField("Width", text: $customWidth)
                                .keyboardType(.numberPad)
                                .foregroundColor(DS.Colors.textPrimary)
                                .padding(DS.Spacing.sm)
                                .background(DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            
                            Text("×")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.textTertiary)
                            
                            TextField("Height", text: $customHeight)
                                .keyboardType(.numberPad)
                                .foregroundColor(DS.Colors.textPrimary)
                                .padding(DS.Spacing.sm)
                                .background(DS.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            
                            GoldButton("Create", icon: "plus", isCompact: true) {
                                if let w = Double(customWidth), let h = Double(customHeight) {
                                    let preset = CanvasPreset(name: "Custom", nameAr: "مخصص", icon: "aspectratio", width: w, height: h)
                                    canvasVM.loadNewProject(preset: preset)
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        navigateToEditor = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, DS.Spacing.md)
                    }
                }
                .padding(.bottom, DS.Spacing.huge)
            }
            .background(DS.Colors.bgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
    }
    
    private func presetCard(_ preset: CanvasPreset) -> some View {
        Button {
            canvasVM.loadNewProject(preset: preset)
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                navigateToEditor = true
            }
        }
        label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.system(size: 20))
                    .foregroundColor(DS.Colors.primary)
                    .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textPrimary)
                        .lineLimit(1)
                    Text(preset.displaySize)
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                
                // Aspect ratio preview
                let w: CGFloat = preset.width > preset.height ? 28 : 28 * (preset.width / preset.height)
                let h: CGFloat = preset.height > preset.width ? 28 : 28 * (preset.height / preset.width)
                RoundedRectangle(cornerRadius: 3)
                    .stroke(DS.Colors.primary.opacity(0.5), lineWidth: 1.5)
                    .frame(width: w, height: h)
            }
            .padding(DS.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(selectedPreset?.id == preset.id ? DS.Colors.primary : DS.Colors.surfaceBorder, lineWidth: 1)
                    )
            )
        }
    }
}
