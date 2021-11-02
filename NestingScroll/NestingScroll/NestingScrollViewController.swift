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
        scrollView.contentDelegate = self
        scrollView.pageCount = sectionView.titles.count
        return scrollView
    }()
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }

    func initView() {
        view.addSubview(mainScrollView)
    }
    

}

extension NestingScrollViewController: MainScrollViewDelegate {
    
    func contentScrollViewDidScroll(_ scrollView: UIScrollView) {
        sectionView.bindContentDidScroll(scrollView.contentOffset)
    }
    
    func contentScrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sectionView.bindContentWillBeginDraging(scrollView.contentOffset)
    }
    
    func contentScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sectionView.bindContentDidEndScroll(scrollView.contentOffset)
    }
    
    func contentScrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        sectionView.bindContentScrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
}

extension NestingScrollViewController: SectionViewDelegate {
    func sectionView(_ sectionView: SectionView, didSelectedIndex index: Int) {
        mainScrollView.scrollToPage(index)
    }
}
