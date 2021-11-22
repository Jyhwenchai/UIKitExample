//
//  PresentURLImageViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/22.
//

import UIKit

class PresentURLImageViewController: UIViewController {
    
    var dataSource: [UIImage] = []
    var urlImages: [URL] = []
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
        for index in 0...1 {
            let id = index * index + 1
            let width: Int = index / 2 == 0 ? 400 : 500
            let height: Int = index / 3 == 0 ? 400 : 500
            let url = "https://picsum.photos/id/\(id)/\(width * 5)/\(height * 5)"
            let image = UIImage(data: try! Data(contentsOf: URL(string: url)!))!
            dataSource.append(image)
            urlImages.append(URL(string: url)!)
        }
    }
    
}

extension PresentURLImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
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
        let previewInfo = ResourcePreviewInfo(resources: dataSource, selectedIndex: indexPath.item, fromFrame: fromFrame)
        
        let transitionData = TransitionData(resource: previewInfo.selectedResource, fromFrame: fromFrame, toFrame: .zero)
        let navigationTransitioning = PhotoBrowserPresentTransitioning(transitionData: transitionData)
        let controller = PhotoBrowserViewController(previewInfo: previewInfo)
        controller.isURLImage = true
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = navigationTransitioning
        present(controller, animated: true, completion: nil)
    }
    
    private func updateTransitioningConfigure(with cell: ImageCell, at indexPath: IndexPath) {
    }
    
}


extension PresentURLImageViewController: PhotoBrowserDelegate {
    func numberOfItems(in controller: PhotoBrowserViewController) -> Int {
        dataSource.count
    }
    
    func photoBrowserViewController(_ controller: PhotoBrowserViewController, willShowItemAt index: Int) -> Resource {
        var toFrame = CGRect.zero
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell {
            toFrame = cell.contentView.convert(cell.imageView.frame, to: view)
        }
        return URLImage(url: urlImages[index], fromFrame: .zero, toFrame: toFrame)
    }
    
}
