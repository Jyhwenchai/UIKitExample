//
//  ImageResource.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/11.
//

import UIKit

struct ImageResource {
    var type: ImageResourceType = .url("")
    var fromFrame: CGRect = .zero
    var toFrame: CGRect = .zero
}

extension ImageResource {
    static var empty: ImageResource { .init() }
}
