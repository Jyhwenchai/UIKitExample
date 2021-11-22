//
//  PhotoBrowserDismissTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserDismissTransitioning: NSObject, UIViewControllerTransitioningDelegate {

    var transitionData: TransitionDismissData? {
        get { nil }
        set {
            interactiveTransition.transitionData = newValue
            dismissAnimator.transitionData = newValue
        }
    }
    
    var interactiveController: UIViewController? {
        get { interactiveTransition.interactiveController }
        set { interactiveTransition.interactiveController = newValue }
    }
    
    let interactiveTransition = DismissDrivenInteractiveTransition()
    private lazy var dismissAnimator = PhotoBrowserDismissAnimator()
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition.interactionInProgress ? interactiveTransition : nil
    }
}
