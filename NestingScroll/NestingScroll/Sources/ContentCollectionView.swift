//
//  ContentScrollView.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/28.
//

import UIKit

class ContentCollectionView: UICollectionView {
    
    var scrollViewWillBeginDraggingHandler: ((UIScrollView) -> Void)?
    var scrollViewDidEndDeceleratingHandler: ((UIScrollView) -> Void)?
    var scrollViewDidScrollHandler: ((UIScrollView) -> Void)?
    var scrollViewWillEndDraggingHandler: ((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void)?
    
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
        register(ContentListCell.self, forCellWithReuseIdentifier: "cell")
        backgroundColor = .white
    }
    

}

extension ContentCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ContentListCell
        cell.tag = indexPath.item
        cell.tableView.reloadData()
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
        scrollViewWillBeginDraggingHandler?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDeceleratingHandler?(scrollView)
        adjustmentMainScrollViewContentOffset()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollHandler?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDraggingHandler?(scrollView, velocity, targetContentOffset)
    }
 
    func adjustmentMainScrollViewContentOffset() {
        let currentIndex: Int = Int(contentOffset.x / width)
        if let cell = cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ContentListCell {
            let listOffset = cell.tableView.contentOffset
            if listOffset.y > 0 {
                scrollMainScrollViewToSectionTop?()
            }
        }
    }
}
