//
//  PhotoBrowserPresentTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPresentTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    
    private var transitionData: TransitionData
    
    init(transitionData: TransitionData) {
        self.transitionData = transitionData
        self.transitionData.toFrame = convertImageFrameToPreviewFrame(transitionData.resource)
        super.init()
        presentAnimator.transitionData = self.transitionData
    }
    
    private let presentAnimator = PhotoBrowserPresentAnimator()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimator
    }
}
