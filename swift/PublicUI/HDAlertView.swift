//
//  HDAlertView.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/6/17.
//  Copyright © 2020 航电. All rights reserved.
//

//使用说明
//使用(view).showAlert || (vc).showAlert，可以选择block或者delegate，也可以获取let alert = HDAlertView(show...)，对alert public部分定制
//

import Foundation
import UIKit

public typealias HDAlertViewClickButtonBlock = ((_ alertView:HDAlertView, _ buttonIndex:Int) -> Void)?

extension UIResponder {
    
    //MARK: -提示框+按键，block
    public func showAlert(title: String, message: String?, cancelButtonTitle: String?, otherButtonTitle: String, clickButtonBlock: HDAlertViewClickButtonBlock) {
        if Thread.isMainThread {
            HDAlertView.show(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle, clickButtonBlock: clickButtonBlock)
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle, clickButtonBlock: clickButtonBlock)
            }
        }
    }
    
    //MARK: -提示框+多个按键，block
    public func showMultipleButtonsAlert(title: String, message: String?, cancelButtonTitle: String?, otherButtonTitles: [String], clickButtonBlock: HDAlertViewClickButtonBlock) {
        if Thread.isMainThread {
            let alertView = HDAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles)
            alertView.clickButtonBlock = clickButtonBlock
            alertView.show()
        } else {
            DispatchQueue.main.async {
                self.showMultipleButtonsAlert(title: title, message: message, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, clickButtonBlock: clickButtonBlock)
            }
        }
    }
    
    //MARK: -提示框+按键，delegate
    public func showAlert(title: String, message: String?, delegate: HDAlertViewDelegate, cancelButtonTitle: String?, otherButtonTitle: String) {
        if Thread.isMainThread {
            let alertView = HDAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: [otherButtonTitle])
            alertView.show()
        } else {
            DispatchQueue.main.async {
                self.showAlert(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle, otherButtonTitle: otherButtonTitle)
            }
        }
    }
    
    //MARK: -提示框+多个按键，delegate
    public func showMultipleButtonsAlert(title: String, message: String?, delegate: HDAlertViewDelegate, cancelButtonTitle: String?, otherButtonTitles: [String]) {
        if Thread.isMainThread {
            let alertView = HDAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles)
            alertView.show()
        } else {
            DispatchQueue.main.async {
                self.showMultipleButtonsAlert(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles)
            }
        }
    }
    
}

public enum YHAlertAnimationOptions {
    case none
    case zoom        // 放大-缩小-还原
    case topToCenter // 从上到中间
}

public protocol HDAlertViewDelegate {
    func alertView(alertView: HDAlertView, clickedButtonAtIndex: Int)
}

public class HDAlertView : UIView {

    public var delegate : HDAlertViewDelegate?
    public var animationOption:YHAlertAnimationOptions = .none
    
    // MARK: - Public Property
    // background
    public var visual = false {
        willSet(newValue) {
            if newValue == true {
                effectView.backgroundColor = UIColor.clear
            } else {
                effectView.backgroundColor = UIColor.VisualColor()
            }
        }
    }
    
    // backgroudColor
    public var visualBGColor = UIColor.VisualColor() {
        willSet(newValue){
             effectView.backgroundColor = newValue
        }
    }
    
    // MARK: - Private Property
    private let contentWidth: CGFloat  = .scaleW(300.0)
    private let contentHeight: CGFloat = .scaleW(150)
    
    /**处理delegate传值 */
    private var arrayButton: [UIButton] = []
    private var effectView: UIVisualEffectView!
    
    /**显示的数据 */
    private var _title: String!
    private var _message: String?
    private var _cancelButtonTitle: String?
    private var _otherButtonTitles: [String] = []
    
