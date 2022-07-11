//
//  YXAlertView.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/2/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit
import TYAlertController
import RxSwift
import RxCocoa

@objcMembers public class YXAlertAction: NSObject {
    
    @objc public enum YXAlertActionStyle: Int {
        case `default`, cancel, destructive, fullDefault, fullCancel, fullDestructive
    }
    
    fileprivate var title: String?
    fileprivate var style: YXAlertActionStyle = .default
    fileprivate var handler: ((YXAlertAction) -> Void)?

    @objc public class func action(title: String, style: YXAlertActionStyle, handler: @escaping ((YXAlertAction) -> Void)) -> YXAlertAction {
        return YXAlertAction(title: title, style: style, handler: handler)
    }

    public convenience init(title: String?, style: YXAlertActionStyle, handler: @escaping ((YXAlertAction) -> Void)) {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }
}

@objcMembers public class YXAlertController: TYAlertController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertViewOriginY = (YXConstant.screenHeight - alertView.bounds.size.height - 55)/2;
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        if (alertView is YXAlertView) {
            let textFieldArray = (alertView as? YXAlertView)?.textFields
            if textFieldArray?.count == 1 {
                let textField = textFieldArray?.first
                textField?.becomeFirstResponder()
            }
        }
    }
}


@objcMembers public class YXAlertView: UIView {
    
    let horizontalMargin = 16
    let verticalMargin = 20
    let buttonContentHeight = 48
    let textFieldContentHeight = 78
    let textFieldHeight = 36
    let messageTextViewMaxHeight = 160
    let defaultWidth = 285
    let appType = YXConstant.appTypeValue
    
    let buttonTagOffset = 1000
    
    let disposeBag = DisposeBag()
    
