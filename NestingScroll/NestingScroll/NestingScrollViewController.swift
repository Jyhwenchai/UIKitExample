//
//  ViewController.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/28.
//

import UIKit


class NestingScrollViewController: UIViewController {
    
    lazy var sectionView: SectionView = {
        let view = SectionView()
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.titles = ["China", "America", "Japan", "United Kingdom", "Canada", "South Korea", "Spain"]
        view.contentDelegate = self
        return view
    }()
   
    lazy var mainScrollView: MainScrollView = {
        let scrollView = MainScrollView(frame: view.bounds)
        let headerView = UIView()
        headerView.backgroundColor = .systemYellow
        scrollView.headerView = headerView
        scrollView.headerHeight = 200
        scrollView.sectionView = sectionView
        scrollView.sectionHeight = 35
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentCollectionView.pageDelegate = self
        scrollView.contentCollectionView.pageDataSource = self
        scrollView.pageCount = sectionView.titles.count
        return scrollView
    }()
    
    lazy var listViews: [TestListView] = {
        var views: [TestListView] = []
        for i in 0..<sectionView.titles.count {
            let view = TestListView()
            view.tag = i
            view.contentListScrollListener = mainScrollView
            views.append(view)
        }
        return views
    }()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }

    func initView() {
        view.addSubview(mainScrollView)
    }
    
    deinit {
        print("deinit: \(self)")
    }

}

extension NestingScrollViewController: PageListViewDelegate {
    
    func pageListViewwWillBeginDragging(_ scrollView: UIScrollView) {
        sectionView.bindContentWillBeginDraging(scrollView.contentOffset)
    }
    
    func pageListViewDidScroll(_ scrollView: UIScrollView) {
        sectionView.bindContentDidScroll(scrollView.contentOffset)
    }
    
    func pageListViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sectionView.bindContentDidEndScroll(scrollView.contentOffset)
    }
    
    func pageListViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        sectionView.bindContentScrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension NestingScrollViewController: SectionViewDelegate {
    func sectionView(_ sectionView: SectionView, didSelectedIndex index: Int) {
        mainScrollView.scrollToPage(index)
    }
}

extension NestingScrollViewController: PageListViewDataSource {
    func pageListView(_ scrollView: UIScrollView, cellForItemAt index: Int) -> ScrollContainerResponder {
       listViews[index]
    }
}
