//
//  PhotoBrowserTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

class PhotoBrowserShowTransitioning: NSObject, UINavigationControllerDelegate {
    
    private var previewInfo: ResourcePreviewInfo
    
    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init()
        self.previewInfo.toFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        pushAnimator.previewInfo = self.previewInfo
    }
    
    private lazy var pushAnimator = PhotoBrowserPresentAnimator()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        pushAnimator
    }
    
}
