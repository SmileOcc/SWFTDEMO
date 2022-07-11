//
//  YXRegisterCodeAlertView.swift
//  uSmartOversea
//
//  Created by rrd on 2019/6/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import SnapKit
import TYAlertController
import RxSwift
import RxCocoa
import QMUIKit

public class YXRegisterCodeAlertAction: NSObject {
    
    @objc public enum YXRegisterCodeAlertActionStyle: Int {
        case `default`, cancel, destructive, fullDefault, fullCancel, fullDestructive
    }
    
    fileprivate var title: String?
    fileprivate var style: YXRegisterCodeAlertActionStyle = .default
    fileprivate var handler: ((YXRegisterCodeAlertAction) -> Void)?
    
    @objc class public func action(title: String, style: YXRegisterCodeAlertActionStyle, handler: @escaping (YXRegisterCodeAlertAction) -> Void) -> YXRegisterCodeAlertAction {
        YXRegisterCodeAlertAction(title: title, style: style, handler: handler)
    }
    
    public convenience init(title: String?, style: YXRegisterCodeAlertActionStyle, handler: @escaping (YXRegisterCodeAlertAction) -> Void) {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }
}


public class YXRegisterCodeAlertView: UIView {
    
    let horizontalMargin = 16
    let verticalMargin = 20
    let buttonContentHeight = 48
    let textFieldContentHeight = 78
    let textFieldHeight = 36
    let messageTextViewMaxHeight = 160
    let defaultWidth = 285
    
    let buttonTagOffset = 1000
    
    let disposeBag = DisposeBag()
    
//    @objc public enum YXAlertStyle: Int {
//        case `default`, document
//    }
    
    @objc public var clickedAutoHide: Bool = true
    
    @objc fileprivate var textField: UITextField? {
        get {
            self.textFields.first
        }
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")
        label.font = .systemFont(ofSize: 18)//16
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.qmui_color(withHexString: "#353547")
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        return textView
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")
        label.font = .systemFont(ofSize: 16)//14
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")?.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    fileprivate lazy var textContextView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var textFieldBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4;
        view.layer.masksToBounds = true;
        view.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    fileprivate lazy var numLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#353547")?.withAlphaComponent(0.5)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    fileprivate lazy var buttonContextView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var textFields: [UITextField] = {
        let textField = [UITextField]()
        return textField
    }()
    
    fileprivate lazy var buttons: [UIButton] = {
        let buttons = [UIButton]()
        return buttons
    }()
    
    fileprivate lazy var actions: [YXRegisterCodeAlertAction] = {
        let actions = [YXRegisterCodeAlertAction]()
        return actions
    }()
    
    fileprivate lazy var textContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var textFieldContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var buttonContentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    fileprivate var alertStyle: YXAlertStyle = .default
    fileprivate var textFieldMaxNum: UInt = 0
    fileprivate var customView: UIView?
    
    @objc public class func alertView(message: String) -> YXAlertView {
        YXAlertView(message: message)
    }
    
