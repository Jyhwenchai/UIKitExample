//
//  ContentScrollView.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/28.
//

import UIKit

@objc protocol ScrollContainerResponder where Self: UIView {
    func loadScrollContainerResponder() -> UIScrollView
}

@objc protocol PageListViewDelegate {
    @objc optional func pageListViewwWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func pageListViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func pageListViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func pageListViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
}

 @objc protocol PageListViewDataSource {
    func pageListView(_ scrollView: UIScrollView, cellForItemAt index: Int) -> ScrollContainerResponder
}

class PageListView: UICollectionView {
    
    var scrollViewDidScrollHandler: ((UIScrollView) -> Void)?
    
    weak var pageDelegate: PageListViewDelegate?
    weak var pageDataSource: PageListViewDataSource?
    
    var scrollMainScrollViewToSectionTop: (() -> ())?
    var pageCount: Int = 0
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        bounces = false
        dataSource = self
        delegate = self
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        backgroundColor = .white
    }
    
}

extension PageListView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        if let view = pageDataSource?.pageListView(self, cellForItemAt: indexPath.item) {
            view.frame = cell.bounds
            cell.addSubview(view)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageDelegate?.pageListViewwWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageDelegate?.pageListViewDidEndDecelerating?(scrollView)
        adjustmentMainScrollViewContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
       adjustmentMainScrollViewContentOffset()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageDelegate?.pageListViewDidScroll?(scrollView)
        scrollViewDidScrollHandler?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pageDelegate?.pageListViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
 
    private func adjustmentMainScrollViewContentOffset() {
        let currentIndex: Int = Int(contentOffset.x / width)
        guard let cell = cellForItem(at: IndexPath(item: currentIndex, section: 0)),
           let responder = cell.subviews.first as? ScrollContainerResponder else {
               return
        }
        
        let scrollView = responder.loadScrollContainerResponder()
        if scrollView.contentOffset.y > 0 {
            scrollMainScrollViewToSectionTop?()
        }
    }
}
