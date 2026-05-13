import SwiftUI
import PhotosUI

// MARK: - Photo Picker Service
@Observable
class PhotoPickerService {
    var selectedItems: [PhotosPickerItem] = []
    var loadedImages: [UIImage] = []
    var isLoading = false
    
    func loadImages() async {
        isLoading = true
        var images: [UIImage] = []
        
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        await MainActor.run {
            loadedImages = images
            isLoading = false
        }
    }
}

// MARK: - Image Picker View
struct ImagePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photoPicker = PhotoPickerService()
    @State private var selectedItems: [PhotosPickerItem] = []
    var onImageSelected: (UIImage) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Photo picker grid
                if photoPicker.loadedImages.isEmpty {
                    emptyState
                } else {
                    loadedImagesGrid
                }
                
                // Action buttons
                VStack(spacing: DS.Spacing.sm) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 18))
                            Text("Choose from Gallery")
                                .font(DS.Typography.bodyMedium)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(DS.Colors.textInverse)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.Colors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        photoPicker.selectedItems = newItems
                        Task {
                            await photoPicker.loadImages()
                            if let first = photoPicker.loadedImages.first {
                                onImageSelected(first)
                                dismiss()
                            }
                        }
                    }
                    
                    Button {
                        // Camera functionality would go here
                    } label: {
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Take a Photo")
                                .font(DS.Typography.bodyMedium)
                        }
                        .foregroundColor(DS.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(DS.Colors.surfaceBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
            }
            .padding(.top, DS.Spacing.md)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(DS.Colors.info.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(DS.Colors.info)
            }
            
            VStack(spacing: DS.Spacing.xs) {
                Text("Add a Photo")
                    .font(DS.Typography.title)
                    .foregroundColor(DS.Colors.textPrimary)
                Text("أضف صورة")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DS.Colors.primary)
                Text("Choose from your gallery or take a photo")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.textTertiary)
            }
            Spacer()
        }
    }
    
    private var loadedImagesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DS.Spacing.xs),
                GridItem(.flexible(), spacing: DS.Spacing.xs),
                GridItem(.flexible(), spacing: DS.Spacing.xs),
            ], spacing: DS.Spacing.xs) {
                ForEach(Array(photoPicker.loadedImages.enumerated()), id: \.offset) { _, img in
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
            }
            .padding(.horizontal, DS.Spacing.md)
        }
    }
}

// MARK: - Advanced Color Picker
struct AdvancedColorPicker: View {
    @Binding var selectedColor: Color
    @State private var hue: Double = 0.5
    @State private var saturation: Double = 0.8
    @State private var brightness: Double = 0.9
    @State private var hexInput: String = "D4A853"
    @State private var showHexInput = false
    
    private let presetColors: [(String, Color)] = [
        ("White", .white),
        ("Black", .black),
        ("Gold", Color(hex: "D4A853")),
        ("Coral", Color(hex: "E8734A")),
        ("Sky", Color(hex: "5AC8FA")),
        ("Green", Color(hex: "34C759")),
        ("Purple", Color(hex: "AF52DE")),
        ("Pink", Color(hex: "FF6B8A")),
        ("Navy", Color(hex: "1A237E")),
        ("Teal", Color(hex: "30D5C8")),
        ("Amber", Color(hex: "FFB340")),
        ("Red", Color(hex: "FF4757")),
    ]
    
    var body: some View {
        VStack(spacing: DS.Spacing.md) {
            // Current color preview
            HStack(spacing: DS.Spacing.sm) {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(selectedColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.sm)
                            .stroke(DS.Colors.surfaceBorder, lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected Color")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    
                    if showHexInput {
                        HStack(spacing: 4) {
                            Text("#")
                                .font(DS.Typography.bodyMedium)
                                .foregroundColor(DS.Colors.textTertiary)
                            TextField("Hex", text: $hexInput)
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(DS.Colors.textPrimary)
                                .textInputAutocapitalization(.characters)
                                .onSubmit {
                                    selectedColor = Color(hex: hexInput)
                                }
                        }
                    } else {
                        Button {
                            showHexInput = true
                        } label: {
                            Text("#\(hexInput)")
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(DS.Colors.primary)
                        }
                    }
                }
                Spacer()
            }
            
            // Quick presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.xs) {
                    ForEach(presetColors, id: \.0) { name, color in
                        Button {
                            selectedColor = color
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(DS.Colors.surfaceBorder, lineWidth: 2)
                                )
                                .overlay(
                                    selectedColor.description == color.description ?
                                    Circle()
                                        .stroke(DS.Colors.primary, lineWidth: 3)
                                        .frame(width: 42, height: 42)
                                    : nil
                                )
                        }
                    }
                }
            }
            
            // HSB Sliders
            VStack(spacing: DS.Spacing.sm) {
                // Hue
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hue")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: stride(from: 0.0, through: 1.0, by: 0.1).map {
                                        Color(hue: $0, saturation: 0.8, brightness: 0.9)
                                    },
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 24)
                        Slider(value: $hue, in: 0...1)
                            .tint(.clear)
                            .onChange(of: hue) { _, _ in updateColor() }
                    }
                }
                
                // Saturation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saturation")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Slider(value: $saturation, in: 0...1)
                        .tint(DS.Colors.primary)
                        .onChange(of: saturation) { _, _ in updateColor() }
                }
                
                // Brightness
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brightness")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(DS.Colors.textTertiary)
                    Slider(value: $brightness, in: 0...1)
                        .tint(DS.Colors.primary)
                        .onChange(of: brightness) { _, _ in updateColor() }
                }
            }
        }
        .padding(DS.Spacing.md)
    }
    
    private func updateColor() {
        selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}
