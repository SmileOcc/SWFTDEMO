//
//  OSSVAlertsViewNew.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/27.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

public typealias calertBlock = (_ index:NSInteger,_ buttonTitle: String)->Void
typealias calertCancelBlock = ()->Void

let alert_screenWidth = UIScreen.main.bounds.width
let alert_screenHeight = UIScreen.main.bounds.height
let alert_screenSpace: CGFloat = alert_screenWidth < 375 ? 25.0 : 36.0
let alert_contentSpace: CGFloat = 20.0
let alert_titleSpace: CGFloat = 40.0
let alert_space8: CGFloat = 8

let alert_horizontalSpace: CGFloat = 12.0
let alert_lineHeight: CGFloat = 1.0
let alert_lineColor: UIColor = OSSVThemesColors.col_CCCCCC()
let alert_labelColor: UIColor = OSSVThemesColors.col_0D0D0D()
let alert_contentColor: UIColor = OSSVThemesColors.col_0D0D0D()
let alert_buttonTitleNorColor: UIColor = OSSVThemesColors.col_0D0D0D()
let alert_buttonTitleHeightColor: UIColor = OSSVThemesColors.stlWhiteColor()
let alert_buttonBgDisabledColor: UIColor = OSSVThemesColors.col_CCCCCC()
let alert_buttonBgColor: UIColor = OSSVThemesColors.stlWhiteColor()
let alert_buttonBgHeightColor: UIColor = OSSVThemesColors.col_0D0D0D()
let alert_buttonBorderColor: UIColor = OSSVThemesColors.col_CCCCCC()

let alert_buttonHeight: CGFloat = 36.0


func alert_fontDefault(fontSize: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize)
}


@objc public enum STLAlertType : Int {
    case normal = 0
    case button
    case buttonColumn
    case input
}


class OSSVAlertsViewNew: UIView {


    var alertCallBlock: calertBlock?
    var alertCallCancelBlock: calertCancelBlock?
    ///高亮显示
    var alertHeightIndex:NSInteger = 0
    var cancelTitle: String?
    
