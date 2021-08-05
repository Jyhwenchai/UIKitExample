//
//  ViewController.swift
//  UISearchController
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

private let cellIdentifier = "ColorCell"

class MainViewController: UITableViewController {

    let colors: [Color] =  ColorStore.default.colors
    
    let resultsController = ResultsTableViewController()
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        // 默认当搜索内容为空的时候不显示搜索结果页面，如果希望总是显示搜索结果页可以设置此属性
        searchController.showsSearchResultsController = true
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.searchController = searchController
        // 滚动时是否隐藏 searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
    }


}

extension MainViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        colors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ColorCell
        let color = colors[indexPath.row]
        cell.nameLabel.text = color.name
        cell.nameLabel.textColor = color.value
        cell.colorView.backgroundColor = color.value
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}
