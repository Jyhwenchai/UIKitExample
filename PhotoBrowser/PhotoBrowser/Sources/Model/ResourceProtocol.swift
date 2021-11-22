//
//  ResourceProtocol.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/11.
//

import UIKit

protocol Resource {
    var fromFrame: CGRect { get set }
    var toFrame: CGRect { get set }
}

struct RawImage: Resource {
    var image: UIImage
    var fromFrame: CGRect
    var toFrame: CGRect
}

extension RawImage {
    static var empty: RawImage { .init(image: UIImage(), fromFrame: .zero, toFrame: .zero) }
}

struct URLImage: Resource {
    var url: URL
    var fromFrame: CGRect
    var toFrame: CGRect
    var rawImage: RawImage = .empty 
}

enum ResourceType {
    case rawImage, urlImage
}

enum ResourceDataState {
    case possible, downloaded, failed
}

class ResourceData {
    var resource: Resource
    var state: ResourceDataState = .possible
    
    init(resource: Resource) {
        self.resource = resource
    }
}
