//
//  YXNewStockPurchaseUtility.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockPurchaseUtility: NSObject {
    
    @objc class func noticeOneButtonAlert(title: String?, msg: String, actionBlock: (() -> Void)? = nil) {
        
        let alertView = YXAlertView.init(title: title, message: msg, prompt: nil, style: .default, messageAlignment: .center)
        alertView.addAction(YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
            actionBlock?()
        }))
        alertView.showInWindow()
    }
    
    @objc class func commonAlert(title: String?, msg: String, cancelTitle: String, otherActionTitle: String, actionBlock: @escaping(() -> Void)) {
        let alertView = YXAlertView.init(title: title, message: msg, prompt: nil, style: .default, messageAlignment: .left)
        alertView.addAction(YXAlertAction.init(title: cancelTitle, style: .cancel, handler: { (action) in
            
        }))
        alertView.addAction(YXAlertAction.init(title: otherActionTitle, style: .default, handler: { (action) in
            actionBlock()
        }))
        alertView.showInWindow()
    }
    
    @objc class func compareDate(firstDate: String, lessThanSecond secondDate: String) -> Bool {
        let firstDate = NSDate.init(string: firstDate, format: "yyyy-MM-dd HH:mm:ss")
        let secondDate = NSDate.init(string: secondDate, format: "yyyy-MM-dd HH:mm:ss")
        
        if (firstDate != nil && secondDate != nil) {
            return firstDate!.compare(secondDate! as Date) == .orderedAscending
        }
        
        return true
    }
    
    @objc class func moneyFormat(value: Double, decPoint: Int) -> String? {
        let str = String(format: "%.\(decPoint)lf", value)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh")
        switch decPoint {
        case 0:
            formatter.positiveFormat = ",###"
        case 1:
            formatter.positiveFormat = "###,##0.0"
        case 2:
            formatter.positiveFormat = "###,##0.00"
        case 3:
            formatter.positiveFormat = "###,##0.000"
        default:
            formatter.positiveFormat = "###,##0.00"
        }
        let v = NSNumber.init(string: str) ?? NSNumber.init(value: 0.0)
        let formatterStr = formatter.string(from: v)
        return formatterStr
    }
    
    @objc class func moneyFormat(value: Double) -> String? {
        let str = String(format: "%.2lf", value)
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00"
        formatter.locale = Locale(identifier: "zh")
        let v = NSNumber.init(string: str) ?? NSNumber.init(value: 0.0)
        let formatterStr = formatter.string(from: v)
        return formatterStr
    }
    
    @objc class func moneyFormat(value: Double, format: String) -> String? {
        let str = String(format: "%.2lf", value)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh")
        formatter.positiveFormat = format
        let v = NSNumber.init(string: str) ?? NSNumber.init(value: 0.0)
        let formatterStr = formatter.string(from: v)
        return formatterStr
    }
    
    @objc class func integerFormat(value: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.positiveFormat = ",###"
        formatter.locale = Locale(identifier: "zh")
        let v = NSNumber.init(value: value)
        let formatterStr = formatter.string(from: v)
        return formatterStr
    }
    
    class func int64Format(value: Int64) -> String? {
        let formatter = NumberFormatter()
        formatter.positiveFormat = ",###"
        formatter.locale = Locale(identifier: "zh")
        let v = NSNumber.init(value: value)
        let formatterStr = formatter.string(from: v)
        return formatterStr
    }
    
    @objc class func unitStr(moneyType: Int) -> String {
        //认购股数/金额
        if moneyType == 0 {
            return YXLanguageUtility.kLang(key: "common_rmb")
        } else if moneyType == 1 {
            return YXLanguageUtility.kLang(key: "common_us_dollar")
        } else if moneyType == 2 {
            return YXLanguageUtility.kLang(key: "common_hk_dollar")
        }else {
            return ""
        }
    }
    
    // 带横划线的富文本
    @objc class func middleLineString(string: String) -> NSAttributedString {
        let mutString = NSMutableAttributedString.init(string: string)
        mutString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber.init(value: 1), range: NSRange(location: 0, length: mutString.length))
        mutString.addAttribute(NSAttributedString.Key.baselineOffset, value: NSNumber.init(value: 0), range: NSRange(location: 0, length: mutString.length))
        mutString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel2(), range: NSRange(location: 0, length: mutString.length))
        mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: mutString.length))
        
        return mutString
    }
    
    @objc class func htmlString(text: String) -> NSAttributedString {
        NSAttributedString.init(htmlData: (text.data(using: String.Encoding.unicode)), options: [DTUseiOS6Attributes: true], documentAttributes: nil)
    }
    
    // 判断是否以某个值递增
    // value是变化的数值 constant是固定的增量，比如以10递增，这个10就是固定的增量。
    @objc class func isIntergerMultiple(value: Double, constant: Double, pointCount: Int) -> Bool {
        
        let powerBase = pow(10.0, Double(pointCount))
        let leftNumber = Int64(value * powerBase)
        let rightNumber = Int64(constant * powerBase)
        
        if leftNumber == 0 || rightNumber == 0 {
            return true
        } else if leftNumber % rightNumber == 0 {
            return true
        }
        return false
    }
    
    @objc class func yyLabelWithlinkText(wholeText: String, linkString: [String], action: @escaping (Int) -> Void) -> YYLabel {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        
        let contentString = wholeText
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.paragraphStyle : paragraph])
        
        for (index, str) in linkString.enumerated() {
            let range = (contentString as NSString).range(of: str)
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTintColor()], range: range)
            attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTintColor(), backgroundColor: UIColor.clear, tapAction: { (view, attstring, range, rect) in
                action(index)
            })
        }
        
        label.attributedText = attributeString
        return label
    }
    
    @objc class func yyLabelWithlinkText(wholeText: String, linkString: [String], font: UIFont, color: UIColor, action: @escaping (Int) -> Void) -> YYLabel {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        
        let contentString = wholeText
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.paragraphStyle : paragraph])
        
        for (index, str) in linkString.enumerated() {
            let range = (contentString as NSString).range(of: str)
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTintColor()], range: range)
            attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTintColor(), backgroundColor: UIColor.clear, tapAction: { (view, attstring, range, rect) in
                action(index)
            })
        }
        
        label.attributedText = attributeString
        return label
    }
    
    @objc class func yyLabelWithUnderLinelinkText(wholeText: String, linkString: [String], action: @escaping (Int) -> Void) -> YYLabel {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        
        let contentString = wholeText
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        let attributeString = NSMutableAttributedString.init(string: contentString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().stockRedColor(), NSAttributedString.Key.paragraphStyle : paragraph])
        
        for (index, str) in linkString.enumerated() {
            let range = (contentString as NSString).range(of: str)
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTintColor(), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTintColor(), backgroundColor: UIColor.clear, tapAction: { (view, attstring, range, rect) in
                action(index)
            })
        }
        
        label.attributedText = attributeString
        return label
    }
    
    @objc class func gradientImage(gradientColors: [UIColor] = [UIColor.init(hexString: "#2D40AB")!, UIColor.init(hexString: "#6D74FF")!], size:CGSize = CGSize(width: 10, height: 10)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map {(color: UIColor) -> AnyObject? in
            color.cgColor
        } as NSArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)
        
        context!.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: CGGradientDrawingOptions(rawValue: 0))
        let image: UIImage!
        if let temp = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
            image = UIImage.init(cgImage: temp)
        } else {
            image = UIImage.init()
        }
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @objc class func dateString(timeInterval: Double, format: String) -> String {
        let date = NSDate.init(timeIntervalSince1970: timeInterval)
        let dateString = date.string(withFormat: format)
        return dateString ?? ""
    }
}