    /**public 都可修改 */
    public var contentView: UIView!
    public var labelTitle: UILabel!
    public var labelMessage: UILabel!
    public var clickButtonBlock: HDAlertViewClickButtonBlock?
    public var buttonTitleColors: [UIColor]?
    public var buttonBKColors: [UIColor]?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = UIView()
        contentView.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: contentHeight)
        contentView.center = CGPoint(x: HDConst.SCREENW / 2, y: HDConst.SCREENH / 2)
        contentView.backgroundColor = UIColor.white
        contentView.layer.borderColor = UIColor.TabbarTitleSelect().cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        labelTitle = UILabel()
        labelTitle.frame = CGRect(x: 16, y: 22, width: contentWidth - 32, height: 0)
        labelTitle.textColor = UIColor.BlackTitle()
        labelTitle.textAlignment = .center
        labelTitle.numberOfLines = 0
        labelTitle.font = UIFont.systemFont(ofSize: .scaleW(17), weight: .medium)

        labelMessage = UILabel()
        labelMessage.frame = CGRect(x: 16, y: 22, width: contentWidth - 32, height: 0)
        labelMessage.textColor = UIColor.black
        labelMessage.textAlignment = .center
        labelMessage.numberOfLines = 0
        labelMessage.lineBreakMode = .byTruncatingTail
        labelMessage.font = UIFont.systemFont(ofSize: .scaleW(15), weight: .regular)
        
        effectView = UIVisualEffectView()
        effectView.frame = CGRect(x: 0, y: 0, width: HDConst.SCREENW, height: HDConst.SCREENH)
        effectView.effect = nil
        effectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(title: String, message: String?, delegate: HDAlertViewDelegate?, cancelButtonTitle: String?, otherButtonTitles: [String]) {
        self.init()
        arrayButton = [UIButton]()
        
        //标题
        _title = title
        labelTitle.text = title
        
        let labelX:CGFloat = 16
        let labelY:CGFloat = 30
        let labelW:CGFloat = contentWidth - 2 * labelX
        labelTitle.sizeToFit()
        
        let size = labelTitle.frame.size
        labelTitle.frame = CGRect(x: labelX, y: labelY, width: labelW, height: size.height)
        
        //消息
        _message = message
        labelMessage.text = message
        labelMessage.sizeToFit()
        let sizeMessage = labelMessage.frame.size
        labelMessage.frame = CGRect(x: labelX, y: labelTitle.frame.maxY + 10, width: labelW, height: sizeMessage.height)
        
        self.delegate = delegate
        animationOption = .none
        _cancelButtonTitle = cancelButtonTitle
       
        for eachObject in otherButtonTitles {
            _otherButtonTitles.append(eachObject)
        }
        
        _setupDefault()
        _setupButton()
        
    }
    
    static func show(title: String, message: String?, cancelButtonTitle: String?, otherButtonTitles: String ... , clickButtonBlock: HDAlertViewClickButtonBlock) {
        let alertView = HDAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles)
        alertView.clickButtonBlock = clickButtonBlock
        alertView.show()
    }
    
    static func show(title: String, message: String?, cancelButtonTitle: String?, otherButtonTitle: String, clickButtonBlock: HDAlertViewClickButtonBlock) {
        let alertView = HDAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: [otherButtonTitle])
        alertView.clickButtonBlock = clickButtonBlock
        alertView.show()
    }
    
    // shows popup alert animated.
    open func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        switch animationOption {
            case .none:
                contentView.alpha = 0.0
                UIView.animate(withDuration: 0.34, animations: { [unowned self] in
                    if self.visual == true {
                        self.effectView.effect = UIBlurEffect(style: .dark)
                    }
                    self.contentView.alpha = 1.0
                })
            break
                
            case .zoom:
                self.contentView.layer.setValue(0, forKeyPath: "transform.scale")
                UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
                    [unowned self] in
                    if self.visual == true {
                        self.effectView.effect = UIBlurEffect(style: .dark)
                    }
                    self.contentView.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: { _ in
                    
                })

                break
            case .topToCenter:
                let startPoint = CGPoint(x: center.x, y: contentView.frame.height)
                contentView.layer.position = startPoint
                
                UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: { [unowned self] in
                    if self.visual == true {
                        self.effectView.effect = UIBlurEffect(style: .dark)
                    }
                    self.contentView.layer.position = self.center
                }, completion: { _ in
                    
                })
        
                break
        }
    }
    
    // MARK: - Private Method
    fileprivate func _setupDefault() {
        frame = CGRect(x: 0, y: 0, width: HDConst.SCREENW, height: HDConst.SCREENH)
        self.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        backgroundColor  = UIColor.clear
        visual = false
        animationOption = .zoom
        addSubview(effectView)
        addSubview(contentView)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(labelTitle)
        contentView.addSubview(labelMessage)
    }
    
    private func _setupButton() {
        let buttonY  = contentView.height - contentHeight / 3
        var countRow = 0
        
        if _cancelButtonTitle?.isEmpty == false {
            countRow = 1;
        }
        countRow += _otherButtonTitles.count
        
        switch countRow {
            case 0:
                contentView.addSubview(_button(frame: CGRect(x: 0, y: buttonY, width: contentWidth, height:contentHeight/3), title: "", target: self, action: #selector(_clickCancel(sender:)), index: 0))
               let height = contentHeight/2 + buttonY
                contentView.frame = CGRect(x: 0, y: 0, width:contentWidth, height: height)
                contentView.center = self.center
                
            break
            
            case 2:
                var titleCancel: String
                var titleOther: String
                if _cancelButtonTitle?.isEmpty == false {
                    titleCancel = _cancelButtonTitle ?? ""
                    titleOther  = _otherButtonTitles[0]
                } else {
                    titleCancel = _otherButtonTitles[0]
                    titleOther  = _otherButtonTitles.last!
                }
               
                let width = (contentWidth - 30) / 2
                let buttonCancel = _button(frame:  CGRect(x: 10, y: buttonY, width: width, height: contentHeight / 3 - 10), title: titleCancel, target: target, action: #selector(_clickCancel(sender:)), index: 0)
                let buttonOther = _button(frame: CGRect(x: width + 20, y: buttonY, width: width, height: contentHeight/3 - 10), title: titleOther, target: self, action: #selector(_clickOther(sender:)), index: 1)
                
                buttonCancel.layer.borderWidth = 1
                buttonCancel.layer.borderColor = UIColor.TabbarTitleSelect().cgColor
                buttonCancel.layer.cornerRadius = 5
                buttonCancel.layer.masksToBounds = true
                buttonCancel.setTitleColor(UIColor.TabbarTitleSelect(), for: .normal)
                
                buttonOther.layer.borderWidth = 1
                buttonOther.layer.borderColor = UIColor.TabbarTitleSelect().cgColor
                buttonOther.layer.cornerRadius = 5
                buttonOther.layer.masksToBounds = true
                buttonOther.setTitleColor(UIColor.WhiteToBlack(), for: .normal)
                buttonOther.backgroundColor = .TabbarTitleSelect()
                
                contentView.addSubview(buttonOther)
                contentView.addSubview(buttonCancel)
            
                let height = contentHeight / 3 + buttonY
                contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: height)
                contentView.center = self.center
        
            break
            
        default:
            for number in 0..<countRow {
                var title = ""
                var selector:Selector
                if _otherButtonTitles.count > number {
                    title = _otherButtonTitles[number]
                    selector = #selector(_clickOther(sender:))
                } else {
                    title = _cancelButtonTitle ?? ""
                    selector = #selector(_clickCancel(sender:))
                }
                let button = _button(frame: CGRect(x: 0, y: (CGFloat(number) * contentHeight / 2 + buttonY), width: contentWidth, height: contentHeight / 3), title: title, target: self, action: selector, index: number)
                arrayButton.append(button)
                contentView.addSubview(button)
            }
            
            var height = contentHeight / 2 + buttonY
            if countRow > 2 {
                height = CGFloat(countRow) * (contentHeight / 2) + buttonY
            }
            contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: height)
            contentView.center = self.center
       
            break
        }
    }

    private func _image(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func _button(frame: CGRect, title: String, target: Any, action: Selector, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        if let titleColor = buttonTitleColors?[index] {
            button.setTitleColor(titleColor, for: .normal)
        } else {
            button.setTitleColor(UIColor.init(red: 70.0/255, green: 130.0/255, blue: 233.0/255, alpha: 1.0), for: .normal)
        }
        button.setTitle(title, for: .normal)
        button.setBackgroundImage(_image(color: UIColor.init(red: 235.0/255, green: 235.0/255, blue: 235.0/255, alpha: 1.0)), for: .highlighted)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(target, action: action, for: .touchUpInside)
        let lineUp = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5))
        if let bkColor = buttonBKColors?[index] {
            button.backgroundColor = bkColor
        } else {
            lineUp.backgroundColor = UIColor.init(red: 219.0/255, green: 219.0/255, blue: 219.0/255, alpha: 1.0)
        }
        let lineRight = UIView(frame: CGRect(x: frame.size.width, y:  0, width: 0.5, height: frame.size.height))
        lineRight.backgroundColor = UIColor.init(red: 219.0/255, green: 219.0/255, blue: 219.0/255, alpha: 1.0)
        button.addSubview(lineUp)
        button.addSubview(lineRight)
        return button
    }
    
    private func _remove() {
            switch animationOption {
                case .none:
                    UIView.animate(withDuration: 0.3, animations: {
                        [unowned self] in
                        if self.visual == true {
                            self.effectView.effect = nil
                        }
                        self.contentView.alpha = 0.0
                        }, completion: { [unowned self] (finished:Bool) in
                        self.removeFromSuperview()
                    })
                 
                break
                    
                case .zoom:
                    UIView.animate(withDuration: 0.3, animations: {
                        self.contentView.alpha = 0.0
                        if self.visual == true {
                            self.effectView.effect = nil
                        }
                    }, completion: { [unowned self] (finished:Bool) in
                        self.removeFromSuperview()
                    })

                break
                
                case .topToCenter:
                    let endPoint = CGPoint(x: center.x, y: frame.height + contentView.frame.height)
                    UIView.animate(withDuration: 0.3, animations: {
                        if self.visual == true {
                            self.effectView.effect = nil
                        }
                        self.contentView.layer.position = endPoint
                    }, completion: {[unowned self] (finished:Bool)in
                        self.removeFromSuperview()
                    })
                break

            }
    }
    
    // MARK: - Action
    @objc func _clickOther(sender:UIButton) {
        var buttonIndex: Int = 0
        if _cancelButtonTitle?.isEmpty == false {
            buttonIndex = 1
        }
        if arrayButton.count > 0 {
            buttonIndex += arrayButton.firstIndex(of: sender) ?? 0
        }
     
        delegate?.alertView(alertView: self, clickedButtonAtIndex: buttonIndex)
        if let aBlock = clickButtonBlock {
            aBlock!(self, buttonIndex)
        }
        _remove()
    }

    @objc func _clickCancel(sender:UIButton) {
        delegate?.alertView(alertView: self, clickedButtonAtIndex: 0)
        if let aBlock = clickButtonBlock {
            aBlock!(self, 0)
        }
        _remove()
    }
    
    // MARK: - Life
    deinit {

    }
}