    @objc public convenience init(title: String? = nil, message: String?, prompt: String? = nil, style: YXAlertStyle = .default, messageAlignment : NSTextAlignment = .center) {
        self.init(frame: .zero)
        
        alertStyle = style
        
        titleLabel.text = title
        promptLabel.text = prompt
        
        if let string = message {
            if alertStyle == .default {
                messageLabel.text = string
                messageLabel.textAlignment = messageAlignment
                
//                if title == nil || title?.count == 0  {
//                    messageLabel.textColor = UIColor.qmui_color(withHexString: "#353547")
//                } else {
//                    messageLabel.textColor = UIColor.qmui_color(withHexString: "#353547")?.withAlphaComponent(0.5)
//                }
            } else {
                messageTextView.text = message
                promptLabel.textAlignment = .center
                promptLabel.font = .systemFont(ofSize: 14)
                titleLabel.font = .systemFont(ofSize: 20)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        layer.cornerRadius = 8
        
        addContentViews()
        addTextLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


//MARK: Method
extension YXRegisterCodeAlertView {
    fileprivate func actionButton(with action: YXRegisterCodeAlertAction) -> UIButton{
        let button = UIButton(type: .custom)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tag = buttonTagOffset + buttons.count
        button.titleLabel?.textAlignment = .center
        
        let style = action.style
        switch style {
        case .default:
            button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            break;
        case .cancel:
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            break;
        case .destructive:
            button.setTitleColor(UIColor.qmui_color(withHexString: "#EC355A"), for: .normal)
            break;
        case .fullDefault:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = UIColor.qmui_color(withHexString: "#0055FF")
            button.setTitleColor(.white, for: .normal)
            break;
        case .fullCancel:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = UIColor.qmui_color(withHexString: "#D6D6D6")
            button.setTitleColor(.white, for: .normal)
            break;
        case .fullDestructive:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = UIColor.qmui_color(withHexString: "#EC355A")
            button.setTitleColor(.white, for: .normal)
            break;
        default:
            break;
        }
        button.addTarget(self, action: #selector(self.actionButtonClicked(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc fileprivate func actionButtonClicked(_ button: UIButton) {
        let action = actions[button.tag - buttonTagOffset];
        
        if (clickedAutoHide) {
            hide()
        }
        
        if let handler = action.handler {
            handler(action);
        }
    }
    
    @objc fileprivate func updateNumLabel() {
        if let text = textField?.text {
            numLabel.text = "\(text.characterLength())/\(textFieldMaxNum)"
        }
        //[NSString stringWithFormat:@"%zd/%d",[self.textField.text characterLength], kDefaultMaxNumber];
    }
}

//MARK: Layout
public extension YXRegisterCodeAlertView {
    override func didMoveToSuperview() {
        if self.superview != nil {
            layoutContentViews()
            layoutTextLabels()
            layoutTextFieldContentView()
            layoutButtonContentView()
        }
    }
    
    fileprivate func layoutContentViews() {
        if textContentView.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        
        self.snp.makeConstraints { (make) in
            make.width.equalTo(defaultWidth)
            make.center.equalToSuperview()
            make.bottom.equalTo(buttonContentView)
        }
        
        textContentView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(horizontalMargin)
            make.right.equalTo(self).offset(-horizontalMargin)
            make.top.equalTo(24)//verticalMargin
            
        }
        textContentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func layoutTextLabels() {
        if titleLabel.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(textContentView)
            make.top.equalTo(textContentView)
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if alertStyle == .default {
            if let text = promptLabel.text, text.count > 0 {
                messageLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(titleLabel.snp.bottom).offset(30)//verticalMargin/4
                }
                
                promptLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(messageLabel.snp.bottom).offset(verticalMargin/4)
                    make.bottom.equalTo(textContentView.snp.bottom).offset(-verticalMargin/2)
                }
            } else {
                messageLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(titleLabel.snp.bottom).offset(30)//verticalMargin/4
                    make.bottom.equalTo(textContentView.snp.bottom).offset(-25)//verticalMargin
                }
            }
            
        } else {
            if let text = promptLabel.text, text.count > 0 {
                promptLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(titleLabel.snp.bottom).offset(verticalMargin/4)
                }
                
                var messageHeight = Int((messageTextView.text as NSString).boundingRect(with: CGSize(width: defaultWidth - horizontalMargin * 2, height:Int.max), options: .usesLineFragmentOrigin, attributes: [.font: messageTextView.font!], context: nil).size.height) + verticalMargin
                if messageHeight > messageTextViewMaxHeight {
                    messageHeight = messageTextViewMaxHeight
                }
                
                messageTextView.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(promptLabel.snp.bottom).offset(verticalMargin/4)
                    make.bottom.equalTo(textContentView).offset(-verticalMargin)
                    make.height.equalTo(messageHeight)
                }
            }
        }
    }
    
    //    fileprivate func layoutCustomView() {
    //        if let customView = self.customView, customView.translatesAutoresizingMaskIntoConstraints == true {
    //            customView.snp.makeConstraints { (make) in
    //                make.top.equalTo(textContentView.snp.bottom)
    //                make.centerX.equalTo(self)
    //                make.height.equalTo(customView.bounds.size.height)
    //            }
    //        }
    //    }
    
    fileprivate func layoutTextFieldContentView() {
        if textFieldContentView.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        
        textFieldContentView.snp.makeConstraints { (make) in
            make.top.equalTo(textContentView.snp.bottom)
            make.left.right.equalTo(textContentView)
            make.height.equalTo(0)
        }
        textFieldContentView.translatesAutoresizingMaskIntoConstraints = false
        
        if let customView = self.customView {
            let customSize = customView.bounds.size
            textFieldContentView.snp.updateConstraints { (make) in
                make.height.equalTo(Int(customSize.height) + verticalMargin)
            }
            
            customView.snp.makeConstraints { (make) in
                make.top.equalTo(textFieldContentView)
                make.centerX.equalTo(textFieldContentView)
                make.size.equalTo(customSize)
            }
        } else {
            if textFields.count > 0 {
                textFieldContentView.snp.updateConstraints { (make) in
                    make.height.equalTo(textFieldContentHeight)
                }
                
                textField?.snp.makeConstraints({ (make) in
                    make.top.bottom.equalTo(textFieldBackgroundView)
                    make.left.equalTo(self.textFieldBackgroundView).offset(verticalMargin/2)
                    make.right.equalTo(self.textFieldBackgroundView).offset(-verticalMargin/2)
                })
            }
        }
    }
    
