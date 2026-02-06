//
//  CuratorImageProcessor.swift
//  supdate_native
//
//  Downscales and compresses images for the AI Curator, then returns Base64 strings.
//

import UIKit

enum CuratorImageProcessor {
    static let maxDimension: CGFloat = 768
    static let jpegQuality: CGFloat = 0.7

    /// Resizes image so the longest side is at most `maxDimension`, compresses to JPEG,
    /// and returns the result as a Base64 string. Returns nil if conversion fails.
    static func process(_ image: UIImage) -> String? {
        let resized = downscale(image, maxDimension: maxDimension)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else { return nil }
        return data.base64EncodedString()
    }

    /// Downscales so no dimension exceeds `maxDimension`. Preserves aspect ratio.
    static func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else { return image }
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
