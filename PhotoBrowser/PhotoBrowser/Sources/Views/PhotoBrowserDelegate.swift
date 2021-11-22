//
//  MutiplePhotoBrowserDelegate.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/16.
//

import UIKit

protocol PhotoBrowserDelegate: NSObjectProtocol {
    
    func numberOfItems(in controller: PhotoBrowserViewController) -> Int
    
    func photoBrowserViewController(_ controller: PhotoBrowserViewController, willShowItemAt index: Int) -> Resource
}

