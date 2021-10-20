//
//  ChatInputView.swift
//  ChatRoom
//
//  Created by 蔡志文 on 2021/10/19.
//

import UIKit

private let maxInputHeight: CGFloat = 100.0
private let minInputHeight: CGFloat = 36.0

class ChatInputView: UIView {

    
    var confirmInputClosure: ((String) -> Void)?
    var updateFrameClosure: ((CGFloat) -> Void)?
    
    let voiceButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_voice"), for: .normal)
        return button
    }()
    
    let emojiButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_expression"), for: .normal)
        return button
    }()
    
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_more2"), for: .normal)
        return button
    }()
    

//    let textField: UITextField = {
//        let textField = UITextField()
//        textField.backgroundColor = UIColor.white
//        textField.font = UIFont.systemFont(ofSize: 16)
//        textField.textColor = UIColor.darkText
//        textField.layer.cornerRadius = 18
//        textField.tintColor = UIColor.systemRed
//        textField.leftViewMode = .always
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.rightViewMode = .always
//        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        textField.returnKeyType = .send
//        textField.enablesReturnKeyAutomatically = true
//        return textField
//    }()
    
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
        contentView.addSubview(voiceButton)
        contentView.addSubview(textField)
        contentView.addSubview(emojiButton)
        contentView.addSubview(addButton)
        contentView.addSubview(lineView)
        lineView.backgroundColor = UIColor(hex: "eeeeee")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        voiceButton.frame = CGRect(x: 0, y: height - 52, width: 54, height: 52)
        textField.frame = CGRect(x: 54, y: 8, width: width - 54 - 93, height: height - 16)
        addButton.sizeToFit()
        addButton.frame = CGRect(x: width - addButton.width - 15, y: height - 52, width: addButton.width, height: 52)
        emojiButton.sizeToFit()
        emojiButton.frame = CGRect(x: addButton.minX - addButton.width - 15, y: height - 52, width: emojiButton.width, height: 52)
        lineView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: 1)
    }
    
}

extension ChatInputView: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            textField.text = nil
            confirmInputClosure?(text)
            return true
        } else {
            return false
        }
    }
    
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let text = textView.text {
                textView.text = nil
                confirmInputClosure?(text)
            }
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let _ = textView.text {
            let size = textView.sizeThatFits(CGSize(width: textView.width, height: 0))
            let viewHeight: CGFloat = min(max(ceil(size.height), 36), maxInputHeight) + 16
            updateFrameClosure?(viewHeight)
        }
    }
    
}

extension ChatInputView {
    var minHeight: CGFloat {
        minInputHeight + 16.0
    }
}
