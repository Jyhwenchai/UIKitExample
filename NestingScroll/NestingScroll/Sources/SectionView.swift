//
//  SectionView.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/29.
//

import UIKit

@objc protocol SectionViewDelegate {
    @objc optional func sectionView(_ sectionView: SectionView, didSelectedIndex index: Int)
}

class TitleCell: UICollectionViewCell {
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
    }
    
    
}



private  let calculateLabel: UILabel = UILabel()

class SectionView: UICollectionView {
    
    var animator: SectionAnimator? = nil
    weak var contentDelegate: SectionViewDelegate?
    var selectedIndex: Int = 0
    var lineSelectedIndex: Int = 0
    
    var titles: [String] = [] {
        didSet {
            itemsSize.removeAll()
            for title in titles {
                calculateLabel.text = title
                calculateLabel.font = UIFont.systemFont(ofSize: 15)
                var size = calculateLabel.sizeThatFits(.zero)
                size.width = ceil(size.width)
                size.height = 35
                itemsSize.append(size)
            }
            reloadData()
        }
    }
    
    private var itemsSize: [CGSize] = []
    private var firstLayoutDidComplete: Bool = false
    
    var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    init(frame: CGRect = .zero) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        dataSource = self
        delegate = self
        backgroundColor = .white
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(TitleCell.self, forCellWithReuseIdentifier: "cell")
        backgroundColor = .white
        addSubview(lineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstLayoutDidComplete {
            return
        }
        
        firstLayoutDidComplete = true
        var offsetX: CGFloat = 0
        var selectedItemSize: CGSize = .zero
        for (index, size) in itemsSize.enumerated() {
            if index == selectedIndex {
                selectedItemSize = size
                break
            } else {
                offsetX += size.width
                offsetX += 15
            }
        }
        let lineWidth: CGFloat = 15
        lineView.frame = CGRect(x: offsetX + (selectedItemSize.width - lineWidth) / 2, y: height - 3, width: 15, height: 3)
    }

}


extension SectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TitleCell
        cell.textLabel.text = titles[indexPath.item]
        cell.textLabel.textColor = selectedIndex == indexPath.item ? .systemRed : .darkText
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemsSize[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex != indexPath.item {
            let offset = CGPoint(x: CGFloat(indexPath.item) * width, y: 0)
            updateSelectedIndexWithOffset(offset)
            updateLineViewPositionWithOffset(offset, animated: true)
            contentDelegate?.sectionView?(self, didSelectedIndex: indexPath.item)
        }
    }
    
}

extension SectionView {
    
    func bindContentWillBeginDraging(_ offset: CGPoint) {
    }
    
    func bindContentDidEndScroll(_ offset: CGPoint) {
    }
    
    func bindContentScrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        updateSelectedIndexWithOffset(scrollView.contentOffset)
        updateLineViewPositionWithOffset(scrollView.contentOffset, animated: false)
    }
    
    func bindContentDidScroll(_ offset: CGPoint) {
        updateSelectedIndexWithOffset(offset)
        updateLineViewPositionWithOffset(offset, animated: false)
    }
    

    func updateSelectedIndexWithOffset(_ offset: CGPoint) {
        
        let currentIndex = selectedIndex
        let diffValue = ceil(offset.x - CGFloat(currentIndex) * width)
        
        var willSelectedIndex = currentIndex
        if abs(diffValue) > ceil(width / 2)   {
            var offsetItem: Int = abs(Int(diffValue / width))
            let remain = abs(diffValue) - CGFloat(offsetItem) * width - ceil(width / 2)
            offsetItem = remain >= 0 ? offsetItem + 1 : offsetItem
            if diffValue > 0 {
                willSelectedIndex = currentIndex + offsetItem
            } else {
                willSelectedIndex = currentIndex - offsetItem
            }
        }
        
        if selectedIndex != willSelectedIndex {
            selectedIndex = willSelectedIndex
            scrollToItem(at: IndexPath(item: willSelectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            reloadData()
        }
    }
    
    func updateLineViewPositionWithOffset(_ offset: CGPoint, animated: Bool) {
        
        let currentIndex = lineSelectedIndex
        let diffValue = ceil(offset.x - CGFloat(currentIndex) * width)
        var targetIndex = currentIndex
        
        if diffValue == 0 { return }

        var offsetItem: Int = abs(Int(diffValue / width))
        let remain = abs(diffValue) - CGFloat(offsetItem) * width
        offsetItem = remain > 0 ? offsetItem + 1 : offsetItem
        if diffValue > 0 {
            targetIndex = currentIndex + offsetItem
        } else {
            targetIndex = currentIndex - offsetItem
        }

        let currentItemX = getItemStartPosition(currentIndex)
        let currentSize = itemsSize[currentIndex]
        let targetItemX = getItemStartPosition(targetIndex)
        let targetSize = itemsSize[targetIndex]
        
        let distance = ceil((targetItemX + targetSize.width / 2) - (currentItemX + currentSize.width / 2))
       
        if animated {
            animator = SectionAnimator()
            animator?.progressClosure = { [weak self] percent in
                guard let self = self else { return }
                self.lineView.centerX = currentItemX + currentSize.width / 2 + distance * percent
            }
            animator?.completedClosure = { [weak self] in
                guard let self = self else { return }
                self.animator = nil
            }
            animator?.start()
        } else {
            let centerOffsetX = abs(diffValue) * distance / (width * CGFloat(offsetItem))
            let centerX = currentItemX + currentSize.width / 2 + centerOffsetX
            lineView.centerX = centerX
        }

        lineSelectedIndex = Int(offset.x / width)
    }
    
    func getItemStartPosition(_ selectedIndex: Int) -> CGFloat {
        var offset: CGFloat = 0
        for (index, size) in itemsSize.enumerated() {
            if index == selectedIndex {
                break
            } else {
                offset += size.width
                offset += 15
            }
        }
        return offset
    }
}
