//
//  PhotoBrowserDismissAnimator.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionData: TransitionData!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        containerView.addSubview(toView)
        
        /// set a placeholder view before the animation start
        let placeholderView = UIView(frame: transitionData.toFrame)
        placeholderView.backgroundColor = .systemGray
        containerView.addSubview(placeholderView)
       
        /// add dimming view
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 1
        containerView.addSubview(dimmingView)
        
        let animateView = UIImageView(image: transitionData.resource)
        animateView.frame = transitionData.fromFrame
        containerView.addSubview(animateView)
       
        /// execute animation
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            dimmingView.alpha = 0
            animateView.frame = self.transitionData.toFrame
        } completion: { _ in
            animateView.removeFromSuperview()
            placeholderView.removeFromSuperview()
            dimmingView.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
    
}
