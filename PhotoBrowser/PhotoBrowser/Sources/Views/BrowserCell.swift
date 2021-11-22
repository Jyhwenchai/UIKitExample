//
//  BrowserCell.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class BrowserCell: UICollectionViewCell {
    
    let loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.lineWidth = 2
        loadingView.font = UIFont.systemFont(ofSize: 7)
        return loadingView
    }()
    
    var resource: RawImage {
        get { scrollView.resource }
        set { scrollView.resource = newValue }
    }
    
    var startInteractingClosure: (() -> Void)?
    {
        get { scrollView.startInteractingClosure }
        set { scrollView.startInteractingClosure = newValue }
    }
    
    var dismissClosure: (() -> Void)?
    {
        get { scrollView.dismissClosure }
        set { scrollView.dismissClosure = newValue }
    }
    
    lazy var scrollView: PreviewImageView = {
        let scrollView = PreviewImageView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 4
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        contentView.addSubview(loadingView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        loadingView.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        loadingView.center = contentView.center
    }
    
    func endInteractive() {
        scrollView.endInteractive()
    }
}
