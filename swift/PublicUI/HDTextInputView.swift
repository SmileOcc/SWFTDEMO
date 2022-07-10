//
//  HDTextInputView.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/8/31.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public protocol HDTextInputViewDelegate: NSObjectProtocol {
    func onInputTextForBeginEditingFromHDTextInputView();
    func onInputTextForEndEditingFromHDTextInputView();
}

public class HDTextInputView: UIView, UITextViewDelegate {

    public weak var delegate:HDTextInputViewDelegate?
    public var placeholderString: NSString {
        set {
            self.placeholderLabel.text = newValue as String;
        }
        get {
            return self.placeholderLabel.text! as NSString;
        }
    }
    
    public var maxNum: NSInteger {
        set {
            if localMaxNum == newValue {
                return
            }
            localMaxNum = newValue
            let tempString = NSString.init(string: "\(localMaxNum ?? 0)")
            let textAttributed = NSMutableAttributedString.init(string: "\(localinputNum ?? 100)/\(tempString)")
            textAttributed.addAttribute(.foregroundColor, value: UIColor.LightGrayTitle(), range: NSMakeRange(textAttributed.length - tempString.length, tempString.length))
            inputNumLabel.attributedText = textAttributed
        }
        get {
            return self.localMaxNum ?? 100
        }
    }
    public var showValue:String {
        set {
            if textViewName == newValue {
                return;
            }
            textViewName = newValue;
            self.textView.text = textViewName;
            self.setNeedsLayout();
        }
        get {
            return textViewName;
        }
    }
    
    var localMaxNum: NSInteger?
    var localinputNum: NSInteger?
    private var textViewName:String = "";
    
    lazy public var textView : UITextView = {
        var textView = UITextView.init(frame: CGRect(x: 0, y: 0, width: HDConst.SCREENW, height: HDConst.SCREENH))
        textView.textColor = .DarkGrayTitle()
        textView.font = UIFont.systemFont(ofSize: .scaleW(15), weight: .regular)
        textView.delegate = self
        return textView
    }()
    
    lazy var placeholderLabel : UILabel = {
        var label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.textColor = .PlaceholderGrayTitle()
        label.font = UIFont.systemFont(ofSize: .scaleW(14), weight: .regular)
        label.textAlignment = .left
        label.text = "";
        return label
    }()
    
    lazy var inputNumLabel : UILabel = {
        var label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.textColor = .ApplicationTitleRed()
        label.font = UIFont.systemFont(ofSize: .scaleW(12), weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.lineColor().cgColor
        self.layer.borderWidth = 1
        
        localMaxNum = 100
        localinputNum = 0
        
        self.addSubview(textView)
        textView.frame = CGRect(x: .scaleW(15.0), y: .scaleW(10.0), width: self.width - .scaleW(15.0) * 2, height: self.height - .scaleW(10.0) - .scaleW(25))
        
        self.addSubview(placeholderLabel);
        placeholderLabel.text = placeholderString as String?;
        placeholderLabel.frame = CGRect(x: .scaleW(10.0), y: .scaleW(12.0), width: self.width - .scaleW(40.0) * 2, height: .scaleW(20))
        
        self.addSubview(inputNumLabel)
        inputNumLabel.frame = CGRect(x: self.width - .scaleW(100) - .scaleW(5), y: self.height - .scaleW(20), width: .scaleW(100), height: .scaleW(20))
        let tempString = NSString.init(string: "\(localMaxNum ?? 0)")
        let textAttributed = NSMutableAttributedString.init(string: "\(localinputNum ?? 100)/\(tempString)")
        textAttributed.addAttribute(.foregroundColor, value: UIColor.LightGrayTitle(), range: NSMakeRange(textAttributed.length - tempString.length, tempString.length))
        inputNumLabel.attributedText = textAttributed
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        textView.frame = CGRect(x: .scaleW(5), y: .scaleW(5), width: self.width - .scaleW(10), height: self.height - .scaleW(25))
        inputNumLabel.frame = CGRect(x: self.width - .scaleW(100) - .scaleW(5), y: self.height - .scaleW(20), width: .scaleW(100), height: .scaleW(20))
        
        localinputNum = textView.text.count
        let tempString = NSString.init(string: "\(localMaxNum ?? 0)")
        let textAttributed = NSMutableAttributedString.init(string: "\(localinputNum ?? 100)/\(tempString)")
        textAttributed.addAttribute(.foregroundColor, value: UIColor.LightGrayTitle(), range: NSMakeRange(textAttributed.length - tempString.length, tempString.length))
        inputNumLabel.attributedText = textAttributed
        
        placeholderLabel.frame = CGRect(x: .scaleW(10.0), y: .scaleW(12.0), width: self.width - .scaleW(40.0) * 2, height: .scaleW(20))
        if localinputNum! > 0 {
            placeholderLabel.isHidden = true;
        } else {
            placeholderLabel.isHidden = false;
        }
    }
    
    // MARK: - delegate
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.placeholderLabel.isHidden = true;
        } else {
            self.placeholderLabel.isHidden = false;
        }
        
        if (self.delegate != nil) {
            self.delegate?.onInputTextForBeginEditingFromHDTextInputView();
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.placeholderLabel.isHidden = true;
        } else {
            self.placeholderLabel.isHidden = false;
        }
        
        localinputNum = textView.text.count
        let tempString = NSString.init(string: "\(localMaxNum ?? 0)")
        let textAttributed = NSMutableAttributedString.init(string: "\(localinputNum ?? 100)/\(tempString)")
        textAttributed.addAttribute(.foregroundColor, value: UIColor.LightGrayTitle(), range: NSMakeRange(textAttributed.length - tempString.length, tempString.length))
        inputNumLabel.attributedText = textAttributed
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.placeholderLabel.isHidden = true;
        } else {
            self.placeholderLabel.isHidden = false;
        }
        self.setNeedsLayout();
        
        if (self.delegate != nil) {
            self.delegate?.onInputTextForEndEditingFromHDTextInputView();
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {//回车
            textView.resignFirstResponder()
            return false
        }
        if text == "" {//删除
            return true
        }
        if textView.text.count >= self.localMaxNum! || textView.text.count + text.count > self.localMaxNum! {
            return false
        }
        return true
    }
}
