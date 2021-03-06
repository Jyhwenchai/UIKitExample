//
//  ChatInputView.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/19.
//

import UIKit

private let maxInputHeight: CGFloat = 100.0
private let minInputHeight: CGFloat = 36.0
private let inputMarginSpacing: CGFloat = 16

protocol InputViewDelegate: NSObjectProtocol {
    func inputView(_ inputView: ChatInputView, show newAccessoryView: ChatInputView.SelectAccessoryView, dismiss oldAccessoryView: ChatInputView.SelectAccessoryView?)
}

public class ChatInputView: UIView {
    
    enum SelectAccessoryView: Equatable {
        case input
        case selected(InputAccessoryView, AccessoryDirection)
    }
    
    enum AccessoryDirection: Equatable {
        case left
        case right
    }
    
    /// 可能所有的组件视图都没有被选中，包括 TextField
    var selectAccessoryView: SelectAccessoryView? = nil
    var leftAccessoryViewGroup: InputAccessoryViewGroup?
    var rightAccessoryViewGroup: InputAccessoryViewGroup?
    
    weak var delegate: InputViewDelegate?
    
    var confirmInputClosure: ((String) -> Void)?
    var updateFrameClosure: ((CGFloat) -> Void)?
    
    let textField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = UIColor.white
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor.darkText
        textField.layer.cornerRadius = 4
        textField.tintColor = UIColor.systemRed
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    let lineView = UIView()
    let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "f1f1f1")
        textField.delegate = self
        addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(lineView)
        lineView.backgroundColor = UIColor(hex: "e1e1e1")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        lineView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: 1)
        
        var reduceWidth: CGFloat = 0
        var groupViewMaxX: CGFloat = 0
        if let leftAccessoryViewGroup = leftAccessoryViewGroup {
            let groupView = leftAccessoryViewGroup.titleGroupView()
            var frame = groupView.frame
            frame.size.height = bounds.height
            groupView.frame = frame
            reduceWidth += frame.width
            groupViewMaxX = frame.width
        }
        
        if let rightAccessoryViewGroup = rightAccessoryViewGroup {
            let groupView = rightAccessoryViewGroup.titleGroupView()
            var frame = groupView.frame
            frame.origin.x = bounds.width - frame.width
            frame.size.height = bounds.height
            groupView.frame = frame
            reduceWidth += frame.width
        }
        
        let remainWidth = bounds.width - reduceWidth
        textField.frame = CGRect(x: groupViewMaxX, y: inputMarginSpacing / 2, width: remainWidth, height: height - inputMarginSpacing)
    }
    
    
    public func addLeftAccessoryViews(@InputAccessoryBuilder _ viewBuilder: () -> InputAccessoryViewGroup) {
        leftAccessoryViewGroup = viewBuilder()
        addSubview(leftAccessoryViewGroup!.titleGroupView())
        leftAccessoryViewGroup?.selectedClosure = { [weak self] view in
            guard let self = self else { return }
            self.updateSelectedAccessoryView(view, direction: .left)
        }
    }
    
    public func addRightAccessoryViews(@InputAccessoryBuilder _ viewBuilder: () -> InputAccessoryViewGroup) {
        rightAccessoryViewGroup = viewBuilder()
        addSubview(rightAccessoryViewGroup!.titleGroupView())
        rightAccessoryViewGroup?.selectedClosure = { [weak self] view in
            guard let self = self else { return }
            self.updateSelectedAccessoryView(view, direction: .right)
        }
    }
    
    func updateSelectedAccessoryView(_ accessoryView: InputAccessoryView, direction: AccessoryDirection) {
        if selectAccessoryView == nil {
            selectAccessoryView = .selected(accessoryView, direction)
            accessoryView.titleView.isSelected = true
            delegate?.inputView(self, show: selectAccessoryView!, dismiss: nil)
            return
        }
        
        let oldSelectAccessoryView = selectAccessoryView!
        switch oldSelectAccessoryView {
        case .input:
            selectAccessoryView = .selected(accessoryView, direction)
            accessoryView.titleView.isSelected = true
        case .selected(let currentAccessoryView, let currentDirection):
            if direction == currentDirection, accessoryView.index == currentAccessoryView.index {
                selectAccessoryView = .input
            } else {
                selectAccessoryView = .selected(accessoryView, direction)
                accessoryView.titleView.isSelected = true
            }
            currentAccessoryView.titleView.isSelected = false
        }
        delegate?.inputView(self, show: selectAccessoryView!, dismiss: oldSelectAccessoryView)
    }
    
    
}

extension ChatInputView: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if case let .selected(view, _) = selectAccessoryView {
            view.titleView.isSelected = false
        }
        let oldSelectAccessoryView = selectAccessoryView
        selectAccessoryView = .input
        delegate?.inputView(self, show: selectAccessoryView!, dismiss: oldSelectAccessoryView)
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let text = textView.text {
                textView.text = nil
                confirmInputClosure?(text)
            }
            return false
        }
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let _ = textView.text {
            let size = textView.sizeThatFits(CGSize(width: textView.width, height: 0))
            let viewHeight: CGFloat = min(max(ceil(size.height), minInputHeight), maxInputHeight) + inputMarginSpacing
            if viewHeight != height {
                updateFrameClosure?(viewHeight)
            }
        }
    }
    
}

extension ChatInputView {
    var minHeight: CGFloat {
        minInputHeight + inputMarginSpacing
    }
    
    var maxHeight: CGFloat {
        maxInputHeight + inputMarginSpacing
    }
}
