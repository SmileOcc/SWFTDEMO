//
//  YXTupleTool.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTupleTool: NSObject {
    
    //MARK: 只支持元组传入
    class func mirrorTuple(_ tuple: Any) -> [String: Any]? {
        let mirror = Mirror(reflecting: tuple)
        guard let style = mirror.displayStyle, style == .tuple else {
            return nil
        }
        
        func mirrorSingleValue(value: Any) -> Any? {
            let subMirror = Mirror(reflecting: value)
            if subMirror.displayStyle == .tuple {
                if let subDic = mirrorTuple(value) {
                    return subDic
                }
            } else {
                return value
            }
            return nil
        }
        
        func mirrorDictinaryValue(valueDic: [String : Any]) -> Any? {
            var dic = [String : Any]()
            for (key, value) in valueDic {
                if let value = mirrorSingleValue(value: value) {
                    dic[key] = value
                }
            }
            if !dic.isEmpty {
                return dic
            }
            return nil
        }
        
        
        func mirrorArrayValue(valueArray: [Any]) -> Any? {
            var array = [Any]()
            for value in valueArray {
                if let value = mirrorSingleValue(value: value) {
                    array.append(value)
                }
            }
            if !array.isEmpty {
                return array
            }
            return nil
        }
        
        var dic = [String : Any]()
        for item in mirror.children {
            
            guard let label = item.label else { fatalError("Invalid key in child:key\(item)") }
            if let value = item.value as? [Any] {
                if let array = mirrorArrayValue(valueArray: value) {
                    dic[label] = array
                }
            } else if let value = item.value as? [String : Any] {
                if let subdic = mirrorDictinaryValue(valueDic: value) {
                    dic[label] = subdic
                }
            } else {
                if let singleValue = mirrorSingleValue(value: item.value),let object = singleValue as? NSObject {
                    dic[label] = object
                }
            }
        }
        
        if dic.isEmpty == false  {
            return dic
        }
        return nil
    }
}