    var contentView : UIView?
    lazy var closeButton: UIButton = {
        let button  = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "close_18"), for: .normal)
        button.addTarget(self, action: #selector(colseAction(sender:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 12, left: 6, bottom: 0, right: 6)
        return button
    }()
    
    @objc func colseAction(sender: UIButton) {
        if let cancelBlock = self.alertCallCancelBlock {
            cancelBlock()
        }
        self.dismissAlertView()
    }
    
    lazy var alertAllButtonArr: NSMutableArray = {
        var btnArray: NSMutableArray = NSMutableArray.init()
        return btnArray
    }()
    
    func layoutTitleAndMessage(title:Any?, message:Any?, messageAlignment: NSTextAlignment, isAr:Bool) -> CGFloat {
        let contentW = alert_screenWidth-alert_screenSpace*2.0
        let rect = CGRect(x: alert_screenSpace, y: 0, width: contentW, height: 0)
        
        let contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.white
        if app_type == 3 {
            
        } else {
            contentView.layer.cornerRadius = 6.0
            contentView.layer.masksToBounds = true
        }
        self.addSubview(contentView)
        self.contentView = contentView
        
        if self.alertCallCancelBlock != nil {
            //按钮扩展了内容区域
            self.contentView?.addSubview(self.closeButton)
            self.closeButton.snp.makeConstraints { make in
                make.top.equalTo(self.contentView!.snp.top)
                make.trailing.equalTo(self.contentView!.snp.trailing).offset(-6)
            }
        }
        
        ///有关闭按钮时，现在是默认显示 标题的位置高度20，只是隐藏
        var lastLabMaxY: CGFloat = 0
        let labelWidth = contentW - alert_contentSpace*2
        let titleWidth = contentW - alert_titleSpace*2

        
        var titleLabel: UILabel?
        var hasContent = OSSVAlertsViewNew.isContainContent(content: title)
        
        if hasContent {
            titleLabel = UILabel(frame: CGRect.zero)
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.textColor = alert_labelColor
            titleLabel?.textAlignment = .center
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel?.numberOfLines = 0
            //titleLabel?.backgroundColor = STLRandomColor()
            contentView.addSubview(titleLabel!)
            
            if let strTitle = title as? String {
                titleLabel?.text = strTitle
            } else if let attrTitle = title as? NSAttributedString {
                titleLabel?.attributedText = attrTitle
            }
            
            let titleHeight = OSSVAlertsViewNew.calculateTextHeight(font: titleLabel!.font!, width: titleWidth, textObject: title as Any)
            titleLabel?.frame = CGRect(x: alert_titleSpace, y: alert_contentSpace, width: titleWidth, height: titleHeight)
            lastLabMaxY = !(message is NSNull) ? titleLabel!.frame.maxY : titleLabel!.frame.maxY+alert_contentSpace
            
        }
        
        if !hasContent && self.alertCallCancelBlock != nil {
            ///有关闭按钮时，现在是默认显示 标题的位置高度19
            hasContent = true
            lastLabMaxY = 19+alert_contentSpace
        }
        
        if OSSVAlertsViewNew.isContainContent(content: message) {

//            let messageFont: UIFont = hasContent ? alert_fontDefault(fontSize: 14) : alert_fontDefault(fontSize: 14)
//            let messageColor: UIColor = hasContent ? alert_contentColor : alert_labelColor
//
            let messageFont: UIFont = alert_fontDefault(fontSize: 14)
            let messageColor: UIColor = alert_contentColor
            
            
            var msgObject = message
            
            let messageLab: UILabel = UILabel.init()
            messageLab.backgroundColor = UIColor.clear
            messageLab.textColor = messageColor
            messageLab.font = messageFont
            messageLab.numberOfLines = 0
            //messageLab.backgroundColor = STLRandomColor()
            
            if let strMessage = message as? String {
                let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
                paragraph.lineSpacing = OSSVAlertsViewNew.lineSpace()
                let messageAttr: NSAttributedString = NSAttributedString(string: strMessage, attributes: [NSAttributedString.Key.font: messageFont,NSAttributedString.Key.foregroundColor:messageColor,NSAttributedString.Key.paragraphStyle: paragraph])
                
                msgObject = messageAttr
                messageLab.attributedText = messageAttr
                
            } else if let attrMessage = message as? NSAttributedString {
                messageLab.attributedText = attrMessage
            }
            messageLab.numberOfLines = 0

            
            let messageMaxHeight = alert_screenHeight * 0.6
            let msgHeight = OSSVAlertsViewNew.calculateTextHeight(font: messageLab.font, width: labelWidth, textObject: msgObject as Any)
            let messageLabY = hasContent ? lastLabMaxY + alert_space8 : alert_contentSpace
            
            if msgHeight > messageMaxHeight {
                let scrollView:UIScrollView = UIScrollView.init(frame: CGRect.init(x: alert_contentSpace, y: messageLabY, width: labelWidth, height: messageMaxHeight))
                scrollView.contentSize = CGSize.init(width: labelWidth, height: msgHeight)
                contentView.addSubview(scrollView)
                messageLab.frame = CGRect.init(x: 0, y: 0, width: labelWidth, height: msgHeight)
                scrollView.addSubview(messageLab)
                lastLabMaxY = scrollView.frame.maxY + alert_contentSpace
            } else {
                messageLab.frame = CGRect.init(x: alert_contentSpace, y: messageLabY, width: labelWidth, height: msgHeight)
                lastLabMaxY = messageLab.frame.maxY + alert_contentSpace
                if msgHeight < 250 {
                    messageLab.textAlignment = NSTextAlignment.center
                }
                contentView.addSubview(messageLab)
            }
            
            ///是否需要阿语显示
            if isAr && OSSVSystemsConfigsUtils.isRightToLeftShow() {
                messageLab.textAlignment = NSTextAlignment.right
            }
        } else {
            lastLabMaxY += 12
        }
        
        contentView.bounds = CGRect.init(x: 0, y: 0, width: contentW, height: lastLabMaxY)
        contentView.center = self.center
        
        return lastLabMaxY
    }
    
    func layoutAlertButton(allTitleArrays titleArrays:NSArray, buttonFormateType formatType: STLAlertType, contentView:UIView, lastUImaxY lastMaxY: CGFloat, isVertical vertical: Bool, buttonAction buttonSelector: Selector?) {
        if titleArrays.count == 0 {
            return
        }
        
        
        var lastBtnMaxY = lastMaxY
        let contentW = alert_screenWidth - alert_screenSpace*2.0
        let btnSuperView = contentView
        
        if formatType == STLAlertType.button || formatType == STLAlertType.buttonColumn {
            
            let buttonAllContentW = contentW - alert_contentSpace * 2.0
            
            for index in 0...titleArrays.count-1 {
                let actionButton: UIButton = UIButton.init(type: .custom)
                actionButton.backgroundColor = UIColor.white
                if app_type == 3 {
                    actionButton.titleLabel?.font = UIFont.stl_buttonFont(14)
                } else {
                    actionButton.titleLabel?.font = UIFont.stl_buttonFont(12)
                }
                actionButton.titleLabel?.lineBreakMode = .byTruncatingTail
                
                actionButton.addTarget(self, action: buttonSelector ?? #selector(alertBtnAction(sender:)), for: .touchUpInside)
                actionButton.isExclusiveTouch = true
                
                ///高亮显示
                if index == self.alertHeightIndex {
                    contentView.addSubview(actionButton)
                    actionButton.setTitleColor(alert_buttonTitleHeightColor, for: .normal)
                    actionButton.setBackgroundImage(OSSVAlertsViewNew.imageWithColor(color: alert_buttonBgHeightColor), for: .normal)
                } else {
                    actionButton.layer.borderWidth = 1.0
                    actionButton.layer.borderColor = alert_buttonBorderColor.cgColor
                    actionButton.setTitleColor(alert_buttonTitleNorColor, for: .normal)
                    btnSuperView.addSubview(actionButton)
                }
                actionButton.tag = 2021+index

                ///按钮标题
                let btnTitleObject = titleArrays[index]
                if let strBtnTitle = btnTitleObject as? String {
                    actionButton.setTitle(strBtnTitle, for: .normal)
                    
                } else if let attrBtnTitle = btnTitleObject as? NSAttributedString {
                    actionButton.titleLabel?.numberOfLines = 0
                    actionButton.titleLabel?.textAlignment = .center
                    actionButton.setAttributedTitle(attrBtnTitle, for: .normal)
                }
                
                self.alertAllButtonArr.add(actionButton)
                let lineY = lastMaxY
                
                ///按钮数大于3个 或 按钮设置垂直排列
                if titleArrays.count > 2 || formatType == STLAlertType.buttonColumn {
                    if index == self.alertHeightIndex {
                        actionButton.setTitleColor(alert_buttonTitleHeightColor, for: .normal)
                        actionButton.setBackgroundImage(OSSVAlertsViewNew.imageWithColor(color: alert_buttonBgHeightColor), for: .normal)
                    } else {
                        actionButton.setTitleColor(alert_buttonTitleNorColor, for: .normal)
                        actionButton.setBackgroundImage(OSSVAlertsViewNew.imageWithColor(color: alert_buttonBgColor), for: .normal)
                        actionButton.layer.borderColor = alert_buttonBorderColor.cgColor
                        actionButton.layer.borderWidth = 1.0
                    }
                    
                    let btnY = lastBtnMaxY > 0 ? lastBtnMaxY : lineY
                    actionButton.frame = CGRect.init(x: alert_contentSpace, y: btnY, width: buttonAllContentW, height: alert_buttonHeight)
                    lastBtnMaxY = actionButton.frame.maxY + alert_space8
                    
                } else {//水平显示
                    let btnY = lastMaxY
                    let btnW = titleArrays.count == 2 ? (buttonAllContentW - alert_horizontalSpace) / 2.0 : buttonAllContentW
                    actionButton.frame = CGRect.init(x: alert_contentSpace + (btnW + alert_horizontalSpace) * CGFloat(index), y: btnY, width: btnW, height: alert_buttonHeight)
                }
                
                contentView.bounds = CGRect.init(x: 0, y: 0, width: contentW, height: actionButton.frame.maxY + alert_contentSpace)
                contentView.center = self.center
            }
            
        } else {
            
            for index in 0...titleArrays.count-1 {
                let lineView = UIView.init()
                lineView.backgroundColor = alert_lineColor
                
                lineView.frame = CGRect.init(x: 0, y: lastBtnMaxY, width: contentW, height: alert_lineHeight)
                btnSuperView.addSubview(lineView)
                
                let actionButton = UIButton.init(type: .custom)
                actionButton.backgroundColor = UIColor.white
                actionButton.titleLabel?.font = UIFont.stl_buttonFont(16)
                actionButton.titleLabel?.lineBreakMode = .byTruncatingTail
                
                actionButton.addTarget(self, action:  buttonSelector ?? #selector(alertBtnAction(sender:)), for: .touchUpInside)
                actionButton.setBackgroundImage(OSSVAlertsViewNew.imageWithColor(color: alert_buttonBgDisabledColor), for: .disabled)
                actionButton.setBackgroundImage(OSSVAlertsViewNew.imageWithColor(color: alert_buttonBgHeightColor), for: .highlighted)
                actionButton.isExclusiveTouch = true
                
                if index == titleArrays.count - 1 {
                    contentView.addSubview(actionButton)
                } else {
                    btnSuperView.addSubview(actionButton)
                }
                
                actionButton.tag = 2021+index
                
                let btnTitleObject = titleArrays[index]
                if let strBtnTitle = btnTitleObject as? String {
                    actionButton.setTitle(strBtnTitle, for: .normal)
                } else if let attrBtnTitle = btnTitleObject as? NSAttributedString {
                    actionButton.titleLabel?.numberOfLines = 0
                    actionButton.titleLabel?.textAlignment = .center
                    actionButton.setAttributedTitle(attrBtnTitle, for: .normal)
                }
                
                self.alertAllButtonArr.add(actionButton)
                
                if titleArrays.count > 2 || vertical {
                    let btnY = lineView.frame.maxY
                    actionButton.frame = CGRect.init(x: 0, y: btnY, width: contentW, height: alert_buttonHeight)
                } else {
                    let btnY = lastMaxY + alert_lineHeight
                    let btnW = titleArrays.count == 2 ? contentW / 2.0 : contentW
                    let lineY = titleArrays.count == 2 ? (index == 0 ? lastMaxY: btnY) : lastMaxY
                    let lineW = titleArrays.count == 2 ? (index == 0 ? contentW: alert_lineHeight) : contentW
                    let linewH = titleArrays.count == 2 ? (index == 0 ? alert_lineHeight : alert_buttonHeight) : alert_buttonHeight
                    lineView.frame = CGRect.init(x: (contentW / 2.0) * CGFloat(index), y: lineY, width: lineW, height: linewH)
                    actionButton.frame = CGRect.init(x: (contentW / 2.0 + alert_lineHeight) * CGFloat(index), y: btnY, width: btnW, height: alert_buttonHeight)
                }
                
                lastBtnMaxY = actionButton.frame.maxY
                contentView.bounds = CGRect.init(x: 0, y: 0, width: contentW, height: actionButton.frame.maxY)
                contentView.center = self.center
            }
        }
        
    }
    
    ///计算内容高度
    class func calculateTextHeight(font: UIFont, width:CGFloat, textObject: Any) -> CGFloat {
        if let strText = textObject as? String {
            let textFont = font
        
            let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle.init()
            paragraph.lineBreakMode = .byWordWrapping
            paragraph.lineSpacing = OSSVAlertsViewNew.lineSpace()
            
            let attributes = [NSAttributedString.Key.font: textFont,NSAttributedString.Key.paragraphStyle: paragraph]
            let textSize = strText.boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions(rawValue: (NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)) , attributes: attributes, context: nil).size

            return ceil(textSize.height)
            
        } else if let attrText = textObject as? NSAttributedString {
            
            let textSize = attrText.boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions(rawValue: (NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)) , context: nil).size

            return ceil(textSize.height)
        }
        return 0.0
    }
    
    
    @objc init(frame:CGRect,
               alertType ctype:STLAlertType,
               isVertical vertical:Bool,
               messageAlignment cAlignment: NSTextAlignment,
               isAr ar:Bool,
               showHeightIndex heightIndex:NSInteger,
               title ctitle:Any?,
               message cmessage:Any?,
               buttonTitles cbuttonTitles:NSArray!,
               buttonBlock cbuttonBlock: calertBlock?,
               closeBlock ccloseBlock:calertCancelBlock?) {
        super.init(frame: frame)
        
        self.alertHeightIndex = heightIndex >= 0 ? heightIndex : 0
        if let buttons = cbuttonTitles {
            self.alertHeightIndex = buttons.count <= 0 ? 0 : self.alertHeightIndex
        }
        self.alertCallBlock = cbuttonBlock;
        self.alertCallCancelBlock = ccloseBlock;
        
        ///先移除
        self.removeAlertFromWindow()
        
        let lastLabMaxY = self.layoutTitleAndMessage(title: ctitle, message: cmessage, messageAlignment: cAlignment, isAr: ar)
        
        let allTitleArray: NSMutableArray = NSMutableArray.init(array: cbuttonTitles)
        
        if allTitleArray.count > 0 {
            self.layoutAlertButton(allTitleArrays: cbuttonTitles, buttonFormateType: ctype, contentView: self.contentView ?? UIView.init(), lastUImaxY: lastLabMaxY, isVertical: vertical, buttonAction: nil)
            
            showAlertToWindow()

        }
        
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func alertBtnAction(sender: UIButton) {
        if (self.alertCallBlock != nil) {
            self.alertCallBlock!(sender.tag-2021,"dd")
        }
        dismissAlertView()
    }
    
    
    
    func showAlertToWindow() {
        self.alpha = 0.0
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.3)
        
        if let window = keyWindow() {
            window.endEditing(true)
            window.addSubview(self)
            self.contentView?.transform = CGAffineTransform.init(scaleX: 1.12, y: 1.12)
            UIView.animate(withDuration: 0.15) {
                self.alpha = 1
                self.contentView?.transform = CGAffineTransform.identity
            }
        }
    }
    
    func dismissAlertView() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.0
            self.contentView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        } completion: { finished in
            self.removeFromSuperview()
        }

    }
    
    func removeAlertFromWindow() {
        
        if let window = keyWindow() {
            window.endEditing(true)
            for view in window.subviews {
                if view.isKind(of: OSSVAlertsViewNew.self) {
                    view.removeFromSuperview()
                    break;
                }
            }
        }
    }
    
    
    func keyWindow() -> UIWindow? {
        var window: UIWindow? = UIApplication.shared.keyWindow
        if #available(iOS 13.0, *) {
            if window == nil{
                for windowScene:UIWindowScene in (UIApplication.shared.connectedScenes as? Set<UIWindowScene>)! {
                    if windowScene.activationState == .foregroundActive {
                        window = windowScene.windows.first
                    }
                    break
                }
            }
        }
        return window
    }
    
    class func imageWithColor(color:UIColor) -> UIImage
    {
            let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
            UIGraphicsBeginImageContext(rect.size)
            let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
            
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage.init() }
            UIGraphicsEndImageContext()
            
            return image
    }

}


