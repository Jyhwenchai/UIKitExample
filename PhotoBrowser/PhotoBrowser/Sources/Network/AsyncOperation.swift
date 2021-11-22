//
//  AsyncOperation.swift
//  PhotoBrowser
//
//  Created by 蔡志文 on 2021/11/17.
//

import Foundation

class AsyncOperation: Operation {
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keypath: String {
            return "is\(rawValue.capitalized)"
        }
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keypath)
            willChangeValue(forKey: state.keypath)
        }
        didSet {
            didChangeValue(forKey:  oldValue.keypath)
            didChangeValue(forKey: state.keypath)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        main()
        state = .executing
    }
}