    fileprivate func layoutButtonContentView() {
        if buttonContentView.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        
        buttonContentView.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldContentView.snp.bottom)
            make.left.right.equalTo(self)
            make.height.equalTo(0)
        }
        
        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
        
        if (buttons.count > 0) {
            buttonContentView.snp.updateConstraints({ (make) in
                if alertStyle == .document {
                    make.height.equalTo(buttonContentHeight + verticalMargin)
                } else {
                    make.height.equalTo(48+95)
                    //make.height.equalTo(buttonContentHeight)
                }
            })
//            //添加横线
//            if alertStyle == .default {
//                let line = UIView()
//                line.backgroundColor = UIColor.qmui_color(withHexString: "#F0F0F0")
//                buttonContentView.addSubview(line)
//
//                line.snp.makeConstraints { (make) in
//                    make.top.left.right.equalTo(buttonContentView)
//                    make.height.equalTo(1)
//                }
//            }
            
            if buttons.count == 2 {
                let firstBtn = buttons.first!
                firstBtn.backgroundColor = QMUITheme().themeTextColor()
                firstBtn.setTitleColor(.white, for: .normal)
                firstBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                firstBtn.layer.cornerRadius = 6
                firstBtn.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(buttonContentView)
                    make.size.equalTo(CGSize(width: 130, height: 48))
                }
                let secondBtn = buttons.last!
                let titleColor = QMUITheme().textColorLevel1().qmui_color(withAlpha: 0.6, backgroundColor: .clear)
                secondBtn.setTitleColor(titleColor, for: .normal)
                secondBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                secondBtn.snp.makeConstraints { (make) in
                    make.right.equalToSuperview().offset(-32)
                    make.bottom.equalToSuperview().offset(-28)
                }
                
//                buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: CGFloat(horizontalMargin), leadSpacing: CGFloat(horizontalMargin), tailSpacing: CGFloat(horizontalMargin))
//                buttons.snp.makeConstraints { (make) in
//                    if alertStyle == .document {
//                        make.top.equalTo(buttonContentView)
//                        make.height.equalTo(buttonContentHeight)
//                    } else {
//                        make.centerY.equalTo(buttonContentView)
//                    }
//                }
//
//                if alertStyle == .default {
//                    //竖线
//                    let line = UIView()
//                    line.backgroundColor = UIColor.qmui_color(withHexString: "#F0F0F0")
//                    buttonContentView.addSubview(line)
//
//                    line.snp.makeConstraints { (make) in
//                        make.center.height.equalTo(buttonContentView)
//                        make.width.equalTo(1)
//                    }
//                }
            } else if buttons.count == 1 {
                let button = buttons.first
                button?.snp.makeConstraints({ (make) in
                    make.left.equalTo(self).offset(horizontalMargin)
                    make.right.equalTo(self).offset(-horizontalMargin)
                    if alertStyle == .document {
                        make.top.equalTo(buttonContentView)
                        make.height.equalTo(buttonContentHeight)
                    } else {
                        make.centerY.equalTo(buttonContentView)
                    }
                })
            }
        }
    }
}

//MARK: Add Content
public extension YXRegisterCodeAlertView {
    fileprivate func addContentViews() {
        addSubview(imageView)
        addSubview(textContentView)
        addSubview(textFieldContentView)
        addSubview(buttonContentView)
    }
    
    fileprivate func addTextLabels() {
        textContentView.addSubview(titleLabel)
        textContentView.addSubview(messageTextView)
        textContentView.addSubview(messageLabel)
        textContentView.addSubview(promptLabel)
    }
    
    @objc func addAction(_ action: YXRegisterCodeAlertAction) {
        if buttons.count >= 2 {
            return
        }
        
        let button = actionButton(with: action)
        buttonContentView.addSubview(button)
        buttons.append(button)
        actions.append(action)
    }
    
    @objc func addTextField(maxNum: UInt, handler: ((UITextField) -> Void)!) {
        if alertStyle == .document || textFields.count > 0 {
            return
        }
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(updateNumLabel), for: .editingChanged)
        textField.delegate = self
        textField.rx.text.subscribe { [weak self] (text) in
            self?.updateNumLabel()
            }.disposed(by: disposeBag)
        textFields.append(textField)
        handler(textField)
        
        textFieldContentView.addSubview(textFieldBackgroundView)
        textFieldContentView.addSubview(numLabel)
        
        textFieldMaxNum = maxNum
        numLabel.text = "0/\(textFieldMaxNum)"
        
        textFieldBackgroundView.snp.makeConstraints { (make) in
            make.height.equalTo(textFieldHeight)
            make.width.top.left.equalTo(textFieldContentView)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalTo(textFieldContentView)
            make.top.equalTo(textFieldBackgroundView.snp.bottom).offset(4)
        }
        
        textFieldBackgroundView.addSubview(textField)
    }
    
    @objc func addCustomView(_ customView: UIView) {
        self.customView = customView;
        addSubview(customView)
    }
}

extension YXRegisterCodeAlertView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        let textFieldText = textField.text ?? ""
        if textFieldText.characterLength() + string.characterLength() >= textFieldMaxNum {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [unowned self] in
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: Int(self.textFieldMaxNum))
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        } else if textFieldText.characterLength() + string.characterLength() >= textFieldMaxNum {
            var text = (textFieldText as NSString).substring(with: NSRange(location: 0, length: range.location))
            text += string
            textField.text = text.subString(toCharacterIndex: textFieldMaxNum)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: text.count)
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        }
        
        return true
        
    }
    
}
