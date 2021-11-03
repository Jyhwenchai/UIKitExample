//
//  MainScrollView.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/28.
//

import UIKit

@objc protocol MainScrollViewDelegate {
    @objc optional func contentScrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func contentScrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func contentScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func contentScrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
}

class MainScrollView: UIScrollView {
    
    var isArrowMoved: Bool = true
    var sectionHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var pageCount: Int = 0 {
        didSet { contentCollectionView.pageCount = pageCount }
    }
    
    public var contentDelegate: MainScrollViewDelegate? = nil
    
    private var isDisabledDelegateCallback: Bool = false
    
    var headerView: UIView? = nil {
        didSet {
            if let view = headerView {
                addSubview(view)
            }
        }
    }
    var sectionView: UIView? = nil {
        didSet {
            if let view = sectionView {
                addSubview(view)
            }
        }
    }
    
    private var mainViewArrowMovedToken: NSObjectProtocol? = nil
    
    private lazy var contentCollectionView: ContentCollectionView = {
        let collectionView = ContentCollectionView(frame: .zero)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(contentCollectionView)
        delegate = self
        mainViewArrowMovedToken = NotificationCenter.default.addObserver(forName: MainScrollView.mainViewArrowMovedNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.isArrowMoved = true
            self.contentCollectionView.isArrowMoved = false
        }
        
        contentCollectionView.scrollViewWillBeginDraggingHandler = { [weak self] scrollView in
            guard let self = self else { return }
            self.contentDelegate?.contentScrollViewWillBeginDragging?(scrollView)
        }
        
        contentCollectionView.scrollViewDidEndDeceleratingHandler = { [weak self] scrollView in
            guard let self = self else { return }
            self.contentDelegate?.contentScrollViewDidEndDecelerating?(scrollView)
        }
        
        
        contentCollectionView.scrollViewDidScrollHandler = { [weak self] scrollView in
            guard let self = self else { return }
            guard !self.isDisabledDelegateCallback else { return }
            self.contentDelegate?.contentScrollViewDidScroll?(scrollView)
        }
        
        contentCollectionView.scrollViewWillEndDraggingHandler = { [weak self] scrollView, velocity, targetContentOffset in
            guard let self = self else { return }
            self.contentDelegate?.contentScrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
        
        contentCollectionView.scrollMainScrollViewToSectionTop = { [weak self] in
            guard let self = self else { return }
            self.scrollSectionToTop()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var contentY: CGFloat = 0
        if let headerView = headerView {
            headerView.frame = CGRect(x: 0, y: 0, width: width, height: headerHeight)
            contentY += headerHeight
        }
        
        var contentHeight = height - safeAreaInsets.top
        if let sectionView = sectionView {
            sectionView.frame = CGRect(x: 0, y: headerHeight, width: width, height: sectionHeight)
            contentY += sectionHeight
            contentHeight -= sectionHeight
        }
        contentSize = CGSize(width: width, height: height + contentY)
        contentCollectionView.frame = CGRect(x: 0, y: contentY, width: width, height: contentHeight)
    }
    
    func scrollToPage(_ index: Int) {
        isDisabledDelegateCallback = true
        contentCollectionView.isArrowMoved = !isArrowMoved
        contentCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        isDisabledDelegateCallback = false
    }
    
    private func scrollSectionToTop() {
        let contentOffset = CGPoint(x: 0, y: headerHeight - safeAreaInsets.top)
        self.isScrollEnabled = false
        UIView.animate(withDuration: 0.20, delay: 0, options: .curveLinear) {
            self.setContentOffset(contentOffset, animated: false)
        } completion: { _ in
            self.isScrollEnabled = true
        }
    }
    
}

extension MainScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(otherGestureRecognizer.view is ContentCollectionView)
    }
}

extension MainScrollView: UIScrollViewDelegate {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if contentOffset.y >= headerHeight - safeAreaInsets.top {
            contentCollectionView.isArrowMoved = true
            isArrowMoved = false
        }
        
        if !isArrowMoved {
            scrollView.contentOffset = CGPoint(x: 0, y: headerHeight - safeAreaInsets.top)
        }
    }
}

extension MainScrollView {
    static let mainViewArrowMovedNotification = Notification.Name(rawValue: "mainViewArrowMoved")
}
