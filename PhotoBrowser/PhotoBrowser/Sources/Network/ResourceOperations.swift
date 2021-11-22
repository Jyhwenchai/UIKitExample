//
//  ImageOperations.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/19.
//

import UIKit

class ResourceOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
