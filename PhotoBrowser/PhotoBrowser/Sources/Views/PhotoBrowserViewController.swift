//
//  MutiplePhotoBrowserAnimateViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PhotoBrowserViewController: UIViewController {

    var isURLImage: Bool = false
    var selectedIndex: Int = 0
    weak var delegate: PhotoBrowserDelegate?
    
    private var dismissTransitioning: PhotoBrowserDismissTransitioning = PhotoBrowserDismissTransitioning()
    private var followIndex: Bool = true
    
    
    private lazy var resourceDatas: [ResourceData] = []
    private lazy var pendingOperations = ResourceOperations()
    
    private var willEnterForgroundToken: NSObjectProtocol?
    private var didEnterBackgroundToken: NSObjectProtocol?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareData()
        initView()
        initBind()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        transitioningDelegate = dismissTransitioning
    }
    
    func prepareData() {
        guard let delegate = delegate else { return }
        let numberOfCount = delegate.numberOfItems(in: self)
        for index in 0..<numberOfCount {
            let resource = delegate.photoBrowserViewController(self, willShowItemAt: index)
            let resourceData = ResourceData(resource: resource)
            resourceDatas.append(resourceData)
        }
    }
    
    func initView() {
//        previewInfo.toFrame = previewInfo.fromFrame
//        previewInfo.fromFrame = convertImageFrameToPreviewFrame(previewInfo.selectedResource)
        dismissTransitioning.interactiveController = self
        
        view.backgroundColor = .black
        view.addSubview(collectionView)
        
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func initBind() {
        dismissTransitioning.interactiveTransition.interactiveEndClosure = { [weak self] in
            guard let self = self else { return }
            self.unActiveInteractiveCell()
        }
        
        willEnterForgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.loadImagesForOnScreenCells()
            self.resumeAllOperations()
            self.startCurrentDownloadOperationProgressAnimation()
        }
        
        didEnterBackgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.suspendAllOperations()
            self.stopCurrentDownloadOperationProgressAnimation()
        }
    }
  
    deinit {
        willEnterForgroundToken = nil
        didEnterBackgroundToken = nil
        cancelAllOperation()
    }
}

extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resourceDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BrowserCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = cell as! BrowserCell
        let data = resourceDatas[indexPath.item]

        switch data.resource {
        case let resource as RawImage:
            cell.resource = resource
        case let resource as URLImage:
           
            switch data.state {
            case .possible:
                cell.loadingView.textLabel.isHidden = false
                cell.loadingView.textLabel.text = "0%"
                cell.loadingView.startAnimating()
                if !collectionView.isDragging && !collectionView.isDecelerating {
                    startOperation(for: data, at: indexPath)
                }
            case .downloaded: cell.loadingView.stopAnimating()
            case .failed: cell.loadingView.stopAnimating()
            }
            
            cell.scrollView.imageView.alpha = 0
            cell.resource = resource.rawImage
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
                cell.scrollView.imageView.alpha = 1
            }
        default: break

        }

        cell.startInteractingClosure = { [weak self, weak cell] in
            guard let self = self else { return }
            guard let cell = cell else { return }
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
        selectedIndex = Int(targetContentOffset.pointee.x / scrollView.bounds.width)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isURLImage {
            suspendAllOperations()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && isURLImage {
            loadImagesForOnScreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isURLImage {
            loadImagesForOnScreenCells()
            resumeAllOperations()
        }
    }
    
    
    private func createTransitionData() -> TransitionDismissData? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? BrowserCell else {
            return nil
        }
        let resource = cell.resource.image
        let fromFrame = cell.resource.fromFrame
        let toFrame = cell.resource.toFrame
        let transitionData = TransitionDismissData(resource: resource, fromFrame: fromFrame, toFrame: toFrame)
        return transitionData
    }
    
    private func unActiveInteractiveCell() {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? BrowserCell else { return }
        cell.endInteractive()
    }

}

//MARK: - Operations
extension PhotoBrowserViewController {
    func startOperation(for resourceData: ResourceData, at indexPath: IndexPath) {
        switch resourceData.state {
        case .possible: startDownload(for: resourceData, at: indexPath)
        default: print("do nothing")
        }
    }
    
    func startDownload(for resourceData: ResourceData, at indexPath: IndexPath) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        
        let resource = resourceData.resource as! URLImage
        let downloader = NetworkImageOperation(url: resource.url, completion: nil)
        
        downloader.completionBlock = { [weak self] in
            guard let self = self else { return }
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let image = downloader.image {
                    let resourceData = self.resourceDatas[indexPath.item]
                    var urlImage = resourceData.resource as! URLImage
                    urlImage.rawImage = RawImage(image: image, fromFrame: convertImageFrameToPreviewFrame(image), toFrame: urlImage.toFrame)
                    resourceData.resource = urlImage
                    resourceData.state = .downloaded
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        downloader.progressClosure = { [weak self] progress in
            guard let self = self else { return }
            guard progress > 0 else { return }
            DispatchQueue.main.async {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? BrowserCell {
                    cell.loadingView.textLabel.text = "\(Int(progress * 100))%"
                }
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnScreenCells() {
        let indexPathes = collectionView.indexPathsForVisibleItems
        let allOperations = Set(pendingOperations.downloadsInProgress.keys)
        
        var toBeCancelled = allOperations
        let visiblePaths = Set(indexPathes)
        toBeCancelled.subtract(visiblePaths)
        
        var toBeStarted = visiblePaths
        toBeStarted.subtract(allOperations)
        
        for indexPath in toBeCancelled {
            if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            
            pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        }
        
        for indexPath in toBeStarted {
            let resourceData = resourceDatas[indexPath.item]
            startOperation(for: resourceData, at: indexPath)
        }
    }
    
    func cancelAllOperation() {
        for operation in pendingOperations.downloadsInProgress.values where operation.isExecuting {
            operation.cancel()
        }
        pendingOperations.downloadsInProgress.removeAll()
    }
    
    func startCurrentDownloadOperationProgressAnimation() {
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowserCell else { return }
        cell.loadingView.startAnimating()
    }
    
    func stopCurrentDownloadOperationProgressAnimation() {
         let indexPath = IndexPath(item:selectedIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowserCell else { return }
        cell.loadingView.stopAnimating()
    }
    
    
}
