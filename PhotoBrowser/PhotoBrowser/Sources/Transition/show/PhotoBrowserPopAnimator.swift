//
//  PhotoBrowserPopAnimator.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

class PhotoBrowserPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var previewInfo: ResourcePreviewInfo! = nil
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        guard let fromVC = transitionContext.viewController(forKey: .from) as? MutiplePhotoBrowserAnimateViewController else {
            return
        }
        
        containerView.addSubview(toView)
        
        /// set a placeholder view before the animation start
        let placeholderView = UIView(frame: previewInfo.toFrame)
        placeholderView.backgroundColor = .systemGray
        containerView.addSubview(placeholderView)
       
        /// add dimming view
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 1
        containerView.addSubview(dimmingView)
        
        let animateView = fromVC.imageView.snapshotView()!
        animateView.frame = previewInfo.fromFrame
        containerView.addSubview(animateView)
       
        /// execute animation
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            dimmingView.alpha = 0
            animateView.frame = self.previewInfo.toFrame
        } completion: { _ in
            animateView.removeFromSuperview()
            placeholderView.removeFromSuperview()
            dimmingView.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                fromView.addSubview(animateView)
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
    
    func animationEnded(_ transitionCompleted: Bool) {
    }
    
}
