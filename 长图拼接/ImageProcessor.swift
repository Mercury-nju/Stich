//
//  ImageProcessor.swift
//  长图拼接
//
//  Created by Mercury on 2026/1/11.
//

import UIKit

enum ImageProcessor {
    
    /// Maximum dimension for processing to prevent memory issues
    static let maxDimension: CGFloat = 4096
    
    /// Stitch images vertically with memory optimization
    static func stitchImages(_ images: [UIImage], maxWidth: CGFloat? = nil) -> UIImage? {
        guard !images.isEmpty else { return nil }
        
        // Downsample images if needed
        let processedImages = images.map { downsampleIfNeeded($0) }
        
        // Calculate dimensions
        let targetWidth = maxWidth ?? processedImages.map { $0.size.width }.max() ?? 0
        guard targetWidth > 0 else { return nil }
        
        // Calculate total height
        var totalHeight: CGFloat = 0
        var scaledHeights: [CGFloat] = []
        
        for image in processedImages {
            let scale = targetWidth / image.size.width
            let scaledHeight = image.size.height * scale
            scaledHeights.append(scaledHeight)
            totalHeight += scaledHeight
        }
        
        // Check if result would be too large
        let finalWidth = min(targetWidth, maxDimension)
        let widthScale = finalWidth / targetWidth
        let finalHeight = min(totalHeight * widthScale, maxDimension * 4) // Allow 4:1 aspect ratio max
        
        // Create renderer with optimized format
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Use 1x scale to reduce memory
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: finalWidth, height: finalHeight),
            format: format
        )
        
        let result = renderer.image { context in
            // Fill background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: finalWidth, height: finalHeight))
            
            var yOffset: CGFloat = 0
            let heightScale = finalHeight / totalHeight
            
            for (index, image) in processedImages.enumerated() {
                let drawHeight = scaledHeights[index] * widthScale * heightScale
                
                // Only draw if within bounds
                if yOffset < finalHeight {
                    let drawRect = CGRect(
                        x: 0,
                        y: yOffset,
                        width: finalWidth,
                        height: min(drawHeight, finalHeight - yOffset)
                    )
                    image.draw(in: drawRect)
                }
                
                yOffset += drawHeight
            }
        }
        
        return result
    }
    
    /// Downsample image if it exceeds maximum dimension
    static func downsampleIfNeeded(_ image: UIImage) -> UIImage {
        let maxDim = max(image.size.width, image.size.height)
        
        guard maxDim > maxDimension else { return image }
        
        let scale = maxDimension / maxDim
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Calculate estimated memory usage for stitching
    static func estimatedMemoryUsage(for images: [UIImage]) -> Int64 {
        var total: Int64 = 0
        for image in images {
            // 4 bytes per pixel (RGBA)
            let pixels = Int64(image.size.width * image.size.height * image.scale * image.scale)
            total += pixels * 4
        }
        return total
    }
    
    /// Check if stitching is safe based on available memory
    static func canSafelyStitch(_ images: [UIImage]) -> Bool {
        let estimated = estimatedMemoryUsage(for: images)
        // Conservative limit: 500MB
        return estimated < 500 * 1024 * 1024
    }
}
