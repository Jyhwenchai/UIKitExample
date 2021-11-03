//
//  ContentListCell.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/10/29.
//

import UIKit

class ContentListCell: UICollectionViewCell {
   
    private var contentCanScrollToken: NSObjectProtocol? = nil
    
    var isArrowMoved: Bool = false
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        contentCanScrollToken = NotificationCenter.default.addObserver(forName: ContentListCell.contentViewArrowMovedNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.isArrowMoved = true
        }
        addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    deinit {
        contentCanScrollToken = nil
    }
}

extension ContentListCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
      
        cell.textLabel?.text = "page \(tag): table view cell \(indexPath.row)"
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isArrowMoved {
            scrollView.contentOffset = .zero
        }
        
        if scrollView.contentOffset.y <= 0 {
            // 通知主视图可以移动了
            NotificationCenter.default.post(name: MainScrollView.mainViewArrowMovedNotification, object: nil)
            isArrowMoved = false
        }
    }
}

extension ContentListCell {
    static let contentViewArrowMovedNotification = Notification.Name(rawValue: "contentViewArrowMoved")
}
