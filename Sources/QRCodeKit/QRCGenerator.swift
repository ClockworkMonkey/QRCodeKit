//
//  QRCodeKit.swift
//  QRCodeKit
//
//  Created by Clockwork Monkey Stutdios on 2020/9/8.
//  Copyright © 2020 Clockwork Monkey Stutdios. All rights reserved.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

/// QR Code correction level. L: 7%, M: 15%, Q: 25%, H30%
public enum CorrectionLevel: String {
    case L, M, Q, H
}

public struct QRCGenerator {
    
    /// Generate QR code.
    /// - Parameters:
    ///   - message: Message for QR Code.
    ///   - correctionLevel: QR Code correction level. L: 7%, M: 15%, Q: 25%, H30%.
    ///   - sideLength: QR Code image height and width.
    /// - Returns: QR Code image.
    public static func generateQRCode(from message: String, correctionLevel: CorrectionLevel = .M, sideLength: CGFloat = 256.0) -> UIImage? {
        // QR code message.
        guard let messageData = message.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        // QR code filter.
        let qrCodeGeneratorFilter = CIFilter.qrCodeGenerator()
        qrCodeGeneratorFilter.message = messageData
        qrCodeGeneratorFilter.correctionLevel = correctionLevel.rawValue
        
        // QR code CIImage.
        let qrCodeCIImage = qrCodeGeneratorFilter.outputImage
        
        // False Color Filter.
        let falseColorFilter = CIFilter.falseColor()
        falseColorFilter.inputImage = qrCodeCIImage
        falseColorFilter.color0 = CIColor(red: 0, green: 0, blue: 0)
        falseColorFilter.color1 = CIColor(red: 1, green: 1, blue: 1)
        
        // False Color CIImage.
        guard let falseColorCIImage = falseColorFilter.outputImage else { return nil }
        
        // Scale image.
        let imageWidth = falseColorCIImage.extent.width
        let scale = sideLength / imageWidth
        let affineTransform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledCIImage = falseColorCIImage.transformed(by: affineTransform)
        
        // UIImage
        return UIImage.init(ciImage: scaledCIImage)
    }
    
}

