//
//  ResourceInfo.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

struct ResourcePreviewInfo {
    var resources: [UIImage]
    var selectedIndex: Int 
    var fromFrame: CGRect
    var toFrame: CGRect = .zero
    
    var selectedResource: UIImage {
        resources[selectedIndex]
    }
    

}

func convertImageFrameToPreviewFrame(_ image: UIImage) -> CGRect {
    let pointSize = image.size
    let screenHeight = UIScreen.main.bounds.height
    
    let toWidth = UIScreen.main.bounds.width
    let toHeight = pointSize.height * toWidth / pointSize.width
    var toY: CGFloat = (screenHeight - toHeight) / 2
    toY = toY < 0 ? 0 : toY
    
    return CGRect(origin: CGPoint(x: 0, y: toY), size: CGSize(width: toWidth, height: toHeight))
}
