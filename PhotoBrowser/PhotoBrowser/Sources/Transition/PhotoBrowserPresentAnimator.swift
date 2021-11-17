//
//  PhotoBrowserPresentAnimator.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPresentAnimator: NSObject , UIViewControllerAnimatedTransitioning {
    
    var transitionData: TransitionData!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        containerView.addSubview(toView!)
        toView?.isHidden = true // 在动画完成前隐藏
        
        /// set a placeholder view before the animation start
        let placeholderView = UIView(frame: transitionData.fromFrame)
        placeholderView.backgroundColor = .systemGray
        containerView.addSubview(placeholderView)
        
        /// add dimming view
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)
        
        /// add transition image view
        let transitionImageView = UIImageView(frame: transitionData.fromFrame)
        transitionImageView.image = transitionData.resource
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.layer.masksToBounds = true
        containerView.addSubview(transitionImageView)
        
        /// execute animation
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            dimmingView.alpha = 1
            transitionImageView.frame = self.transitionData.toFrame
        } completion: { _ in
            toView?.isHidden = false
            placeholderView.removeFromSuperview()
            dimmingView.removeFromSuperview()
            transitionImageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
    
}
