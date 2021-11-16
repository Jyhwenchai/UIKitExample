//
//  PhotoBrowserPresentTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPresentTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    
    private var previewInfo: ResourcePreviewInfo
    
    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init()
        self.previewInfo.toFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        pushAnimator.previewInfo = self.previewInfo
    }
    
    private lazy var pushAnimator = PhotoBrowserPresentAnimator()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        pushAnimator
    }
}
