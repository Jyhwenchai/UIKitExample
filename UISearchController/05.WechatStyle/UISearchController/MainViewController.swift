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
        
        return searchController
    }()
    
    override func viewDidLoad() {
  
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        view.backgroundColor = .white
//        navigationItem.searchController = searchController
        // 滚动时是否隐藏 searchBar
        navigationItem.hidesSearchBarWhenScrolling = true
        
        // get search bar height
        let size = searchController.searchBar.sizeThatFits(.zero)
        
        // must wrap search bar
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: size.height))
        headerView.addSubview(searchController.searchBar)
        tableView.tableHeaderView = headerView
        
        // 设置为true，当使用 present 跳转页面时，presentingVicewController 为当前控制器否则不是
        definesPresentationContext = true
        
        // 可以修复 searBar 取消按钮点击后的bug
        edgesForExtendedLayout = []
        
        let appearence = UINavigationBarAppearance()
        appearence.backgroundImage = UIColor.white.image(CGSize(width: view.bounds.width, height: 44))
        navigationController?.navigationBar.standardAppearance = appearence
        navigationController?.navigationBar.scrollEdgeAppearance = appearence
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = DetailViewController(colors[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

