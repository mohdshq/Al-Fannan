import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Photo Filter Service
/// Applies CIFilter effects to images for the canvas editor
class PhotoFilterService {
    static let shared = PhotoFilterService()
    private let ciContext = CIContext()
    
    /// Apply a named CIFilter to a UIImage
    func applyFilter(named filterName: String, to image: UIImage, intensity: Float = 1.0) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        var outputImage: CIImage?
        
        switch filterName {
        case "CIPhotoEffectMono":
            let filter = CIFilter.photoEffectMono()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIPhotoEffectChrome":
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIPhotoEffectFade":
            let filter = CIFilter.photoEffectFade()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIPhotoEffectInstant":
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIPhotoEffectNoir":
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIPhotoEffectTonal":
            let filter = CIFilter.photoEffectTonal()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CISepiaTone":
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = intensity
            outputImage = filter.outputImage
            
        case "CIVibrance":
            let filter = CIFilter.vibrance()
            filter.inputImage = ciImage
            filter.amount = Float(intensity) * 1.5
            outputImage = filter.outputImage
            
        case "CIHighlightShadowAdjust":
            let filter = CIFilter.highlightShadowAdjust()
            filter.inputImage = ciImage
            filter.highlightAmount = 1.0 - intensity * 0.5
            filter.shadowAmount = Float(intensity) * 0.8
            outputImage = filter.outputImage
            
        case "CIGaussianBlur":
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = Float(intensity) * 10.0
            outputImage = filter.outputImage?.cropped(to: ciImage.extent)
            
        case "CIColorInvert":
            let filter = CIFilter.colorInvert()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIVignette":
            let filter = CIFilter.vignette()
            filter.inputImage = ciImage
            filter.intensity = Float(intensity) * 2.0
            filter.radius = Float(intensity) * 2.0
            outputImage = filter.outputImage
            
        case "CISharpenLuminance":
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = Float(intensity) * 1.5
            outputImage = filter.outputImage
            
        case "CIColorPosterize":
            let filter = CIFilter.colorPosterize()
            filter.inputImage = ciImage
            filter.levels = Float(6 - intensity * 4)
            outputImage = filter.outputImage
            
        case "CIBloom":
            let filter = CIFilter.bloom()
            filter.inputImage = ciImage
            filter.intensity = Float(intensity)
            filter.radius = Float(intensity) * 15.0
            outputImage = filter.outputImage
            
        case "CIComicEffect":
            let filter = CIFilter.comicEffect()
            filter.inputImage = ciImage
            outputImage = filter.outputImage
            
        case "CIEdges":
            let filter = CIFilter.edges()
            filter.inputImage = ciImage
            filter.intensity = Float(intensity) * 5.0
            outputImage = filter.outputImage
            
        case "CICrystallize":
            let filter = CIFilter.crystallize()
            filter.inputImage = ciImage
            filter.radius = Float(intensity) * 20.0
            outputImage = filter.outputImage
            
        default:
            // Try generic filter creation
            if let filter = CIFilter(name: filterName) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if filter.inputKeys.contains(kCIInputIntensityKey) {
                    filter.setValue(intensity, forKey: kCIInputIntensityKey)
                }
                outputImage = filter.outputImage
            }
        }
        
        guard let output = outputImage,
              let cgResult = ciContext.createCGImage(output, from: output.extent) else { return nil }
        
        return UIImage(cgImage: cgResult, scale: image.scale, orientation: image.imageOrientation)
    }
}
