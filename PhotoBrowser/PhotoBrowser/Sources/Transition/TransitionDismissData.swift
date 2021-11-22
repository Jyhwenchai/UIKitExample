//
//  TransitionData.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/10.
//

import UIKit

struct TransitionDismissData {
    var resource: UIImage
    var fromFrame: CGRect
    var toFrame: CGRect
}

struct TransitionPresentData {
    var resource: Resource
    var fromFrame: CGRect {
        resource.fromFrame
    }
    var toFrame: CGRect {
        resource.toFrame
    }
}