extension OSSVAlertsViewNew {
    
    @objc class func showAlert(alertType ctype:STLAlertType,
                               isVertical vertical:Bool,
                               messageAlignment cAlignment: NSTextAlignment,
                               isAr ar:Bool,
                               showHeightIndex heightIndex:NSInteger,
                               title ctitle:Any?,
                               message cmessage:Any?,
                               buttonTitles cbuttonTitles:NSArray!,
                               buttonBlock cbuttonBlock: calertBlock?) {
        
        if judgeCanShowAlert(title: ctitle, message: cmessage) == false {
            return
        }
        let _: OSSVAlertsViewNew = OSSVAlertsViewNew.init(frame: UIScreen.main.bounds, alertType: ctype, isVertical: vertical, messageAlignment: cAlignment, isAr: ar, showHeightIndex: heightIndex, title: ctitle, message: cmessage, buttonTitles: cbuttonTitles, buttonBlock: cbuttonBlock, closeBlock: nil)
    }
    
    @objc class func showAlert(frame:CGRect,
                               alertType ctype:STLAlertType,
                               isVertical vertical:Bool,
                               messageAlignment cAlignment: NSTextAlignment,
                               isAr ar:Bool,
                               showHeightIndex heightIndex:NSInteger,
                               title ctitle:Any?,
                               message cmessage:Any?,
                               buttonTitles cbuttonTitles:NSArray!,
                               buttonBlock cbuttonBlock: calertBlock?) {
        
        if judgeCanShowAlert(title: ctitle, message: cmessage) == false {
            return
        }
        let _: OSSVAlertsViewNew = OSSVAlertsViewNew.init(frame: frame, alertType: ctype, isVertical: vertical, messageAlignment: cAlignment, isAr: ar, showHeightIndex: heightIndex, title: ctitle, message: cmessage, buttonTitles: cbuttonTitles, buttonBlock: cbuttonBlock, closeBlock: nil)
    }
    
