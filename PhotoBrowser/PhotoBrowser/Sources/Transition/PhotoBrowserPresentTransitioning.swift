//
//  PhotoBrowserPresentTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPresentTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    
    private var transitionData: TransitionPresentData
    
    init(transitionData: TransitionPresentData) {
        self.transitionData = transitionData
        if var resource = transitionData.resource as? RawImage {
            resource.toFrame = convertImageFrameToPreviewFrame(resource.image)
            self.transitionData.resource = resource
        }
        super.init()
        presentAnimator.transitionData = self.transitionData
    }
    
    private let presentAnimator = PhotoBrowserPresentAnimator()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimator
    }
}
