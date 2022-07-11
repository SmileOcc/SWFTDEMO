//
//  YXUpdateAlertView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers public class YXUpdateAlertAction: NSObject {
    
    @objc public enum YXUpdateAlertActionStyle: Int {
        case `default`, cancel, destructive, fullDefault, fullCancel, fullDestructive
    }
    
    fileprivate var title: String?
    fileprivate var style: YXUpdateAlertActionStyle = .default
    fileprivate var handler: ((YXUpdateAlertAction) -> Void)?

    @objc public class func action(title: String, style: YXUpdateAlertActionStyle, handler: @escaping ((YXUpdateAlertAction) -> Void)) -> YXUpdateAlertAction {
        return YXUpdateAlertAction(title: title, style: style, handler: handler)
    }

    public convenience init(title: String?, style: YXUpdateAlertActionStyle, handler: @escaping ((YXUpdateAlertAction) -> Void)) {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class YXUpdateAlertView: UIView {

    let horizontalMargin = 16
    let verticalMargin = 16
    let buttonContentHeight = 48
    let messageTextViewMaxHeight = 120
    let defaultWidth = Int(uniHorLength(315)) //285
    
    let buttonTagOffset = 1000
    
    //let disposeBag = DisposeBag()
    
    @objc public var defaultTextColor = UIColor.qmui_color(withHexString: "#2F79FF")
    @objc public var defaultTintColor = UIColor.qmui_color(withHexString: "#0D50D8")
    @objc public var disableColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.2)
    @objc public var textColorLevel1 = UIColor.qmui_color(withHexString: "#2A2A34")
    @objc public var textColorLevel2 = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.5)
    @objc public var separatorLineColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.05)
    
    @objc public var clickedAutoHide: Bool = true
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = textColorLevel1
        label.font = .systemFont(ofSize: uniHorLength(18), weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    @objc public lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "img_update")
        return imageView
    }()
    
    fileprivate lazy var buttons: [UIButton] = {
        let buttons = [UIButton]()
        return buttons
    }()
    
    fileprivate lazy var actions: [YXUpdateAlertAction] = {
        let actions = [YXUpdateAlertAction]()
        return actions
    }()
    
    fileprivate lazy var textContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var buttonContentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var textScrollContentView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        return view
    }()
    
    @objc public convenience init(title: String? = nil, message: String, prompt: String? = nil) {
        self.init(frame: .zero)
        
        titleLabel.text = (title ?? "") + (prompt ?? "")
//        promptLabel.text = prompt
//        let pattern = "\\[(.*?)\\]"
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
//            return
//        }
//        let matches = regex.matches(in: message, options: [], range: NSMakeRange(0, message.count))
//        let ranges = matches.map { (match) -> NSRange in
//            return match.range
//        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = uniHorLength(8)
        let attStr = NSMutableAttributedString(string: message, attributes: [.foregroundColor: textColorLevel1!, .font: UIFont.systemFont(ofSize: 14,weight: .regular), .paragraphStyle: paragraphStyle])
//        ranges.forEach { (range) in
//            attStr.addAttributes([.foregroundColor:UIColor.qmui_color(withHexString: "#414FFF")!, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], range: range)
//        }
        messageTextView.attributedText = attStr
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.yx_setOnlyLightStyle()
        layer.cornerRadius = 6
        layer.masksToBounds = true
        backgroundColor = .white
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

//MARK: Add Content
extension YXUpdateAlertView {
    fileprivate func addContentViews() {
        addSubview(imageView)
        addSubview(textContentView)
        addSubview(buttonContentView)
    }
    
    fileprivate func addTextLabels() {
        addSubview(titleLabel)
        addSubview(promptLabel)
        textContentView.addSubview(messageTextView)
    }
    
    @objc public func addAction(_ action: YXUpdateAlertAction) {
        if buttons.count >= 2 {
            return
        }
        
        let button = actionButton(with: action)
        buttonContentView.addSubview(button)
        buttons.append(button)
        actions.append(action)
    }
}

//MARK: Method
extension YXUpdateAlertView {
    fileprivate func actionButton(with action: YXUpdateAlertAction) -> UIButton{
        let button = UIButton(type: .custom)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tag = buttonTagOffset + buttons.count
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3

        let style = action.style
        switch style {
        case .default:
            button.setTitleColor(defaultTextColor, for: .normal)
            break;
        case .cancel:
            button.setTitleColor(textColorLevel2, for: .normal)
            break;
        case .destructive:
            button.setTitleColor(.red, for: .normal)
            break;
        case .fullDefault:
            button.setTitleColor(.white, for: .normal)
            button.clipsToBounds = true
            button.layer.cornerRadius = 4
            button.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")
            break;
        case .fullCancel:
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = disableColor
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
}

//MARK: Layout
extension YXUpdateAlertView {
    override public func didMoveToSuperview() {
        if self.superview != nil {
            layoutContentViews()
            layoutTextLabels()
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
        
        self.imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
        }
        
        textContentView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
           
        }
        textContentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func layoutTextLabels() {
        if titleLabel.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(uniHorLength(40))
            make.right.equalTo(uniHorLength(-40))
            make.top.equalTo(imageView.snp.bottom).offset(uniHorLength(-8))
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var messageHeight = Int(messageTextView.attributedText.boundingRect(with: CGSize(width: defaultWidth - horizontalMargin * 2, height:Int.max), options: .usesLineFragmentOrigin, context: nil).size.height)
        if messageHeight > messageTextViewMaxHeight{
            messageHeight = messageTextViewMaxHeight
        }
        messageTextView.snp.makeConstraints { (make) in
            make.left.equalTo(textContentView).offset(horizontalMargin)
            make.right.equalTo(textContentView).offset(-horizontalMargin)
            make.top.equalTo(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(messageHeight)
        }

        
//        if let text = promptLabel.text, text.count > 0 {
//            promptLabel.snp.makeConstraints { (make) in
//                make.left.equalTo(titleLabel)
//                make.top.equalTo(titleLabel.snp.bottom)
//            }
//
//            var messageHeight = Int(messageTextView.attributedText.boundingRect(with: CGSize(width: defaultWidth - horizontalMargin * 2, height:Int.max), options: .usesLineFragmentOrigin, context: nil).size.height) + verticalMargin
//            if messageHeight > messageTextViewMaxHeight + verticalMargin {
//                messageHeight = messageTextViewMaxHeight + verticalMargin
//            }
//
//            messageTextView.snp.makeConstraints { (make) in
//                make.left.equalTo(textContentView).offset(horizontalMargin)
//                make.right.equalTo(textContentView).offset(-horizontalMargin)
//                //make.top.equalToSuperview().offset(verticalMargin/2)
//                make.top.equalTo(0)
//                make.bottom.equalToSuperview().offset(-verticalMargin/2)
//                make.height.equalTo(messageHeight)
//            }
//        }
    }
    
    fileprivate func layoutButtonContentView() {
        if buttonContentView.translatesAutoresizingMaskIntoConstraints == false {
            return
        }
        
        buttonContentView.snp.makeConstraints { (make) in
            make.top.equalTo(textContentView.snp.bottom).offset(14)
            make.left.right.equalTo(self)
            make.height.equalTo(0)
        }
        
        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
        
        if (buttons.count > 0) {
            buttonContentView.snp.updateConstraints({ (make) in
                make.height.equalTo(buttonContentHeight + 15)
            })
            
            if buttons.count == 2 {
                buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: CGFloat(horizontalMargin), leadSpacing: CGFloat(horizontalMargin), tailSpacing: CGFloat(horizontalMargin))
                buttons.snp.makeConstraints { (make) in
                    make.top.equalTo(buttonContentView)
                    make.height.equalTo(buttonContentHeight)
                }
                
            } else if buttons.count == 1 {
                let button = buttons.first
                button?.snp.makeConstraints({ (make) in
                    make.left.equalTo(self).offset(horizontalMargin)
                    make.right.equalTo(self).offset(-horizontalMargin)
                    make.top.equalTo(buttonContentView)
                    make.height.equalTo(buttonContentHeight)
                })
            }
        }
    }
}

