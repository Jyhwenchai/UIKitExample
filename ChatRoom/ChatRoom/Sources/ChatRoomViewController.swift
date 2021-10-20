//
//  ChatRoomViewController.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/20.
//

import UIKit

private let tabBarAdditionHeight: CGFloat = ScreenAppearence.bottomSafeAreaHeight

class ChatRoomViewController: UIViewController {

    let chatInputView: ChatInputView = ChatInputView()
    
    var keyboardFrame: CGRect = .zero
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        initNav()
        initView()
        initBind()
        initNotification()
    }
    
    func initNav() {
        let appearance = navigationController!.navigationBar.standardAppearance
        appearance.backgroundColor = UIColor(hex: "f1f1f1")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func initView() {
        view.backgroundColor = UIColor(hex: "f1f1f1")
        
        let inputViewMinHeight = chatInputView.minHeight
        var frame = view.bounds
        frame.size.height = view.height - inputViewMinHeight - tabBarAdditionHeight
        tableView.frame = frame
        view.addSubview(tableView)
        
        chatInputView.frame = CGRect(x: 0, y: view.height - inputViewMinHeight - tabBarAdditionHeight, width: view.width, height: inputViewMinHeight)
        view.addSubview(chatInputView)
    }

    func initBind() {

        chatInputView.confirmInputClosure = { [weak self] text in
            guard let self = self else { return }
            
            let maxOffset = self.keyboardFrame.height - tabBarAdditionHeight
            // reset inputView frame and correct tableView offset position
            UIView.animate(withDuration: 0.20, delay: 0, options: .curveLinear) {
                self.chatInputView.y = self.keyboardFrame.minY - self.chatInputView.minHeight
                self.chatInputView.height = self.chatInputView.minHeight
                self.chatInputView.layoutIfNeeded()
                if abs(self.tableView.y) > abs(maxOffset) {
                    self.tableView.y = -maxOffset
                }
            }
            self.inputViewConfirmInput(text)
        }
        
        chatInputView.updateFrameClosure = { [weak self] height in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.20, delay: 0, options: .curveLinear) {
                self.chatInputView.y -= (height - self.chatInputView.height)
                self.chatInputView.height = height
                self.chatInputView.layoutIfNeeded()
                self.layoutTableView(with: self.keyboardFrame)
            }
        }
    }
    

    
    private var keyboardWillShowToken: NSObjectProtocol?
    private var keyboardWillHideToken: NSObjectProtocol?

    func initNotification() {
        
        self.keyboardWillShowToken = NotificationCenter.default.addObserver(forName: UIViewController.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            if self.keyboardFrame == .zero {
                self.scrollToBottom()
            }
            self.keyboardFrame = notification.keyboardFrame
            self.chatInputView.frame = CGRect(x: 0, y: self.keyboardFrame.minY - self.chatInputView.height, width: self.chatInputView.width, height: self.chatInputView.height)
            self.layoutTableView(with: self.keyboardFrame)
        }
        
        self.keyboardWillHideToken = NotificationCenter.default.addObserver(forName: UIViewController.keyboardWillHideNotification, object: nil, queue: nil, using: { [weak self] notification in
            guard let self = self else { return }
            self.keyboardFrame = .zero
            self.chatInputView.frame = CGRect(x: 0, y: self.view.height - self.chatInputView.minHeight - tabBarAdditionHeight, width: self.chatInputView.width, height: self.chatInputView.height)
            self.layoutTableView(with: .zero)
        })
        
    }

    //MARK: Main Method
    /// Call this method when receive new message
    func layoutUIWhenReceiveMessage() {
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.layoutTableView(with: self.keyboardFrame)
        self.scrollToBottom()
    }
    
    /// Implemented by subclasses
    func inputViewConfirmInput(_ text: String) {
    }

    /// Update tableView frame when keyboard or inputView frame changed.
    private func layoutTableView(with keyboardFrame: CGRect) {
        
        if keyboardFrame == .zero {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                self.tableView.y = 0
            }
            return
        }
        
        // 由于 tableView 的高度 = view.height - inputViewHeight - tabBarAdditionHeight
        // 所以最大偏移量 maxOffset 的值计算方式如下 keyboardFrame.height - inputViewMinHeight - tabBarAdditionHeight + inputHeight(当前chatInputView的真实高度)
        let inputViewHeight = chatInputView.height
        let maxOffset = keyboardFrame.height - chatInputView.minHeight - tabBarAdditionHeight + inputViewHeight
        let screenHeight = UIScreen.main.bounds.height
        let statusBarAndNavigationBarHeight = ScreenAppearence.statusBarAndNavigationBarHeight
        // 显示键盘时可见区域的高度
        let visiableHeight = screenHeight - keyboardFrame.height - inputViewHeight - statusBarAndNavigationBarHeight
        
        let contentHeight = tableView.contentSize.height
 
        var y: CGFloat = 0
        if contentHeight > visiableHeight && abs(maxOffset) > abs(tableView.y) {
            let offset = contentHeight - visiableHeight
            y = max(-offset, -maxOffset)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
                self.tableView.y = y
            }
        }
        
    }
    
    func scrollToBottom() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        guard numberOfRows > 0 else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.tableView.scrollToRow(at: IndexPath(row: numberOfRows - 1, section: 0), at: .bottom, animated: false)
        }
    }
}


extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}
