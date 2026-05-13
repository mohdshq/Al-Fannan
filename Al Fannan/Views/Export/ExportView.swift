import SwiftUI
import Photos

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: CanvasViewModel
    @State private var selectedFormat: ExportFormat = .png
    @State private var quality: Double = 100
    @State private var isExporting = false
    @State private var exportComplete = false
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?
    private let renderService = CanvasRenderService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xl) {
                // Preview thumbnail
                if let img = renderedImage {
                    ZStack {
                        // Checkerboard for transparent preview
                        if selectedFormat == .pngTransparent {
                            CheckerboardView()
                                .frame(maxHeight: 160)
                                .aspectRatio(CGFloat(viewModel.canvasWidth / viewModel.canvasHeight), contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                        }
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 160)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                    .padding(.top, DS.Spacing.sm)
                }
                
                // Format selection
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Export Format")
                        .font(DS.Typography.bodyMedium)
                        .foregroundColor(DS.Colors.textSecondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: DS.Spacing.sm) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Button {
                                withAnimation(AnimationPreset.springSnappy) {
                                    selectedFormat = format
                                }
                            } label: {
                                VStack(spacing: DS.Spacing.xs) {
                                    Image(systemName: format.icon)
                                        .font(.system(size: 22))
                                    Text(format.rawValue)
                                        .font(DS.Typography.captionSmall)
                                }
                                .foregroundColor(selectedFormat == format ? DS.Colors.textInverse : DS.Colors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DS.Spacing.md)
                                .background(formatBackground(isSelected: selectedFormat == format))
                                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                                        .stroke(selectedFormat == format ? Color.clear : DS.Colors.surfaceBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                
                // Quality slider
                if selectedFormat == .jpg {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        HStack {
                            Text("Quality")
                                .font(DS.Typography.bodyMedium)
                                .foregroundColor(DS.Colors.textSecondary)
                            Spacer()
                            Text("\(Int(quality))%")
                                .font(DS.Typography.captionSmall)
                                .foregroundColor(DS.Colors.primary)
                        }
                        Slider(value: $quality, in: 10...100, step: 5)
                            .tint(DS.Colors.primary)
                    }
                }
                
                // Resolution info
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(DS.Colors.textTertiary)
                    Text("\(Int(viewModel.canvasWidth)) × \(Int(viewModel.canvasHeight)) px")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.textTertiary)
                    Spacer()
                    Text(selectedFormat == .pngTransparent ? "Transparent" : selectedFormat == .pdf ? "Vector" : "Raster")
                        .font(DS.Typography.captionSmall)
                        .foregroundColor(selectedFormat == .pngTransparent ? DS.Colors.accent : DS.Colors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((selectedFormat == .pngTransparent ? DS.Colors.accent : DS.Colors.primary).opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Export buttons
                VStack(spacing: DS.Spacing.sm) {
                    Button {
                        exportToPhotos()
                    } label: {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .tint(DS.Colors.textInverse)
                            } else if exportComplete {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Text(exportComplete ? "Saved to Photos!" : isExporting ? "Exporting..." : "Save to Photos")
                                .font(DS.Typography.bodyMedium)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(DS.Colors.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(exportComplete ? LinearGradient(colors: [Color(hex: "34C759"), Color(hex: "2AAF4F")], startPoint: .leading, endPoint: .trailing) : DS.Colors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                    }
                    .disabled(isExporting)
                    
                    Button {
                        shareDesign()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                                .font(DS.Typography.bodyMedium)
                        }
                        .foregroundColor(DS.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(DS.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.md)
                                .stroke(DS.Colors.surfaceBorder, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(DS.Spacing.xl)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            .onAppear {
                renderedImage = renderService.renderCanvas(viewModel: viewModel, scale: 0.25, transparent: selectedFormat == .pngTransparent)
            }
            .onChange(of: selectedFormat) { _, newFormat in
                renderedImage = renderService.renderCanvas(viewModel: viewModel, scale: 0.25, transparent: newFormat == .pngTransparent)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    @ViewBuilder
    private func formatBackground(isSelected: Bool) -> some View {
        if isSelected {
            DS.Colors.goldGradient
        } else {
            LinearGradient(colors: [DS.Colors.bgCard, DS.Colors.bgCard], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private func exportToPhotos() {
        isExporting = true
        let image = renderService.renderCanvas(viewModel: viewModel, scale: 1.0, transparent: selectedFormat == .pngTransparent)
        
        guard let image else {
            isExporting = false
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { isExporting = false }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                request.creationDate = Date()
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    isExporting = false
                    if success {
                        exportComplete = true
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            exportComplete = false
                        }
                    }
                }
            }
        }
    }
    
    private func shareDesign() {
        if renderedImage == nil {
            renderedImage = renderService.renderCanvas(viewModel: viewModel, scale: 1.0)
        }
        showShareSheet = true
    }
}

// MARK: - UIKit Share Sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Checkerboard View (transparency indicator)
struct CheckerboardView: View {
    let squareSize: CGFloat = 10
    
    var body: some View {
        Canvas { context, size in
            let rows = Int(size.height / squareSize) + 1
            let cols = Int(size.width / squareSize) + 1
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? Color(white: 0.85) : Color(white: 0.95))
                    )
                }
            }
        }
    }
}