    @objc class func showAlert(frame:CGRect,
                               alertType ctype:STLAlertType,
                               isVertical vertical:Bool,
                               messageAlignment cAlignment: NSTextAlignment,
                               isAr ar:Bool,
                               showHeightIndex heightIndex:NSInteger,
                               title ctitle:Any?,
                               message cmessage:Any?,
                               buttonTitles cbuttonTitles:NSArray!,
                               buttonBlock cbuttonBlock: calertBlock?,
                               closeBlock ccloseBlock:calertCancelBlock?) {
        
        if judgeCanShowAlert(title: ctitle, message: cmessage) == false {
            return
        }
        let _: OSSVAlertsViewNew = OSSVAlertsViewNew.init(frame: frame, alertType: ctype, isVertical: vertical, messageAlignment: cAlignment, isAr: ar, showHeightIndex: heightIndex, title: ctitle, message: cmessage, buttonTitles: cbuttonTitles, buttonBlock: cbuttonBlock, closeBlock: ccloseBlock)
        
    }
    
    class func judgeCanShowAlert(title:Any?, message:Any?) -> Bool{
        
        let titleFlag = isContainContent(content: title)
        let messageFlag = isContainContent(content: message)
        if titleFlag || messageFlag {
            return true
        }
        
        return false
    }
    
    class func isContainContent(content: Any?) -> Bool {
        if let tit = content as? String, !tit.isEmpty{
            return true
        }

        if let tit = content as? NSAttributedString, !tit.string.isEmpty {
            return true
        }
        return false
    }
    
    @objc class func lineSpace() -> CGFloat {
        return 4
    }
}
