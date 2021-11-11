//
//  SinglePhotoBrowseViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

class SinglePhotoBrowserViewController: UIViewController {
    
    private let previewInfo: ResourcePreviewInfo
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    func initView() {
        view.backgroundColor = .systemGray
        imageView.frame = previewInfo.toFrame
        imageView.image = previewInfo.resources[previewInfo.selectedIndex]
        view.addSubview(imageView)
    }

}
