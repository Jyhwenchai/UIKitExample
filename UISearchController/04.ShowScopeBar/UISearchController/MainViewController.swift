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
    lazy var searchController: CustomSearchController = {
        let searchController = CustomSearchController(searchResultsController: resultsController)
        
        searchController.searchResultsUpdater = self
        // 默认当搜索内容为空的时候不显示搜索结果页面，如果希望总是显示搜索结果页可以设置此属性
        searchController.showsSearchResultsController = true
        
        // 如果想在主页显示 scoreBar 这里必须设置，如果仅在自定义的 Search Bar 中设置，则会出现首次不显示 scopeBar 的问题
        // 但是如果设置为 true 虽然在此主页可以正常显示 scopeBar，但是上滑时搜索框会出现bug，所以应该避免scopeBar 在主页显示，应该只显示 scoreBar 在搜索结果页。
//        searchController.searchBar.showsScopeBar = true
        
        // 是否隐藏导航栏
        searchController.hidesNavigationBarDuringPresentation = true
        
        // 未知
//        searchController.obscuresBackgroundDuringPresentation = false
        
        // 定义 present 的控制器是当前控制器
        definesPresentationContext = true
        
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.searchController = searchController
        // 滚动时是否隐藏 searchBar
//        navigationItem.hidesSearchBarWhenScrolling = true
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

