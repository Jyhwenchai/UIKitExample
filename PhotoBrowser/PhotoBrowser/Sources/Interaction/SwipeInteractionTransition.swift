//
//  SwipeInteractionTransition.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/5.
//

import UIKit

class SwipeInteractionTransition: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    private(set) var transitionOffset: CGPoint = .zero
    
    let previewInfo: ResourcePreviewInfo
    weak var swipeController: UIViewController?
    
    private var dimmingView: UIView?
    private var placeholderView: UIView?
    private var animateView: UIView?
    
    init(previewInfo: ResourcePreviewInfo,
         swipeController: UIViewController? = nil) {
        self.previewInfo = previewInfo
        self.swipeController = swipeController
        super.init()
        initGesture()
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        prepareBeginTransitionProgress()
    }
    
    func initGesture() {
        guard let navController = swipeController?.navigationController else {
            return
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(gesture:)))
        navController.view.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureAction(gesture: UIPanGestureRecognizer) {
        let transition = gesture.translation(in: gesture.view)
        transitionOffset = transition
        let screenHeight = UIScreen.main.bounds.height
        let scale = abs(transition.y) / screenHeight
        switch gesture.state {
        case .possible: break
        case .began:
            interactionInProgress = true
            swipeController?.navigationController?.popViewController(animated: true)
        case .changed:
            update(scale)
            changeTransitionProgress(transition)
        case .cancelled, .failed, .ended:
            interactionInProgress = false
            if scale > 0.5 && gesture.state != .cancelled {
                finishTransitionProgress(transition)
            } else {
                cancelTransitionProgress(transition)
            }
        default: break
        }
    }
    
    func prepareBeginTransitionProgress() {
        guard let transitionContext = self.transitionContext else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromVC = transitionContext.viewController(forKey: .from) as? MutiplePhotoBrowserAnimateViewController else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        // placeholder imageView
        let placeholderView = UIView()
        placeholderView.backgroundColor = .gray
        placeholderView.frame = previewInfo.toFrame
        containerView.addSubview(placeholderView)
        self.placeholderView = placeholderView
        
        // dimming View
        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .black
        containerView.addSubview(dimmingView)
        self.dimmingView = dimmingView
        
        // placeholder imageView
        guard let animateView = fromVC.imageView.snapshotView() else { return }
        animateView.frame = previewInfo.fromFrame
        containerView.addSubview(animateView)
        self.animateView = animateView
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
        let y = translation.y - previewInfo.fromFrame.height * (1 - scale) * scale
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
            animateView.frame = self.previewInfo.toFrame
        } completion: { _ in
            self.finish()
            animateView.removeFromSuperview()
            dimmingView.removeFromSuperview()
            placeholderView.removeFromSuperview()
            let cancel = self.transitionContext!.transitionWasCancelled
            self.transitionContext?.completeTransition(!cancel)
        }
    }
    
    func cancelTransitionProgress(_ translation: CGPoint) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.dimmingView?.alpha = 1
            self.animateView?.frame = self.previewInfo.fromFrame
        } completion: { _ in
            self.cancel()
            self.animateView?.removeFromSuperview()
            self.dimmingView?.removeFromSuperview()
            self.placeholderView?.removeFromSuperview()
            let cancel = self.transitionContext!.transitionWasCancelled
            self.transitionContext?.completeTransition(!cancel)
        }

    }
}


public extension UIView {
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }

    func snapshotView() -> UIView? {
        if let snapshotImage = snapshotImage() {
            return UIImageView(image: snapshotImage)
        } else {
            return nil
        }
    }
}
