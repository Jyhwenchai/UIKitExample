//
//  CustomSearchBar.swift
//  CustomSearchBar
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

class CustomSearchBar: UISearchBar {

    private var isFirstLayout: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        placeholder = "搜索"
       
        // 影响 光标、取消按钮文本的颜色
        tintColor = .systemPink
        
        setImage(UIImage(named: "icon_search_20x20"), for: .search, state: .normal)
        
        // 调整 icon 的位置
        setPositionAdjustment(UIOffset(horizontal: 150, vertical: 0), for: .search)
        searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: 0)

        // 修改取消按钮文本
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"

        // score Bar, 如果设置 searchBar 到 tableView.tableHeaderView 上那么就不能设置 scopeButtonTitles
//        scopeButtonTitles = ["section1", "section2", "section3"]

        // 移除上下的黑线
        backgroundImage = UIColor.white.image()
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstLayout {
            isFirstLayout.toggle()
            // 设置搜索文本框的外观，
//            setSearchFieldBackgroundImage(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).image(CGSize(width: bounds.width, height: 36)), for: .normal)
        }
    }


}

extension CustomSearchBar: UISearchBarDelegate {
    // 实现 setPositionAdjustment 动画
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.20) {
            self.setPositionAdjustment(.zero, for: .search)
            self.layoutIfNeeded()
        }
        // 消除 cancle button 动画 bug
        setShowsCancelButton(true, animated: true)
       return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.20) {
            self.setPositionAdjustment(UIOffset(horizontal: 150, vertical: 0), for: .search)
            self.layoutIfNeeded()
        }
        setShowsCancelButton(false, animated: true)
    }
    

}
