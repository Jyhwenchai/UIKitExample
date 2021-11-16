//
//  ResourceProtocol.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/11.
//

import UIKit

enum ImageResourceType {
    case raw(UIImage)
    case url(String)
}

enum VideoResourceType {
   case url(String)
}
