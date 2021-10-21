//
//  ViewController.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/18.
//

import UIKit

class ViewController: ChatRoomViewController {

    let viewModel: ChatViewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // test item
        let barItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(testAction))
        navigationItem.rightBarButtonItems = [barItem]
    }
    
    @objc func testAction() {
        tableView.selectRow(at: IndexPath(row: 10, section: 0), animated: false, scrollPosition: .top)
    }
    
    override func initView() {
        super.initView()
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
    }
    
    override func initBind() {
        super.initBind()
        viewModel.receiveNewMessageHandler = { [weak self] in
            guard let self = self else { return }
            self.layoutUIWhenReceiveMessage()
        }
        
        viewModel.loadHistoryMessageCompleteHandler = { [weak self] insertCount in
            guard let self = self else { return }
            self.layoutUIWhenLoadPageCompletion(insertCount: insertCount)
        }
    }
    
    override func inputViewConfirmInput(_ text: String) {
        viewModel.addMessage(text)
    }
    
    override func startLoadHistoryMessage() {
        self.viewModel.loadMoreMessage()
        print("load more data")
    }
    
    override func hasHistoryMessage() -> Bool {
        return viewModel.messages.count > 10
    }
    
}


extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell") as! TextMessageCell
        let model = viewModel.messages[indexPath.item]
        cell.direction = model.direction
        cell.messageView.textView.text = model.text
        cell.contentSize = model.contentSize
        return cell
    }
    
}

extension ViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(at: indexPath)
    }
}
