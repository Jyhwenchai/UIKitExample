//
//  PresentViewController.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/8.
//

import UIKit

class PresentViewController: UIViewController {
    
    var dataSource: [UIImage] = []
    
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
    
}

extension PresentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
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
        let transitionData = TransitionPresentData(resource: RawImage(image: image, fromFrame: fromFrame, toFrame: .zero))
        let navigationTransitioning = PhotoBrowserPresentTransitioning(transitionData: transitionData)
        
        let controller = PhotoBrowserViewController()
        controller.selectedIndex = indexPath.item
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = navigationTransitioning
        present(controller, animated: true, completion: nil)
    }
    
}


extension PresentViewController: PhotoBrowserDelegate {
    func numberOfItems(in controller: PhotoBrowserViewController) -> Int {
        dataSource.count
    }
    
    func photoBrowserViewController(_ controller: PhotoBrowserViewController, willShowItemAt index: Int) -> Resource {
        let image = dataSource[index]
        var toFrame = CGRect.zero
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell {
            toFrame = cell.contentView.convert(cell.imageView.frame, to: view)
        }
        return RawImage(image: image, fromFrame: convertImageFrameToPreviewFrame(image), toFrame: toFrame)
    }
    
}
