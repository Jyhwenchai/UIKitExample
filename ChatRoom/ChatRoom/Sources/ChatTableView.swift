//
//  ChatTableView.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/21.
//

import UIKit

class ChatTableView: UITableView {

    var shouldResetContentOffset: Bool = false
    
    override var contentSize: CGSize {
        willSet {
            if contentOffset.y > 0 { return }
            if !shouldResetContentOffset { return }
            contentOffset = CGPoint(x: 0, y: newValue.height - contentSize.height + contentOffset.y)
        }
    }
}
