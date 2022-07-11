//
//  YXUSElementChangeResModel.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUSElementChangeResModel: YXModel {
    @objc var market:String?
    @objc var thirdClassify:String?
    @objc var list: [YXUSElementChangeItemModel] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXUSElementChangeItemModel.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXUSElementChangeItemModel: YXModel {
    @objc var uniqueSecuCode: String?  //证券唯一编码
    @objc var uniqueSecuCodeElement: String?  //成分股证券唯一编码
    @objc var secuCodeElement: String?  //成分股证券代码
    @objc var holderChanged: Int64 = 0 //持仓变化
    @objc var holder: Int64 = 0
    @objc var dateChanged: String? //变化日期

    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}
