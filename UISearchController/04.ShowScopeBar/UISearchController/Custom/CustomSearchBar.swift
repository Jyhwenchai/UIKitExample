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
        
        placeholder = "please input color name."
       
        isTranslucent = false
        // search bar 的背景色，似乎并没有什么用
        barTintColor = UIColor.systemOrange
        // search bar 的外观样式，似乎并没有什么用
        searchBarStyle = .minimal
        // search bar 的外观样式，会影响输入文本的颜色
        barStyle = .default
        
        // 影响 光标、取消按钮文本的颜色
        tintColor = .systemPink
        
//        backgroundColor = .white
        // 会覆盖 backgroundColor
//        backgroundImage = UIColor.orange.image()
        showsBookmarkButton = true
        showsSearchResultsButton = true
        
        setImage(UIImage(named: "icon_search_20x20"), for: .search, state: .normal)
        setImage(UIImage(named: "icon_search_clear"), for: .clear, state: .normal)
        // 下面两个只会存在一个
        setImage(UIImage(systemName: "bookmark.fill"), for: .bookmark, state: .normal)
        setImage(UIImage(systemName: "camera.filters"), for: .resultsList, state: .normal)
        
        // 调整 icon 的位置
        setPositionAdjustment(UIOffset(horizontal: 60, vertical: 0), for: .search)
        searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: 0)
        
        // 完成键盘类型
        returnKeyType = .done
        
        // 修改取消按钮文本
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        
        // Score Bar
        scopeButtonTitles = ["section1", "section2", "section3"]
        
        // 控制 score bar 是否显示，只有在 `UISearchController` 的 `automaticallyShowsScopeBar` 为 false 下才有效
//        showsScopeBar = true
        setScopeBarButtonTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
        
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
            setSearchFieldBackgroundImage(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).image(CGSize(width: bounds.width, height: 40)), for: .normal)
            
  
        }
    }
    
}

extension CustomSearchBar: UISearchBarDelegate {
    // 实现 setPositionAdjustment 动画
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIView.animate(withDuration: 0.25) {
            self.setPositionAdjustment(.zero, for: .search)
            self.layoutIfNeeded()
        }
       return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.25) {
            self.setPositionAdjustment(UIOffset(horizontal: 60, vertical: 0), for: .search)
            self.layoutIfNeeded()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("select score bar index \(selectedScope)")
    }
}
