//
//  CustomSearchController.swift
//  CustomSearchController
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

class CustomSearchController: UISearchController {

    private lazy var customSearchBar = CustomSearchBar()
    
    override var searchBar: UISearchBar {
        customSearchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // 如果希望自己控制 score bar 的显示，则将此属性设置为 false，否则系统会自动显示或隐藏
//        automaticallyShowsScopeBar = false
    }
    

}
