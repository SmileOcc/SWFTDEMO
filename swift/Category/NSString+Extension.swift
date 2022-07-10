//
//  NSString+Extension.swift
//  HDBaseProject
//
//  Created by MountainZhu on 2020/7/16.
//  Copyright © 2020 航电. All rights reserved.
//

import Foundation
import UIKit

public extension NSString {
    /// 计算文本的高度
    func textHeight(_ fontSize: CGFloat, _ width: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size.height
    }
    
    //MARK:- 手机号码验证
    static func checkMobile(mobileNumbel : NSString) ->Bool {
        /**
        * 手机号码
        * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
        * 联通：130,131,132,152,155,156,185,186
        * 电信：133,1349,153,180,189,181(增加)
        */
        let MOBIL = "^1(3[0-9]|5[0-35-9]|8[025-9]|7[68]|9[9])\\d{8}$";
        /**
        * 中国移动：China Mobile
        * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
        */
        let CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
        /**
        * 中国联通：China Unicom
        * 130,131,132,152,155,156,185,186
        */
        let CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$";
        /**
        * 中国电信：China Telecom
        * 133,1349,153,180,189,181(增加)
        */
        let CT = "^1((33|53|8[019])[0-9]|349)\\d{7}$";
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", MOBIL)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", CM)
        let regextestcu = NSPredicate(format: "SELF MATCHES %@", CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@", CT)
        if regextestmobile.evaluate(with: mobileNumbel) || regextestcm.evaluate(with: mobileNumbel) || regextestcu.evaluate(with: mobileNumbel) || regextestct.evaluate(with: mobileNumbel) {
            return true
        }
        return false
    }
    
    //MARK:- 正则匹配用户身份证号15或18位
    static func checkUserIdCard(idCard:NSString) ->Bool {
        let pattern = "(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: idCard)
        return isMatch;
    }
    
    //MARK:- 正则匹配用户密码8-18位数字和字母组合
    //let pattern = "^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}" //6-18位数字和字母组合
    //let reg = /^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[-!$%^&*()_+|~=`{} //6-18位数字和字母组合
    static func checkPassword(password:NSString) ->Bool {
        let pattern = "^.{8,18}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: password)
        
        return isMatch;
    }
    
    //MARK:- 正则匹配URL
    static func checkURL(url:NSString) ->Bool {
        let pattern = "^[0-9A-Za-z]{1,50}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: url)
        return isMatch;
    }
    
    //MARK:- 正则匹配用户姓名,20位的中文或英文
    static func checkUserName(userName:NSString) ->Bool {
        let pattern = "^[a-zA-Z\\u4E00-\\u9FA5]{1,20}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: userName)
        return isMatch;
    }
    
    //MARK:- 正则匹配用户email
    static func checkEmail(email:NSString) ->Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: email)
        return isMatch;
    }
    
    static func checkStringName(value:NSString) -> NSString {
        if value.isKind(of: NSString.self) {
            if value.isEqual(to: "null") || value.isEqual(to: "(null)") || value.isEqual(to: "<null>") {
                return "";
            }
            return value;
        }
        return "";
    }
    
    //MARK: 时间
    static func checkTime(time:NSString) -> NSString {
        var nowDate = NSDate();
        if time.isKind(of: NSString.self) {
            var nowTime = time;
            if nowTime.length > 0 {
                if nowTime.length > 10 {
                    nowTime = nowTime.substring(with: NSRange(location: 0, length: 10)) as NSString;
                }
                nowDate = NSDate(timeIntervalSince1970: TimeInterval(nowTime.integerValue));
            }
        }
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM月dd日";
        let monthString = dateFormatter.string(from: nowDate as Date);
        
        let calendar = Calendar(identifier: .chinese);
        let dateComponent = calendar.dateComponents(in: TimeZone.current, from: nowDate as Date);
        let weekDay = dateComponent.weekday;
        var weekName = "周日";
        switch weekDay {
        case 1:
            weekName = "周日";
        case 2:
            weekName = "周一";
        case 3:
            weekName = "周二";
        case 4:
            weekName = "周三";
        case 5:
            weekName = "周四";
        case 6:
            weekName = "周五";
        case 7:
            weekName = "周六";
        default:
            weekName = "周日";
        }
        
        return ("\(monthString)"+" "+"\(weekName)") as NSString;
    }
    
    //TODO: 将字典转换成json字符串
    static func onGetJsonStringFromDictionary(_ parameters:[String : Any]) -> String {
       var result:String = ""
       do {
           //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
           let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0))

           if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
               result = JSONString
           }
           
       } catch {
           result = ""
       }
        return result
    }
    
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8.rawValue)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8.rawValue))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])//大写"%02X",小写:"%02x"
        }
        result.deinitialize(count: digestLen)
        return String(format: hash as String)
     }
}
