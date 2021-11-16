//
//  MutiplePhotoBrowserAnimateViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class MultiplePhotoBrowserViewController: UIViewController {

    private var dismissTransitioning: PhotoBrowserDismissTransitioning = PhotoBrowserDismissTransitioning()
    private var previewInfo: ResourcePreviewInfo
    private var followIndex: Bool = true
    
    var delegate: MultiplePhotoBrowserDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        // below four line code set then spacing between items to 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)   // fix last item contentOffset error.
        var frame = view.bounds
        frame.size.width += 20
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BrowserCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        
        return collectionView
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

        initView()
        initBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitioningDelegate = dismissTransitioning
    }
    
    func initView() {
        previewInfo.toFrame = previewInfo.fromFrame
        previewInfo.fromFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        dismissTransitioning.interactiveController = self
        
        view.backgroundColor = .black
        view.addSubview(collectionView)
        
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
    
    deinit {
        print("deinit: \(self)")
    }
    
}

extension MultiplePhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        previewInfo.resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BrowserCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! BrowserCell
        let resources = previewInfo.resources
        let fromFrame = convertImageFrameToPreviewFrame(resources[indexPath.item])
        cell.resource = ImageResource(type: .raw(resources[indexPath.item]), fromFrame: fromFrame, toFrame: previewInfo.toFrame)
        cell.startInteractingClosure = { [weak self] in
            guard let self = self else { return }
            guard let data = self.createTransitionData() else { return }
            self.dismissTransitioning.transitionData = data
            self.dismissTransitioning.interactiveTransition.registerPanGesture(cell.scrollView.panGestureRecognizer)
            self.dismissTransitioning.interactiveTransition.startDismissTransition()
        }
        
        cell.dismissClosure = { [weak self] in
            guard let self = self else { return }
            guard let transitionData = self.createTransitionData() else { return }
            self.dismissTransitioning.transitionData = transitionData
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let selectedIndex = targetContentOffset.pointee.x / scrollView.bounds.width
        previewInfo.selectedIndex = Int(selectedIndex)
    }
    
    private func createTransitionData() -> TransitionData? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: previewInfo.selectedIndex, section: 0)) as? BrowserCell else {
            return nil
        }
        let fromFrame = cell.resource.fromFrame
        let toFrame: CGRect = delegate?.mutiplePhotoBrowserViewController(self, williDsmissToFrame: previewInfo.selectedIndex) ?? previewInfo.toFrame
        let transitionData = TransitionData(resource: previewInfo.selectedResource, fromFrame: fromFrame, toFrame: toFrame)
        return transitionData
    }
    
    private func unActiveInteractiveCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: previewInfo.selectedIndex, section: 0)) as? BrowserCell else { return }
        cell.endInteractive()
    }

}
