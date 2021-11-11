//
//  PhotoBrowserPopTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPopTransitioning: NSObject, UINavigationControllerDelegate {
    
    let previewInfo: ResourcePreviewInfo
    var drivenInteraction: SwipeInteractionTransition?
    
    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init()
    }
    
    private lazy var pushAnimator = PhotoBrowserPushAnimator()
    private lazy var popAnimator = PhotoBrowserPopAnimator()

    private var isPush: Bool = false
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            isPush = true
            return pushAnimator
        } else {
            isPush = false
            return popAnimator
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interaction = drivenInteraction,
              interaction.interactionInProgress
        else { return nil }
        
        return interaction
    }
}
