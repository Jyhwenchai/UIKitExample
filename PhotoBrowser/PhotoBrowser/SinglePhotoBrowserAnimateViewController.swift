//
//  SinglePhotoBrowserAnimateViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

class SinglePhotoBrowserAnimateViewController: UIViewController {

    private let navigationTransitioning: PhotoBrowserTransitioning
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let backButton = UIButton()
    
    init(navigationTransitioning: PhotoBrowserTransitioning) {
        self.navigationTransitioning = navigationTransitioning
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var previewInfo = navigationTransitioning.previewInfo
        let fromFrame = previewInfo.toFrame
        previewInfo.toFrame = previewInfo.fromFrame
        previewInfo.fromFrame = fromFrame
        
        navigationTransitioning.drivenInteraction = SwipeInteractionTransition(previewInfo: previewInfo, swipeController: self)
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        print("will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        print("will disappear")
    }
    
    func initView() {
        view.backgroundColor = .black
        let previewInfo = navigationTransitioning.previewInfo
        imageView.frame = previewInfo.toFrame
        imageView.image = previewInfo.resources[previewInfo.selectedIndex]
        view.addSubview(imageView)
        
        backButton.frame = CGRect(x: 16, y: 40, width: 44, height: 44)
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        backButton.setImage(UIImage(systemName: "chevron.backward.circle", withConfiguration: config), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.tintColor = .white
        view.addSubview(backButton)
    }
 
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        backButton.isHidden = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backButton.isHidden = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backButton.isHidden = false
    }

}
