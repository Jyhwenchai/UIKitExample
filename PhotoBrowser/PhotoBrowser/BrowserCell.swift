//
//  BrowserCell.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PreviewScrollView: UIScrollView {
    var isSwiped: Bool = false
    
    
}

class BrowserCell: UICollectionViewCell {
    
    var resourceFrame: CGRect = .zero {
        didSet {
            imageView.transform = .identity
            imageView.frame = resourceFrame
            scrollView.contentSize = resourceFrame.size
        }
    }
    
    private var isZooming: Bool = false
    private var isActiveInteractive: Bool = false
    
    private var draggingTimes: Int = 0
    private var isContinuousDragging: Bool = false
    private var endDraggingTargetOffset: CGPoint = .zero
    private var willStartAnimateContentOffset: CGPoint = .zero

    
    lazy var scrollView: PreviewScrollView = {
        let scrollView = PreviewScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 4
        return scrollView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
    }
    
    var callback: (() -> Void)?
    var cancelCallback: (() -> Void)?
    
    func unActiveInteractive() {
        isActiveInteractive = false
    }
}

extension BrowserCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isActiveInteractive {
            scrollView.contentOffset = willStartAnimateContentOffset
            return
        }
        
        // disable dragging up
        if scrollView.contentSize.height <= bounds.height && scrollView.contentOffset.y > 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            return
        }
        
        if isZooming { return }
        
        if scrollView.isDecelerating {
            return
        }

        if scrollView.contentSize.height > bounds.height && isContinuousDragging {
            return
        }
        
        if scrollView.contentOffset.y < 0 && !isActiveInteractive {
            isActiveInteractive = true
            callback?()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        draggingTimes += 1
        isContinuousDragging = draggingTimes > 1
        willStartAnimateContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // if decelerate value is false, the delegate does not call `scrollViewDidEndDecelerating(_:)` method.
        if !decelerate {
            draggingTimes = 0
        }
    }
    
    // if velocity value is .zero, the delegate does not call `scrollViewDidEndDecelerating(_:)` method.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollView.isSwiped = velocity.y != 0
        endDraggingTargetOffset = targetContentOffset.pointee
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //TODO: - the two values below maybe not equal
        if endDraggingTargetOffset.y == scrollView.contentOffset.y {
            draggingTimes = 0
        }
    }
    
    
    //MARK: - Zoom
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        isZooming = true
        centerImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
    }
    
    func centerImage() {
        var origin = imageView.frame.origin
        let size = imageView.frame.size
        origin.y = (bounds.height - size.height) / 2
        if size.height >= bounds.height {
            origin.y = 0
        }
        imageView.frame.origin = origin
    }
}
