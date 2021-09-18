//
//  Test.swift
//  Test
//
//  Created by 蔡志文 on 2021/9/8.
//

import UIKit

class User {
    var closure: (() -> ())?
    
    func exec() {
        closure?()
    }
}

class Test {
    let queue = DispatchQueue(label: "test")
    
    var obj = NSAttributedString(string: "hello, world")
    let user = User()
   
    var closure: () -> () = {}
    
    init() {
        closure = {
            print(self.obj.string)
        }
        
        user.closure = {
            print(self.obj.string)
        }
    }
    
    func run() {
        let inclosure = {
            print(self)
        }
        queue.async(execute: inclosure)
//
        user.exec()
//        closure()
    }
    
    deinit {
        print("deinit")
    }
}
