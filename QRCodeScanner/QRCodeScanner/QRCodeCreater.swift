//
//  QRCodeCreater.swift
//  QRCodeScanner
//
//  Created by 蔡志文 on 2021/9/26.
//

import UIKit
import CoreImage


class QRCodeCreater {
    
    static func asyncCreateQRCodeImage(with code: String, size: CGSize, backgroundColor: UIColor = .white, frontColor: UIColor = .black, centerImage: UIImage? = nil, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let image = createQRCodeImage(with: code, size: size, backgroundColor: backgroundColor, frontColor: frontColor, centerImage: centerImage)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    static func asyncCreateQRCodeImage(with code: String, size: CGSize, backgroundColor: UIColor = .white, frontColor: UIColor = .black, centerImage: UIImage? = nil) async -> UIImage? {
        return await withCheckedContinuation({ (continuation: CheckedContinuation<UIImage?, Never>) in
            DispatchQueue.global().async {
                let image = createQRCodeImage(with: code, size: size, backgroundColor: backgroundColor, frontColor: frontColor, centerImage: centerImage)
                
                DispatchQueue.main.async {
                    continuation.resume(returning: image)
                }
            }
        })
    }
    
    
    static func createQRCodeImage(with code: String, size: CGSize, backgroundColor: UIColor = .white, frontColor: UIColor = .black, centerImage: UIImage? = nil) -> UIImage? {
        guard let codeData = code.data(using: .utf8) else {
            return nil
        }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
       
        qrFilter.setValue(codeData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let qrImage = qrFilter.outputImage else { return nil }
        // scale qr code image size
        guard let cgImage = CIContext(options: nil).createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.interpolationQuality = .none
        context.scaleBy(x: 1, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let codeImage = codeImage, let codeCGImage = codeImage.cgImage else { return nil }

        guard let centerImage = centerImage else {
            return codeImage
        }

        
        // draw code image background and front color.
        let ciFrontColor = CIColor(cgColor: frontColor.cgColor)
        let ciBackgroundColor = CIColor(cgColor: backgroundColor.cgColor)
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: [
            "inputImage": CIImage(cgImage: codeCGImage),
            "inputColor0": ciFrontColor,
            "inputColor1": ciBackgroundColor
        ])
        
        guard let outputImage = colorFilter?.outputImage else {
            return nil
        }
        
        let colorCodeImage = UIImage(ciImage: outputImage)
        
        UIGraphicsBeginImageContext(colorCodeImage.size)
        colorCodeImage.draw(in: CGRect(origin: .zero, size: CGSize(width: colorCodeImage.size.width, height: colorCodeImage.size.height)))
        let centerImageWidth: CGFloat = 50.0
        let centerImageX = (colorCodeImage.size.width - centerImageWidth) * 0.5
        let centerImagey = (colorCodeImage.size.height - centerImageWidth) * 0.5
        
        centerImage.draw(in: CGRect(x: centerImageX, y: centerImagey, width: centerImageWidth, height: centerImageWidth))
        
        let centerImageCode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let centerImageCode = centerImageCode else {
            return nil
        }
        return centerImageCode
    }
}