    private struct AlertColor {
        static var _defaultTextColor = UIColor(red: 47/255.0, green: 121/255.0, blue: 255/255.0, alpha: 1.0)
        static var _defaultTintColor = UIColor(red: 13/255.0, green: 80/255.0, blue: 216/255.0, alpha: 1.0)
        static var _disableColor = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 0.2)
        static var _textColorLevel1 = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 1.0)
        static var _textColorLevel2 = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 0.5)
        static var _separatorLineColor = UIColor(red: 25/255.0, green: 25/255.0, blue: 25/255.0, alpha: 0.05)
        static var _backgroundColor = UIColor.white
        
        static var _cancelBorderColor = UIColor(red: 42/255.0, green: 42/255.0, blue: 52/255.0, alpha: 1.0)
    }
    
    @objc public class var defaultTextColor: UIColor {
        get { return AlertColor._defaultTextColor }
        set { AlertColor._defaultTextColor = newValue }
    }

    @objc public class var defaultTintColor: UIColor {
        get { return AlertColor._defaultTintColor }
        set { AlertColor._defaultTintColor = newValue }
    }

    @objc public class var disableColor: UIColor {
        get { return AlertColor._disableColor }
        set { AlertColor._disableColor = newValue }
    }

    @objc public class var textColorLevel1: UIColor {
        get { return AlertColor._textColorLevel1 }
        set { AlertColor._textColorLevel1 = newValue }
    }

    @objc public class var textColorLevel2: UIColor {
        get { return AlertColor._textColorLevel2 }
        set { AlertColor._textColorLevel2 = newValue }
    }

    @objc public class var separatorLineColor: UIColor {
        get { return AlertColor._separatorLineColor }
        set { AlertColor._separatorLineColor = newValue }
    }
    
    @objc public class var backgroundColor: UIColor? {
        get { return AlertColor._backgroundColor }
        set { AlertColor._backgroundColor = newValue ?? .white }
    }
    
    @objc public class var cancelBorderColor: UIColor {
        get { return AlertColor._cancelBorderColor }
        set { AlertColor._cancelBorderColor = newValue }
    }
    
    @objc public enum YXAlertStyle: Int {
        case `default`, document
    }
    
    @objc public var clickedAutoHide: Bool = true
    
    @objc public var textField: UITextField? {
        get {
            return self.textFields.first
        }
    }

    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.textColorLevel1
        if appType == .OVERSEA || appType == .OVERSEA_SG {
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        } else {
            label.font = .systemFont(ofSize: 16)
        }
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = Self.textColorLevel1
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        return textView
    }()
    
    @objc public lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.textColorLevel1
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
//        if appType == .OVERSEA || appType == .OVERSEA_SG {
//            label.font = .systemFont(ofSize: 16, weight: .semibold)
//        }
        label.numberOfLines = 0
        return label
    }()

    @objc public lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.textColorLevel2
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
        view.layer.borderColor = Self.separatorLineColor.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    fileprivate lazy var numLabel: UILabel = {
        let label = UILabel()
        label.textColor = Self.textColorLevel2
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
    
    fileprivate lazy var actions: [YXAlertAction] = {
        let actions = [YXAlertAction]()
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
    
    var alertStyle: YXAlertStyle = .default
    var textFieldMaxNum: UInt = 0
    var customView: UIView?
    
    @objc public class func alertView(message: String) -> YXAlertView {
        return YXAlertView(message: message)
    }
    
    @objc public class func alertView(title: String?, message: String?) -> YXAlertView {
        return YXAlertView(title:title, message: message)
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
                
                if title == nil || title?.count == 0  {
                    messageLabel.textColor = Self.textColorLevel1
                } else {
                    messageLabel.textColor = Self.textColorLevel2
                }
            } else {
                messageTextView.text = message
                promptLabel.textAlignment = .center
                promptLabel.font = .systemFont(ofSize: 14)
                titleLabel.font = .systemFont(ofSize: 20)
            }
        }
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Self.backgroundColor
        layer.cornerRadius = 10
        
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
extension YXAlertView {
    fileprivate func actionButton(with action: YXAlertAction) -> UIButton{
        let button = UIButton(type: .custom)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        if appType == .OVERSEA || appType == .OVERSEA_SG {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        button.tag = buttonTagOffset + buttons.count
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true

        let style = action.style
        switch style {
        case .default:
            button.setTitleColor(Self.defaultTextColor, for: .normal)
            if appType == .OVERSEA || appType == .OVERSEA_SG  {
                button.clipsToBounds = true
                button.layer.cornerRadius = 4
                button.backgroundColor = Self.defaultTintColor
                button.setTitleColor(.white, for: .normal)
            }
            break;
        case .cancel:
            button.setTitleColor(Self.textColorLevel2, for: .normal)
            if appType == .OVERSEA || appType == .OVERSEA_SG {
                button.clipsToBounds = true
                button.layer.cornerRadius = 4
                button.layer.borderColor = Self.cancelBorderColor.cgColor
                button.setTitleColor(Self.textColorLevel1, for: .normal)
                button.layer.borderWidth = 1
                
            }
            break;
        case .destructive:
            button.setTitleColor(.red, for: .normal)
            break;
        case .fullDefault:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = Self.defaultTintColor
            button.setTitleColor(.white, for: .normal)
            break;
        case .fullCancel:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = Self.disableColor
            button.setTitleColor(.white, for: .normal)
            break;
        case .fullDestructive:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = .red
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
            var l = text.characterLength()
            if l > textFieldMaxNum {
                l = Int(textFieldMaxNum)
            }
            numLabel.text = "\(l)/\(textFieldMaxNum)"
        } else {
            numLabel.text = "0/\(textFieldMaxNum)"
        }
    }
}

//MARK: Layout
extension YXAlertView {
    override public func didMoveToSuperview() {
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
            make.top.equalTo(verticalMargin)
           
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
                    make.top.equalTo(titleLabel.snp.bottom).offset(verticalMargin/4)
                }
                
                promptLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(textContentView)
                    make.top.equalTo(messageLabel.snp.bottom).offset(verticalMargin/4)
                    make.bottom.equalTo(textContentView.snp.bottom).offset(-verticalMargin/2)
                }
            } else {
                if appType == .OVERSEA || appType == .OVERSEA_SG {
                    messageLabel.snp.makeConstraints { (make) in
                        make.left.right.equalTo(textContentView)
                        make.top.equalTo(titleLabel.snp.bottom).offset(verticalMargin/4)
                        make.bottom.equalToSuperview()
                    }
                }else {
                    messageLabel.snp.makeConstraints { (make) in
                        make.left.right.equalTo(textContentView)
                        make.top.equalTo(titleLabel.snp.bottom).offset(verticalMargin/4)
                        make.bottom.equalTo(textContentView.snp.bottom).offset(-verticalMargin)
                    }
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
                    make.height.equalTo(buttonContentHeight)
                    if appType == .OVERSEA || appType == .OVERSEA_SG {
                        make.height.equalTo(76)
                    }
                }
            })
            
            if alertStyle == .default {
                let line = UIView()
                line.backgroundColor = Self.separatorLineColor
                buttonContentView.addSubview(line)
                
                line.snp.makeConstraints { (make) in
                    make.top.left.right.equalTo(buttonContentView)
                    make.height.equalTo(1)
                }
                if appType == .OVERSEA || appType == .OVERSEA_SG  {
                    line.isHidden = true
                }
            }
            
            if buttons.count == 2 {
                buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: CGFloat(horizontalMargin), leadSpacing: CGFloat(horizontalMargin), tailSpacing: CGFloat(horizontalMargin))
                buttons.snp.makeConstraints { (make) in
                    if alertStyle == .document {
                        make.top.equalTo(buttonContentView)
                        make.height.equalTo(buttonContentHeight)
                    } else {
                        make.centerY.equalTo(buttonContentView)
                        if appType == .OVERSEA || appType == .OVERSEA_SG  {
                            make.height.equalTo(36)
                        }
                    }
                }
                
                if alertStyle == .default {
                    let line = UIView()
                    line.backgroundColor = Self.separatorLineColor
                    buttonContentView.addSubview(line)

                    line.snp.makeConstraints { (make) in
                        make.center.height.equalTo(buttonContentView)
                        make.width.equalTo(1)
                    }
                    if appType == .OVERSEA || appType == .OVERSEA_SG  {
                        line.isHidden = true
                    }
                }
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
                        if appType == .OVERSEA || appType == .OVERSEA_SG {
                            make.height.equalTo(36)
                        }
                    }
                })
            }
        }
    }
}

