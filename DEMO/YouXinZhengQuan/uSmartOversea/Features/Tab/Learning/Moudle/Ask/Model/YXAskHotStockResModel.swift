//
//  YXAskHotStockResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXAskHotStockResModel: YXModel {
    /// 回复角色(1-普通用户，2-KOL)
    @objc var replyRole : Int = 1
    
    ///
    @objc var waitingFlag : Bool = false
    
    /// 热门股票
    @objc var hotStockInfoVOList : [YXAskStockResModel]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["hotStockInfoVOList": YXAskStockResModel.self]
    }
}
