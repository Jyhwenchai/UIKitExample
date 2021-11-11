//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

/**
 1. 预览图片(一般图片，长图，gif图，webp)
 2. 视频
 */

/**
 a images/selectedIndex/selectedImageFromFrame/selectedImageToFrame
 */
import UIKit

class ViewController: UIViewController {
    
    
    private var navigationTransitioning: PhotoBrowserTransitioning?
    
    
    var dataSource: [UIImage] = []
    private var selectedResourcesInfo: [ResourcePreviewInfo] = []
    
    //MARK: - Views
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
        flowLayout.minimumInteritemSpacing = 1
        let itemWidth = floor((UIScreen.main.bounds.width - flowLayout.minimumInteritemSpacing * 3) / 4.0)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "\(ImageCell.self)")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        initBarItems()
        initImageData()
    }
    

    private func initView() {
        title = "Photo Browser"
        view.backgroundColor = UIColor.black
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func initBarItems() {
        let appearence = navigationController!.navigationBar.standardAppearance
        appearence.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearence
        navigationController?.navigationBar.compactAppearance = appearence
        navigationController?.navigationBar.scrollEdgeAppearance = appearence
    }
    
    private func initImageData() {
        //构造图片数据
        for index in 0...111 {
            let at = index % 13 + 1
            
            let pathString = String(format: "Expression%.2d", at)
            let path = Bundle.main.path(forResource: pathString, ofType: "jpeg")
            
            guard let imgPath = path else { return }
            let img = UIImage(contentsOfFile: imgPath)!
            dataSource.append(img)
        }
    }
    
    @objc func previewAction() {
//        if selectedResourcesInfo.count == 0 { return }
//        let indexPath = selectedResourcesInfo.first!.indexPath
//        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
//        updateTransitioningConfigure(with: cell, at: indexPath)
//
//        let controller = PhotoBrowseViewController()
//        controller.dataSource = selectedResourcesInfo
//        controller.updateTransitionImageClosure = { index in
//            let indexPath = IndexPath(item: index, section: 0)
//            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
//            self.updateTransitioningConfigure(with: cell, at: indexPath)
//        }
//        navigationController?.delegate = navigationTransitioning
//        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ImageCell.self)", for: indexPath) as! ImageCell
        cell.imageView.image = dataSource[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        let fromFrame = cell.contentView.convert(cell.imageView.frame, to: view)
        let image = dataSource[indexPath.item]
        let previewInfo = ResourcePreviewInfo(resources: [image], selectedIndex: 0, fromFrame: fromFrame)
//        let controller = SinglePhotoBrowserViewController(previewInfo: previewInfo)
//        let navigationTransitioning = PhotoBrowserTransitioning(previewInfo: previewInfo)
//        let controller = SinglePhotoBrowserAnimateViewController(navigationTransitioning: navigationTransitioning)
        
        let navigationTransitioning = PhotoBrowserPushTransitioning(previewInfo: previewInfo)
        let controller = MutiplePhotoBrowserAnimateViewController(previewInfo: previewInfo)
//        controller.modalPresentationStyle = .fullScreen
//        controller.transitioningDelegate = navigationTransitioning
//        present(controller, animated: true, completion: nil)
        navigationController?.delegate = navigationTransitioning
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func updateTransitioningConfigure(with cell: ImageCell, at indexPath: IndexPath) {
//        navigationTransitioning.transitionImage = dataSource[indexPath.item]
//        navigationTransitioning.transitionBeforeFrame = cell.contentView.convert(cell.imageView.frame, to: view)
//        navigationTransitioning.transitionAfterFrame = getTransitionAfterFrame(image: navigationTransitioning.transitionImage!)
    }
    

    
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}

