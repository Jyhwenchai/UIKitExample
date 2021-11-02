//
//  SectionFixedViewController.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/28.
//

import UIKit

private let fixedSectionMarginOffsetY: CGFloat = 200.0

class SectionFixedViewController: UIViewController, UIScrollViewDelegate {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var sectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width, height: 1500)
        
        sectionView.frame = CGRect(x: 0, y: fixedSectionMarginOffsetY, width: view.width, height: 35)
        scrollView.addSubview(sectionView)
    }
    
    let floatMargin: CGFloat = 40.0 // 悬停位置
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let safeAreaTop = scrollView.safeAreaInsets.top
        
        // 如果希望一直固定位置, 则不需要加判断
        //        sectionView.y = contentOffsetY + safeAreaTop + floatMargin
        
        
        let maxOffsetY = fixedSectionMarginOffsetY - safeAreaTop - floatMargin
        let sectionOffsetY = min(maxOffsetY, contentOffsetY)
        if sectionOffsetY == maxOffsetY {
            sectionView.y = contentOffsetY + safeAreaTop + floatMargin
        }
        
    }
    
    @IBAction func gotoNestingView1(_ sender: Any) {
        let controller = NestingScrollViewController()
        show(controller, sender: self)
    }
}
