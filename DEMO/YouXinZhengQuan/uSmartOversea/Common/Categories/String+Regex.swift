//
//  String+Regex.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

extension String {
//是否是有效的密码
    func isValidPwd () -> Bool {
        isValid(checkStr: self, regex: "^(?![0-9]+$)(?![a-z]+$)(?![A-Z]+$)(?!([^(0-9a-zA-Z)]|[\\(\\)])+$)([^(0-9a-zA-Z)]|[\\(\\)]|[a-z]|[A-Z]|[0-9]){8,}$")
    }
    //是否为纯数字
    func isAllNumber() -> Bool {
        isValid(checkStr: self, regex: "[0-9]*")
    }
    //是否有效
    func isValid(checkStr:String , regex:String) -> Bool {
        let predicte = NSPredicate(format: "SELF MATCHES %@",regex)
        let b = predicte.evaluate(with:checkStr)
        return b
    }
        
    ///（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        // 如果没有找到就返回-1
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    func removeBlankSpace() -> String {
        self.replacingOccurrences(of: " ", with: "")
    }
    //去掉字符串 前后的空格
    func removePreAfterSpace() -> String {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    //是否非空
    public func isNotEmpty() -> Bool {
        isEmpty == false
    }
    
    func isValidEmail() -> Bool {
        isValid(checkStr: self, regex:"^[a-z0-9A-Z]+[- | a-z0-9A-Z . _]+@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-z]{2,}$")
    }
    
    func isValidDolphID() -> Bool {
        isAllNumber()
       // isValid(checkStr: self, regex: "^([a-z])(?=.*[a-z].*[a-z].*)(?=.*\\d.*\\d.*\\d.*)[a-z0-9]{8}$")
    }
}
extension NSString {
    //获取nsCameraUsageDescription 的描述文字
   @objc class func fetchCameraUsageDescription() -> String {
        let infoDic = Bundle.main.infoDictionary
        let str = infoDic?["NSCameraUsageDescription"] as? String
        return str ?? ""
    }
}
