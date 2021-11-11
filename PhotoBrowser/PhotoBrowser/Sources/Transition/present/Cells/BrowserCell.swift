//
//  BrowserCell.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class BrowserCell: UICollectionViewCell {
    
    var resource: ImageResource {
        get { scrollView.resource }
        set { scrollView.resource = newValue }
    }
    
    var startInteractingClosure: (() -> Void)? {
        get { scrollView.startInteractingClosure }
        set { scrollView.startInteractingClosure = newValue }
    }
    
    lazy var scrollView: PreviewImageView = {
        let scrollView = PreviewImageView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 4
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
    }
    
    func endInteractive() {
        scrollView.endInteractive()
    }
}
