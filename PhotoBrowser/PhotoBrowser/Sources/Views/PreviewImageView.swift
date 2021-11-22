//
//  PreviewImageView.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/11.
//

import UIKit

class PreviewImageView: UIScrollView {
    
    var startInteractingClosure: ( () -> Void )?
    var dismissClosure: ( () -> Void)?
    
    private var __resource: RawImage = .empty {
        didSet {
            imageView.image = __resource.image
            imageView.transform = .identity
            imageView.frame = __resource.fromFrame
            contentSize = __resource.fromFrame.size
        }
    }
    
    var resource: RawImage {
        get {
            var resource = __resource
            var fromFrame = imageView.frame
            if isInteracting {
                fromFrame.origin.x = -willBeginDraggingContentOffset.x
                if zoomScale > 0 {
                    if fromFrame.height >= bounds.height {
                        // image height >= screen height
                        fromFrame.origin.y = -willBeginDraggingContentOffset.y
                    } else {
                        // image height < screen height
                        fromFrame.origin.y = (bounds.height - fromFrame.height) / 2 - willBeginDraggingContentOffset.y
                    }
                }
            } else {
                // single tap to dismisss
                if fromFrame.height > bounds.height {
                    fromFrame.origin = CGPoint(x: -contentOffset.x, y: -contentOffset.y)
                }
            }
            
            resource.fromFrame = fromFrame
            return resource
        }
        set { __resource = newValue }
    }
    
    private(set) var isSwipedDown: Bool = false
    private(set) var isInteracting: Bool = false
    private var isContentZooming: Bool = false
    
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
        initGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endInteractive() {
        isInteracting = false
    }
    
    func initGestures() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        panGestureRecognizer.require(toFail: doubleTapGesture)
        singleTapGesture.require(toFail: doubleTapGesture)
        
        alwaysBounceVertical = true
    }
    
    @objc func singleTapAction(_ sender: UITapGestureRecognizer) {
        dismissClosure?()
    }
    
    @objc func doubleTapAction(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        let relativeImageLocation = sender.location(in: imageView)
        scaleImage(at: location, relativeImageLocation: relativeImageLocation)
    }
    
    func scaleImage(at point: CGPoint, relativeImageLocation location: CGPoint) {
        
        isContentZooming = true
        
        let newScale = zoomScale > 1 ? 1 : 2.0
        let viewSize = bounds.size
        var scaleOrigin = point
        let scaleSize = CGSize(width: 100, height: 100)
        // define the boundary of the zomm rect
        let top = location.y - 100
        let bottom = location.y + 100
        let left = location.x - 100
        let right = location.x + 100
        
        if top < 0 {
            scaleOrigin.y = 0
        } else if bottom > viewSize.height {
            scaleOrigin.y = viewSize.height
        } else {
            scaleOrigin.y -= scaleSize.height / 2
        }
        
        if left < 0 {
            scaleOrigin.x = 0
        } else if right > viewSize.width {
            scaleOrigin.x = viewSize.width
        } else {
            scaleOrigin.x -= scaleSize.width / 2
        }
        
        let rect = CGRect(origin: scaleOrigin, size: scaleSize)
        
        if newScale > 1 {
            maximumZoomScale = 2
            zoom(to: rect, animated: true)
            maximumZoomScale = 4
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
}


extension PreviewImageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isContentZooming { return }
        
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
       
        let transitionOffsetY: CGFloat = zoomScale > 1 ? -40.0 : 0
        let isScaleLargeImage =  zoomScale > 1
        if scrollView.contentOffset.y < transitionOffsetY
            && !isInteracting
            && isDraggingContentWhenZeroContentOffset {
            isInteracting = true
            if isScaleLargeImage {
                willBeginDraggingContentOffset = scrollView.contentOffset
            }
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
        isSwipedDown = abs(velocity.y) > 1.0 && abs(velocity.x) < 1.0
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
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isContentZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isContentZooming = false
    }
    
    
    private func centerImage() {
        var origin = imageView.frame.origin
        let size = imageView.frame.size
        origin.y = (bounds.height - size.height) / 2
        if size.height >= bounds.height {
            origin.y = 0
        }
        imageView.frame.origin = origin
    }

}
