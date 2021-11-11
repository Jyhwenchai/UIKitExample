//
//  PreviewImageView.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/11.
//

import UIKit

class PreviewImageView: UIScrollView {
    
    var startInteractingClosure: ( () -> Void)?
    
    private var __resource: ImageResource = .empty {
        didSet {
            if case let .raw(image) = __resource.type {
                imageView.image = image
            }
            imageView.transform = .identity
            imageView.frame = __resource.fromFrame
            contentSize = __resource.fromFrame.size
        }
    }
    
    var resource: ImageResource {
        get {
            var resource = __resource
            resource.fromFrame = imageView.frame
            return resource
        }
        set { __resource = newValue }
    }
    
    private(set) var isSwiped: Bool = false
    private(set) var isInteracting: Bool = false
    
    private var draggingTimes: Int = 0
    private var isContinuousDragging: Bool { draggingTimes > 1 }

    // Begin dragging when contentOffset.y valu is 0.
    private var isDraggingContentWhenZeroContentOffset: Bool = true
    
    // Begin dragging contentOffset.
    private var willBeginDraggingContentOffset: CGPoint = .zero
    
    // End Dragging target contentOffset.
    private var endDraggingTargetOffset: CGPoint = .zero
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endInteractive() {
        isInteracting = false
    }
    
}


extension PreviewImageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isZooming { return }
        
        if isInteracting {
            scrollView.contentOffset = willBeginDraggingContentOffset
            return
        }
        
        // disable dragging up
        if scrollView.contentSize.height <= bounds.height && scrollView.contentOffset.y > 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            return
        }
        
        if scrollView.isDecelerating {
            return
        }
        
        if scrollView.contentSize.height > bounds.height && isContinuousDragging {
            return
        }
        
        if scrollView.contentOffset.y < 0 && !isInteracting && isDraggingContentWhenZeroContentOffset {
            isInteracting = true
            startInteractingClosure?()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        draggingTimes += 1
        willBeginDraggingContentOffset = scrollView.contentOffset
        isDraggingContentWhenZeroContentOffset = scrollView.contentOffset.y == 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // if decelerate value is false, the delegate does not call `scrollViewDidEndDecelerating(_:)` method.
        if !decelerate {
            draggingTimes = 0
        }
    }
    
    // if velocity value is .zero, the delegate does not call `scrollViewDidEndDecelerating(_:)` method.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.isSwiped = velocity.y != 0
        endDraggingTargetOffset = targetContentOffset.pointee
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //TODO: - the two values below maybe not equal
        if endDraggingTargetOffset.y == scrollView.contentOffset.y {
            draggingTimes = 0
        }
    }
    
    
    //MARK: - Zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
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
