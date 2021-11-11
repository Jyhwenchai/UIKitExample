//
//  MutiplePhotoBrowserAnimateViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class MutiplePhotoBrowserAnimateViewController: UIViewController {

    private var dismissTransitioning: PhotoBrowserDismissTransitioning = PhotoBrowserDismissTransitioning()
    private var previewInfo: ResourcePreviewInfo
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)   // fix last item contentOffset error.
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BrowserCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        
        return collectionView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let backButton = UIButton()
    
    init(previewInfo: ResourcePreviewInfo) {
        self.previewInfo = previewInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitioningDelegate = dismissTransitioning
    }
    
//    private lazy var swipeGesture: UISwipeGestureRecognizer = {
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
//        swipeGesture.direction = .down
//        return swipeGesture
//    }()
    func initView() {
        previewInfo.toFrame = previewInfo.fromFrame
        previewInfo.fromFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        dismissTransitioning.interactiveController = self
        
        view.backgroundColor = .black
        var frame = view.bounds
        frame.size.width += 10  // item spacing
        collectionView.frame = frame
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        backButton.frame = CGRect(x: 16, y: 40, width: 44, height: 44)
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        backButton.setImage(UIImage(systemName: "chevron.backward.circle", withConfiguration: config), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.tintColor = .white
        view.addSubview(backButton)
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: previewInfo.selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        
    }
    
    func initBind() {
        dismissTransitioning.interactiveTransition.interactiveEndClosure = { [weak self] in
            guard let self = self else { return }
            self.unActiveInteractiveCell()
        }
    }
    
    @objc func backAction() {
        guard let transitionData = createTransitionData() else { return }
        dismissTransitioning.transitionData = transitionData
        dismiss(animated: true, completion: nil)
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

extension MutiplePhotoBrowserAnimateViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        previewInfo.resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BrowserCell
        let resources = previewInfo.resources
        cell.imageView.image = resources[indexPath.item]
        cell.resourceFrame = convertImageFrameToPreviewFrame(resources[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! BrowserCell
        cell.resourceFrame = convertImageFrameToPreviewFrame(previewInfo.resources[indexPath.item])
        cell.callback = { [weak self] in
            guard let self = self else { return }
            guard let data = self.createTransitionData() else { return }
            self.dismissTransitioning.transitionData = data
            self.dismissTransitioning.interactiveTransition.registerPanGesture(cell.scrollView.panGestureRecognizer)
        }
        cell.cancelCallback = { [weak self] in
            guard let self = self else { return }
            self.dismissTransitioning.interactiveTransition.unregisterPanGesture()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let selectedIndex = scrollView.contentOffset.x / view.bounds.width
        previewInfo.selectedIndex = Int(selectedIndex)
    }
    
    private func createTransitionData() -> TransitionData? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: previewInfo.selectedIndex, section: 0)) as? BrowserCell else { return nil }
        var fromFrame = cell.imageView.frame
        fromFrame.origin.x = -cell.scrollView.contentOffset.x
        if fromFrame.height > UIScreen.main.bounds.height {
            fromFrame.origin.y = -cell.scrollView.contentOffset.y
        }
        let toFrame = previewInfo.toFrame
        let transitionData = TransitionData(resource: previewInfo.selectedResource, fromFrame: fromFrame, toFrame: toFrame)
        return transitionData
    }
    
    private func unActiveInteractiveCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: previewInfo.selectedIndex, section: 0)) as? BrowserCell else { return }
        cell.unActiveInteractive()
    }

}

