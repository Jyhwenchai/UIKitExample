//
//  ResourceInfo.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/4.
//

import UIKit

struct ResourcePreviewInfo {
    var resources: [UIImage]
    var selectedIndex: Int 
    var fromFrame: CGRect
    var toFrame: CGRect = .zero // default to frame
    
    var selectedResource: UIImage {
        resources[selectedIndex]
    }
    
}

