//
//  ChatRoomViewController.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/20.
//

import UIKit

private let tabBarAdditionHeight: CGFloat = ScreenAppearence.bottomSafeAreaHeight
private let tableHeaderHeight: CGFloat = 30.0

class ChatRoomViewController: UIViewController {

    let chatInputView: ChatInputView = ChatInputView()
    let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        indicator.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        indicator.color = UIColor(hex: "d1d1d1")
        return indicator
    }()
    
    lazy var tableHeaderView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: tableHeaderHeight))
        indicatorView.center = headerView.center
        headerView.addSubview(indicatorView)
        return headerView
    }()
    
    var keyboardFrame: CGRect = .zero
    var historyLoading: Bool = false
    var tableViewIsScrolling: Bool = false
  
    enum ScrollDirection {
        case top
        case bottom
    }
    
    enum RefreshState {
        case unRefresh
        case refreshing
        case complete
    }
    
    var refreshState: RefreshState = .unRefresh
    
    var lastContentOffset: CGPoint = .zero
    var dragTimes: Int = 0
    
    lazy var tableView: ChatTableView = {
        let tableView = ChatTableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 12))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        initNav()
        initView()
        initBind()
        initNotification()
        tableView.tableHeaderView = tableHeaderView
        indicatorView.startAnimating()
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

    deinit {
        keyboardWillShowToken = nil
        keyboardWillHideToken = nil
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
    
    
    /// Call this method when loading history page
    /// - Parameter insertCount: number of messages inserted
//    func layoutUIWhenLoadPageCompletion(insertCount: Int) {
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
//            if self.refreshState == .refreshing || self.refreshState == .complete {
//                self.refreshState = .unRefresh
//                return
//            }
//            self.refreshState = .refreshing
//            self.indicatorView.stopAnimating()
//            self.tableView.tableHeaderView = nil
//
//            //        var indexPathes: [IndexPath] = []
//            //        for index in 0..<insertCount {
//            //            indexPathes.append(IndexPath(row: index, section: 0))
//            //        }
//            UIView.performWithoutAnimation {
//                //            self.tableView.insertRows(at: indexPathes, with: .none)
//                self.tableView.reloadData()
//            }
//
//            self.tableView.setNeedsLayout()
//            self.tableView.layoutIfNeeded()
//            // keep the original position of cells.
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: insertCount - 1, section: 0)) {
//                let contentOffset = cell.maxY - tableHeaderHeight + self.tableView.contentOffset.y
//                self.tableView.setContentOffset(CGPoint(x: 0, y: contentOffset) , animated: false)
//                print("in currentOffset: \(self.tableView.contentOffset)")
//            } else {
//
//                print("out currentOffset: \(self.tableView.contentOffset)")
//            }
//
//            print("currentOffset: \(self.tableView.contentOffset)")
//            self.historyLoading = false
//            self.refreshState = .unRefresh
//        }
//
//    }

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
    
    private func scrollToBottom() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.tableView.scrollRectToVisible(self.tableView.tableFooterView!.frame, animated: false)
        }
    }
    
    //MARK: Implemented by subclasses
    /// Implemented by subclasses
    func inputViewConfirmInput(_ text: String) {
    }

    
    /// Execute load history messages, implemented by subclasses
    func startLoadHistoryMessage() {
    }
    
    /// If there are history messages, loading more messages
    func hasHistoryMessage() -> Bool {
        false
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
//        if indicatorView.isAnimating {
//            print("refresh immediate")
//            refreshDataImmidiate()
//            tableView.reloadData()
//            dragTimes = 2
//        }
        if historyLoading {
            print("refresh immediate")
            refreshDataImmidiate()
            tableView.reloadData()
            dragTimes = 2
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < 0 && hasHistoryMessage() && !indicatorView.isAnimating {
//            tableView.tableHeaderView = tableHeaderView
            dragTimes = 1
            indicatorView.startAnimating()
        }
        
    }
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffsetY = scrollView.contentOffset.y
        if dragTimes == 2 {
            dragTimes = 0
            return
        }
        if contentOffsetY < 20 && hasHistoryMessage() {
            historyLoading = true
//            tableView.tableHeaderView = tableHeaderView
//            indicatorView.startAnimating()
            print("start loading")
            startLoadHistoryMessage()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tableViewIsScrolling = false
    }
    
    func refreshDataImmidiate() {
        if refreshState == .refreshing || refreshState == .complete {
            refreshState = .unRefresh
            return
        }
        
        refreshState = .refreshing
        tableView.shouldResetContentOffset = true
        self.indicatorView.stopAnimating()
//        self.tableView.tableHeaderView = nil
        UIView.performWithoutAnimation {
            print("--- reload data")
            self.tableView.reloadData()
        }
        
        refreshState = .complete
        historyLoading = false
        print("refresh complete")
    }
    
    func layoutUIWhenLoadPageCompletion(insertCount: Int) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            if self.refreshState == .refreshing || self.refreshState == .complete {
                self.refreshState = .unRefresh
                return
            }
            print("begin update cells")
            self.tableView.shouldResetContentOffset = false
            self.refreshState = .refreshing
            self.indicatorView.stopAnimating()
//            self.tableView.tableHeaderView = nil
            
            var indexPathes: [IndexPath] = []
            for index in 0..<insertCount {
                indexPathes.append(IndexPath(row: index, section: 0))
            }
            self.tableView.reloadData()
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            // keep the original position of cells.
            if let cell = self.tableView.cellForRow(at: IndexPath(row: insertCount - 1, section: 0)) {
                let contentOffset = cell.maxY - tableHeaderHeight + self.tableView.contentOffset.y
                self.tableView.setContentOffset(CGPoint(x: 0, y: contentOffset) , animated: false)
            }
            self.historyLoading = false
            self.refreshState = .unRefresh
        }
       
    }
    

}
