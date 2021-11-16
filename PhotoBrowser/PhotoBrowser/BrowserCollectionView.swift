//
//  BrowserCollectionView.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/16.
//

import UIKit

class BrowserCollectionView: UICollectionView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer.view is UIScrollView {
            let gesture = otherGestureRecognizer as! UIPanGestureRecognizer
            print("111: \(gesture.velocity(in: self))")
        }
        
        if gestureRecognizer is UIPanGestureRecognizer, gestureRecognizer.view is UICollectionView {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            print("222: \(gesture.velocity(in: self))")
        }
        return false
    }

}
