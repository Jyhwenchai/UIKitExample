//
//  ChatRoomViewController.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/20.
//

import UIKit

private let tabBarAdditionHeight: CGFloat = ScreenAppearence.bottomSafeAreaHeight
private let tableHeaderHeight: CGFloat = 30.0
private let tableFooterHeight: CGFloat = 12.0

class ChatRoomViewController: UIViewController {

    public var loadingPageDelayInterval: TimeInterval = 0.6
    
    private enum RefreshState {
        case normal
        case prepared
        case loadingData
        case loadingDataCompleted
        case updatingUI
    }
    
    private var keyboardFrame: CGRect = .zero
    private var refreshState: RefreshState = .normal
    private var loadPageSuccessContentOffset: CGPoint = .zero
    private var viewDidLayout: Bool = false
    
    //MARK: - Views
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
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: tableFooterHeight))
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
                self.scrollToBottomWhenKeyBoardWillShow()
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
    
    /// Reload data and update UI immediately when drag tableView and refreshState is `loadingDataCompleted`
    private func reloadDataImmidiate() {
        if self.refreshState != .loadingDataCompleted {
            return
        }
        refreshState = .updatingUI
        self.indicatorView.stopAnimating()
        self.tableView.tableHeaderView = nil
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.refreshState = .normal
    }
    
    /// Reload data and update UI when loading history page
    func reloadDataWhenLoadingPage() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingPageDelayInterval) {
 
            if self.refreshState != .loadingDataCompleted {
                return
            }
            
            self.refreshState = .updatingUI
            self.indicatorView.stopAnimating()
            self.tableView.tableHeaderView = nil
            
            let reloadBeforeCount = self.tableView.numberOfRows(inSection: 0)
            self.tableView.reloadData()
            let reloadEndCount = self.tableView.numberOfRows(inSection: 0)
            
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
            // keep the original position of cells.
            let addCellsCount = reloadEndCount - reloadBeforeCount
            if let cell = self.tableView.cellForRow(at: IndexPath(row: addCellsCount - 1, section: 0)) {
                let contentOffset = cell.maxY - tableHeaderHeight + self.tableView.contentOffset.y
                self.tableView.setContentOffset(CGPoint(x: 0, y: contentOffset) , animated: false)
            }
            self.refreshState = .normal
            self.tableView.bounces = true
        }
       
    }
    
    /// Call this method when receive new message
    func layoutUIWhenReceiveMessage() {
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.layoutTableView(with: self.keyboardFrame)
        self.scrollToBottomWhenKeyBoardWillShow()
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
    
    private func scrollToBottomWhenKeyBoardWillShow() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.tableView.scrollRectToVisible(self.tableView.tableFooterView!.frame, animated: false)
        }
    }
    
    /// Call this method when first load data.(called in the `viewDidLayoutSubviews` method)
    func scrollToBottom(animated: Bool) {
        defer { viewDidLayout = true }
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        let cellHeight = getCellsHeight()
        let offset = cellHeight + tableFooterHeight - tableView.height
        // The default tableView.contentOffset.y value is -tableView.safeAreaInsets.top
        if  offset <= tableView.contentOffset.y { return }
        tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
    }
    
    //MARK: Implemented by subclasses
    /// Implemented by subclasses
    func inputViewConfirmInput(_ text: String) {
    }

    
    /// Execute load history messages, implemented by subclasses
    func loadingHistoryMessages(completion: (Bool) -> Void) {
    }
    
    /// Check has more history messages or not.
    ///
    ///  If there are history messages, can triger loading more messages event.
    func hasHistoryMessage() -> Bool {
        false
    }
    
}

//MARK: - UITableViewDataSource initialize
extension ChatRoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}


//MARK: - UIScrollView Delegate Handler
extension ChatRoomViewController:  UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
        if refreshState == .loadingDataCompleted {
            scrollView.bounces = false
            // delay to refresh
            usleep(150000)
    
            /**
             由于部分 iOS 版本通过 `scrollView.contentSize` 得到的值不正确，所以只能通过计算所有 cell 的高度来计算分页前后增加的高度
             let beforeContentSize = scrollView.contentSize
             
             let endContentSize = scrollView.contentSize
             
             scrollView.setContentOffset(CGPoint(x: 0, y: endContentSize.height - beforeContentSize.height + scrollView.contentOffset.y), animated: false)
             */
            
            let beforeCellsHeight = getCellsHeight()
            reloadDataImmidiate()
            let endCellsHeight = getCellsHeight()
            // 在插入新的cell前后 tableHeaderView，插入后被移除，所以要减去 tableHeaderView 的高度
            let offsetY = endCellsHeight - beforeCellsHeight - tableHeaderHeight + scrollView.contentOffset.y
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            loadPageSuccessContentOffset = scrollView.contentOffset
            scrollView.bounces = true
        }
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !viewDidLayout { return }
        
        // keep contentOffset
        if loadPageSuccessContentOffset != .zero {
            scrollView.setContentOffset(loadPageSuccessContentOffset, animated: false)
            loadPageSuccessContentOffset = .zero
        }
        
        let contentOffsetY = scrollView.contentOffset.y
        if contentOffsetY < 0 && hasHistoryMessage()
            && !indicatorView.isAnimating
            && keyboardFrame == .zero
            && refreshState == .normal {
            refreshState = .prepared
            tableView.tableHeaderView = tableHeaderView
            indicatorView.startAnimating()
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        prepareLoadHistoryPage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        prepareLoadHistoryPage()
    }
    
    private func prepareLoadHistoryPage() {
        if refreshState == .prepared  {
            refreshState = .loadingData
            loadingHistoryMessages { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.refreshState = .loadingDataCompleted
                } else {
                    self.cancelLoadingPage()
                }
            }
        }
    }
    
    /// cancel loading data
    private func cancelLoadingPage() {
        self.indicatorView.stopAnimating()
        self.tableView.tableHeaderView = nil
        self.tableView.scrollsToTop = true
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.refreshState = .normal
    }
    
    private func getCellsHeight() -> CGFloat {
        let numberOfCount = tableView.numberOfRows(inSection: 0)
        guard numberOfCount > 0 else  { return tableView.contentSize.height }
        
        var contentHeight: CGFloat = 0
        for index in 0..<numberOfCount {
            let cellHeight = tableView.delegate!.tableView!(tableView, heightForRowAt: IndexPath(row: index, section: 0))
            contentHeight += cellHeight
        }
        return contentHeight
    }

}
