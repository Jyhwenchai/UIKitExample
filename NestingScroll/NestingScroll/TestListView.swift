//
//  TestListView.swift
//  NestingScroll
//
//  Created by 蔡志文 on 2021/11/3.
//

import UIKit

class TestListView: UIView {
    
    weak var contentListScrollListener: ContentListScrollListener?
    
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
        addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
}

extension TestListView: UITableViewDataSource, UITableViewDelegate {
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
        contentListScrollListener?.contentListDidScroll(scrollView)
    }
    
}

extension TestListView: ScrollContainerResponder {
    func loadScrollContainerResponder() -> UIScrollView {
        tableView
    }
}