//MARK: Add Content
extension YXAlertView {
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
    
    @objc public func addAction(_ action: YXAlertAction) {
        if buttons.count >= 2 {
            return
        }
        
        let button = actionButton(with: action)
        buttonContentView.addSubview(button)
        buttons.append(button)
        actions.append(action)
    }
    
    @objc public func addTextField(maxNum: UInt, handler: ((UITextField) -> Void)!) {
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
    
    @objc public func addCustomView(_ customView: UIView) {
        self.customView = customView;
        addSubview(customView)
    }
}

extension YXAlertView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        if (range.length == 1 && string.count == 0) {
            return true
        }
        let textFieldText = textField.text ?? ""
        let str = string
        
        var text = (textFieldText as NSString).substring(with: NSRange(location: 0, length: range.location))
        let lastText = (textFieldText as NSString).substring(from: range.location + range.length)

        if (text.characterLength() + lastText.characterLength()) >= textFieldMaxNum {
            return false
        }
        
        var offset = Int(self.textFieldMaxNum)
        text += string
        if text.characterLength() < offset {
            offset = text.count
        }

        if textFieldText.characterLength() == textFieldMaxNum {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: offset)
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        } else if textFieldText.characterLength() + str.characterLength() >= textFieldMaxNum {
            text += lastText
            textField.text = text.subString(toCharacterIndex: textFieldMaxNum)
            updateNumLabel()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let startPosition: UITextPosition? = textField.position(from: textField.beginningOfDocument, offset: offset)
                if let startPosition = startPosition {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: startPosition)
                }
            })
            return false
        }
        
        return true
    }
}
