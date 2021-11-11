//
//  PhotoBrowserPushTransitioning.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserPushTransitioning: NSObject, UINavigationControllerDelegate {

    private var previewInfo: ResourcePreviewInfo

    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init()
        self.previewInfo.toFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        pushAnimator.previewInfo = self.previewInfo
    }

    private lazy var pushAnimator = PhotoBrowserPushAnimator()

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return pushAnimator
        }
        return nil
    }
}
