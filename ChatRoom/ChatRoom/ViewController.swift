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
        initView()
        initBind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadDataWhenDataFirstLoad()
    }
    
    @objc func testAction() {
        viewModel.messages.removeAll()
        indicatorView.stopAnimating()
        tableView.tableHeaderView = nil
        tableView.reloadData()
    }
    
    func initView() {
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        
        let button1: VoiceButton = {
            let button = VoiceButton()
            button.button.setImage(UIImage(named: "icon_voice"), for: .normal)
            return button
        }()
        
        let button2: VoiceButton = {
            let button = VoiceButton()
            button.button.setImage(UIImage(named: "icon_expression"), for: .normal)
            return button
        }()
        
        let button3: VoiceButton = {
            let button = VoiceButton()
            button.button.setImage(UIImage(named: "icon_more2"), for: .normal)
            return button
        }()
        
        let contentView1 = VoiceAssessoryContentView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        contentView1.backgroundColor = .blue
        let contentView2 = VoiceAssessoryContentView(frame: CGRect(x: 0, y: 0, width: 0, height: 220))
        contentView2.backgroundColor = .purple
        let contentView3 = VoiceAssessoryContentView(frame: CGRect(x: 0, y: 0, width: 0, height: 240))
        contentView3.backgroundColor = .green
        contentView3.position = .coverInput

        chatInputView.addLeftAccessoryViews {
            InputAccessoryView(titleView: button1, contentView: contentView1)
        }
        chatInputView.addRightAccessoryViews {
            InputAccessoryView(titleView: button2, contentView: contentView2)
            InputAccessoryView(titleView: button3, contentView: contentView3)
        }
    }
    
    func initBind() {
        viewModel.addNewMessageCompleteHandler = { [weak self] in
            guard let self = self else { return }
            self.layoutUIWhenReceiveMessage()
        }
        
        viewModel.loadHistoryMessageCompleteHandler = { [weak self] insertCount in
            guard let self = self else { return }
            self.reloadDataWhenLoadingPage()
        }
    }
    
    override func inputViewConfirmInput(_ text: String) {
        // keyboard return event
        viewModel.addMessage(text)
    }
    
    override func loadingHistoryMessages(completion: (Bool) -> Void) {
        // load history message here, if `hasHistoryMessage` return true
        self.viewModel.loadMoreMessage()
        // return true, if loading successful. otherwise return false
        completion(true)
    }
    
    override func hasHistoryMessage() -> Bool {
        return true
//        return false
    }
    
}


extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell") as! TextMessageCell
        let model = viewModel.messages[indexPath.item]
        cell.configureCellWith(model: model)
        return cell
    }
    
}

extension ViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(at: indexPath)
    }
}
