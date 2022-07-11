//
//  YXBullBearPbSignalResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

// 文档地址http://szshowdoc.youxin.com/web/#/23?page_id=1251

class YXBullBearPbSignalResModel: YXModel {
    @objc var list: [YXBullBearPbSignalItem] = []
    @objc var nextPageSeqNum = 0
    @objc var nextPageUnixTime = 0
    @objc var hasMore = true
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXBullBearPbSignalItem.self]
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearPbSignalItem: YXModel {
    @objc var signal: YXBullBearPbSignal?
    @objc var top: YXBullBearItem?
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXBullBearPbSignal: YXModel {
    @objc var indicatorsId: Int = 0 //指标类型，0：未知，1：正股股价涨破5分钟均价，2：正股股价跌破5分钟均价，3：正股MACD5分金叉，4：正股MACD5分死叉
    @objc var market: String?
    @objc var symbol: String?
    @objc var name: String?
    @objc var netInflow: Int64 = 0
    @objc var type: YXBullAndBellType = YXBullAndBellType.all
    @objc var latestTime: String?
    @objc var color = 0 //信号颜色 1 利好 0 中性 -1 利空
    @objc var seqNum = 0 //序号
    @objc var indicatorsName: String? //信号名称

    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}
