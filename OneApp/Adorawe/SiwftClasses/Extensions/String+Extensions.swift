//
//  String+Extensions.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/16.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import UIKit

extension NSString{
    @objc var isPureNumber:Bool{
        get{
            let rx = NSRegularExpression.rx("\\d+")
            return rx?.isMatch(self as String) ?? false
        }
    }
    
    @objc var isContainArabic:Bool{
        get{
            let rx = NSRegularExpression.rx("\\p{Arabic}+")
            return rx?.isMatch(self as String) ?? false
        }
    }
    
    ///是否全为相同的数字
    @objc var isAllSameNumber:Bool{
        get{
            let rx = NSRegularExpression.rx("0+$|^1+$|^2+$|^3+$|^4+$|^5+$|^6+$|^7+$|^8+$|^9+")
            return rx?.isMatch(self as String) ?? false
        }
    }
    
    @objc var strippedHtml:String?{
        let rx = NSRegularExpression.rx("<\\/?.+?\\/?>")
        
        return rx?.stringByReplacingMatches(in: self as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.length), withTemplate: "")
    }
    
    ///金币返现文案
    @objc static var cashBackHeadline:NSAttributedString {
        get{
            let head1 = STLLocalizedString_("CashBackHeadline1")!
            let desc1 = STLLocalizedString_("CashBackHeadDesc1")!
            let head2 = STLLocalizedString_("CashBackHeadline2")!
            let desc2 = STLLocalizedString_("CashBackHeadDesc2")!
            let head3 = STLLocalizedString_("CashBackHeadline3")!
            let desc3 = STLLocalizedString_("CashBackHeadDesc3")!
            
            let arrs = [(head1,desc1),(head2,desc2),(head3,desc3)]
            
            return assumheadDesc(pairs: arrs)
        }
    }
    
    ///使用优惠券文案
    @objc static var couponUseDesc:NSAttributedString {
        get{
            let head1 = STLLocalizedString_("How_Use_Coupons")!
            let desc1 = STLLocalizedString_("How_Use_Coupons_Content")!
            let head2 = STLLocalizedString_("How_Get_Coupons")!
            let desc2 = STLLocalizedString_("How_Get_Coupons_Content")!
            
            let arrs = [(head1,desc1),(head2,desc2)]

            return assumheadDesc(pairs: arrs)
        }
    }
    
    ///组装 head -- desc
    static func assumheadDesc(pairs:[(String,String)])->NSAttributedString{
        let result = NSMutableAttributedString()
        for (head,desc) in pairs {
            result.yy_appendString(head)
            result.yy_appendString("\n")
            result.addAttributes([
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: OSSVThemesColors.col_0D0D0D()
                                 ], range:(result.string as NSString).range(of: head))
            result.yy_appendString(desc)
            result.addAttributes([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: OSSVThemesColors.col_0D0D0D()
                                 ], range:(result.string as NSString).range(of: desc))
            result.yy_appendString("\n")
        }
        result.yy_appendString("")
        let parastyle = NSMutableParagraphStyle()
        parastyle.lineSpacing = OSSVAlertsViewNew.lineSpace()
        result.addAttributes([NSAttributedString.Key.paragraphStyle:parastyle], range: NSRange(location: 0,length: result.length))
        return result
    }
    
    @objc static func underLineSizeChat(titleStr:String?)->NSAttributedString{
        
        let result = NSMutableAttributedString()
        if let titleStr = titleStr {
            result.yy_appendString(titleStr)
        }else{
            result.yy_appendString(STLLocalizedString_("Size_chart")!)
        }
        
        if app_type == 3 {
            result.yy_color = OSSVThemesColors.col_000000(0.5)
//            result.yy_underlineStyle = NSUnderlineStyle(rawValue: NSUnderlineStyle.single.rawValue | NSUnderlineStyle.patternDot.rawValue)
//            result.yy_underlineColor = OSSVThemesColors.col_000000(0.5)
        }else{
            result.yy_color = OSSVThemesColors.col_B62B21()
            result.yy_underlineStyle = NSUnderlineStyle.single
            result.yy_underlineColor = OSSVThemesColors.col_B62B21()
        }
       
        result.yy_font = UIFont.systemFont(ofSize: 12)
        result.yy_baselineOffset = 1
        return result

    }
    
    @objc func underLine(lineColor:UIColor,textColor:UIColor,font:UIFont)->NSAttributedString{
        let result = NSMutableAttributedString()
        result.yy_appendString(self as String)
        result.yy_color = textColor
        result.yy_underlineStyle = NSUnderlineStyle.single
        result.yy_underlineColor = lineColor
        result.yy_font = font
        result.yy_baselineOffset = 1
        return result
    }
}
