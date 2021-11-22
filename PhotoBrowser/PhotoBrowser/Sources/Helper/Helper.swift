//
//  Helper.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/16.
//

import UIKit

func convertImageFrameToPreviewFrame(_ image: UIImage) -> CGRect {
    let pointSize = image.size
    let screenHeight = UIScreen.main.bounds.height
    
    let toWidth = UIScreen.main.bounds.width
    let toHeight = pointSize.height * toWidth / pointSize.width
    var toY: CGFloat = (screenHeight - toHeight) / 2
    toY = toY < 0 ? 0 : toY
    
    return CGRect(origin: CGPoint(x: 0, y: toY), size: CGSize(width: toWidth, height: toHeight))
}



public extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            if cornerRadius > 0 {
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
                path.addClip()
            }
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

