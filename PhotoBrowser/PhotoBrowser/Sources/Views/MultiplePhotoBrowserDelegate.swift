//
//  MutiplePhotoBrowserDelegate.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/16.
//

import UIKit

protocol MultiplePhotoBrowserDelegate {
    func mutiplePhotoBrowserViewController(_ controller: MultiplePhotoBrowserViewController, williDsmissToFrame atIndex: Int) -> CGRect?
}

