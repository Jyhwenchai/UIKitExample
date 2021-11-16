//
//  DismissDrivenInteractiveTransition.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class DismissDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    private(set) var interactionInProgress: Bool = false
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private weak var panGesture: UIPanGestureRecognizer?
    private var transitionDeviationOffset: CGPoint = .zero
    
    var transitionData: TransitionData!
    weak var interactiveController: UIViewController! 
    var interactiveEndClosure: ( ()->Void )?
    
    private var dimmingView: UIView?
    private var placeholderView: UIView?
    private var animateView: UIView?
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        prepareBeginTransitionProgress()
    }
    
    func registerPanGesture(_ gesture: UIPanGestureRecognizer) {
        unregisterPanGesture()
        gesture.addTarget(self, action: #selector(panGestureAction(gesture:)))
        panGesture = gesture
    }
    
    private func unregisterPanGesture() {
        if let panGesture = panGesture {
            panGesture.removeTarget(self, action: #selector(panGestureAction(gesture:)))
            self.panGesture = nil
        }
    }
    
    func startDismissTransition() {
        transitionDeviationOffset = .zero
        interactionInProgress = true
        interactiveController.dismiss(animated: true, completion: nil)
    }
    
    @objc func panGestureAction(gesture: UIPanGestureRecognizer) {
        
        guard interactionInProgress else { return }
        
        let (translation, scale) = calculateTranslationAndScale(from: gesture)
        switch gesture.state {
        case .possible: break
        case .began: break
        case .changed:
            if transitionData.fromFrame.width > UIScreen.main.bounds.width,
               transitionDeviationOffset == .zero {
                transitionDeviationOffset = translation
                let (translation, scale) = calculateTranslationAndScale(from: gesture)
                update(scale)
                changeTransitionProgress(translation)
                break
            }
     
            update(scale)
            changeTransitionProgress(translation)
        case .cancelled, .failed, .ended:
            interactionInProgress = false
            let view: PreviewImageView = gesture.view as! PreviewImageView
            if view.isSwipedDown && gesture.state == .ended {
                finishTransitionProgress(translation)
                return
            }
            
            if scale > 0.5 && gesture.state == .ended {
                finishTransitionProgress(translation)
            } else {
                cancelTransitionProgress(translation)
            }
            
        default: break
        }
    }
    
    private func calculateTranslationAndScale(from gesture: UIPanGestureRecognizer) -> (CGPoint, CGFloat) {
        var translation = gesture.translation(in: gesture.view)
        translation = CGPoint(x: translation.x - transitionDeviationOffset.x, y: translation.y - transitionDeviationOffset.y)
        let screenHeight = UIScreen.main.bounds.height
        let scale = abs(translation.y) / screenHeight
        return (translation, scale)
    }
    
    func prepareBeginTransitionProgress() {
        guard let transitionContext = self.transitionContext else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        // placeholder imageView
        let placeholderView = UIView()
        placeholderView.backgroundColor = .gray
        placeholderView.frame = transitionData.toFrame
        containerView.addSubview(placeholderView)
        self.placeholderView = placeholderView
        
        // dimming View
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        containerView.addSubview(dimmingView)
        self.dimmingView = dimmingView
        
        // placeholder imageView
        let animateView = UIImageView(image: transitionData.resource)
        animateView.alpha = 1
        animateView.frame = transitionData.fromFrame
        containerView.addSubview(animateView)
        self.animateView = animateView
        
        if let location = panGesture?.location(in: interactiveController.view) {
            let clickPoint = interactiveController.view.convert(location, to: animateView)
            let x = clickPoint.x / transitionData.fromFrame.width
            let y = clickPoint.y / transitionData.fromFrame.height
            animateView.setAnchorPoint(CGPoint(x: x, y: y))
        }
    }
    
    func changeTransitionProgress(_ translation: CGPoint) {
        guard let dimmingView = dimmingView else {
            return
        }

        guard let animateView = animateView else {
            return
        }
        
        let screenHeight = UIScreen.main.bounds.height
        let scale = 1 - abs(translation.y) / screenHeight
        let x = translation.x
        let y = translation.y
        animateView.transform = CGAffineTransform(translationX: x, y: y).scaledBy(x: scale, y: scale)
        dimmingView.alpha = scale
    }
    
    func finishTransitionProgress(_ translation: CGPoint) {
        guard let dimmingView = dimmingView else {
            return
        }

        guard let placeholderView = placeholderView else {
            return
        }
        
        guard let animateView = animateView else {
            return
        }
        
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
            dimmingView.alpha = 0
            animateView.frame = self.transitionData.toFrame
        } completion: { _ in
            self.finish()
            animateView.removeFromSuperview()
            dimmingView.removeFromSuperview()
            placeholderView.removeFromSuperview()
            let cancel = self.transitionContext!.transitionWasCancelled
            self.transitionContext?.completeTransition(!cancel)
            self.unregisterPanGesture()
        }
    }
    
    func cancelTransitionProgress(_ translation: CGPoint) {
        guard let toView = transitionContext?.view(forKey: .to) else { return }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.dimmingView?.alpha = 1
            self.animateView?.frame = self.transitionData.fromFrame
        } completion: { _ in
            self.cancel()
            self.animateView?.removeFromSuperview()
            self.dimmingView?.removeFromSuperview()
            self.placeholderView?.removeFromSuperview()
            toView.removeFromSuperview()
            let cancel = self.transitionContext!.transitionWasCancelled
            self.transitionContext?.completeTransition(!cancel)
            self.interactiveEndClosure?()
        }

    }
}

