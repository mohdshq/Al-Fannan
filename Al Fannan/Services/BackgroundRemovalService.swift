import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Background Removal Service
/// Uses Apple's Vision framework (VNGeneratePersonSegmentationRequest) for on-device AI background removal
@Observable
class BackgroundRemovalService {
    var isProcessing = false
    var progress: Float = 0
    
    /// Remove background from an image using person segmentation
    func removeBackground(from image: UIImage, quality: Quality = .balanced) async -> UIImage? {
        await MainActor.run { isProcessing = true; progress = 0.1 }
        
        guard let cgImage = image.cgImage else {
            await MainActor.run { isProcessing = false }
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = quality.vnQuality
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                
                guard let segResult = request.results?.first else {
                    DispatchQueue.main.async { self.isProcessing = false }
                    continuation.resume(returning: nil)
                    return
                }
                
                let maskBuffer = segResult.pixelBuffer
                
                DispatchQueue.main.async { self.progress = 0.6 }
                
                // Apply mask to original image
                let ciContext = CIContext()
                let originalCI = CIImage(cgImage: cgImage)
                let maskCI = CIImage(cvPixelBuffer: maskBuffer)
                
                // Scale mask to match original image
                let scaleX = originalCI.extent.width / maskCI.extent.width
                let scaleY = originalCI.extent.height / maskCI.extent.height
                let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                // Apply mask using blend with mask filter
                let blendFilter = CIFilter.blendWithMask()
                blendFilter.inputImage = originalCI
                blendFilter.maskImage = scaledMask
                blendFilter.backgroundImage = CIImage.empty()
                    .cropped(to: originalCI.extent)
                
                guard let outputCI = blendFilter.outputImage,
                      let outputCG = ciContext.createCGImage(outputCI, from: originalCI.extent) else {
                    DispatchQueue.main.async { self.isProcessing = false }
                    continuation.resume(returning: nil)
                    return
                }
                
                let outputImage = UIImage(cgImage: outputCG)
                DispatchQueue.main.async {
                    self.progress = 1.0
                    self.isProcessing = false
                }
                continuation.resume(returning: outputImage)
                
            } catch {
                print("BG Removal failed: \(error)")
                DispatchQueue.main.async { self.isProcessing = false }
                continuation.resume(returning: nil)
            }
        }
    }
    
    /// Remove background using subject lifting (iOS 17+) — works on any object, not just people
    @available(iOS 17.0, *)
    func removeBackgroundSubjectLifting(from image: UIImage) async -> UIImage? {
        await MainActor.run { isProcessing = true; progress = 0.1 }
        
        guard let cgImage = image.cgImage else {
            await MainActor.run { isProcessing = false }
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                
                guard let result = request.results?.first else {
                    DispatchQueue.main.async { self.isProcessing = false }
                    continuation.resume(returning: nil)
                    return
                }
                
                DispatchQueue.main.async { self.progress = 0.5 }
                
                // Get all instance indices
                let indices = result.allInstances
                let maskBuffer = try result.generateMaskedImage(ofInstances: indices, from: handler, croppedToInstancesExtent: false)
                
                let ciContext = CIContext()
                let originalCI = CIImage(cgImage: cgImage)
                let maskCI = CIImage(cvPixelBuffer: maskBuffer)
                
                let scaleX = originalCI.extent.width / maskCI.extent.width
                let scaleY = originalCI.extent.height / maskCI.extent.height
                let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                
                let blendFilter = CIFilter.blendWithMask()
                blendFilter.inputImage = originalCI
                blendFilter.maskImage = scaledMask
                blendFilter.backgroundImage = CIImage.empty()
                    .cropped(to: originalCI.extent)
                
                guard let outputCI = blendFilter.outputImage,
                      let outputCG = ciContext.createCGImage(outputCI, from: originalCI.extent) else {
                    DispatchQueue.main.async { self.isProcessing = false }
                    continuation.resume(returning: nil)
                    return
                }
                
                let resultImage = UIImage(cgImage: outputCG)
                DispatchQueue.main.async {
                    self.progress = 1.0
                    self.isProcessing = false
                }
                continuation.resume(returning: resultImage)
                
            } catch {
                print("Subject lifting failed: \(error)")
                DispatchQueue.main.async { self.isProcessing = false }
                continuation.resume(returning: nil)
            }
        }
    }
    
    enum Quality {
        case fast, balanced, accurate
        var vnQuality: VNGeneratePersonSegmentationRequest.QualityLevel {
            switch self {
            case .fast: return .fast
            case .balanced: return .balanced
            case .accurate: return .accurate
            }
        }
    }
}
