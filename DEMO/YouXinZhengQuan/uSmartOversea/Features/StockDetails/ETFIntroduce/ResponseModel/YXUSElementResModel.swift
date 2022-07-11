//
//  YXUSElementModel.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUSElementResModel: YXModel {
    @objc var market:String?
    @objc var thirdClassify:String?
    @objc var list: [YXUSElementItemModel] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXUSElementItemModel.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXUSElementItemModel: YXModel {
    @objc var uniqueSecuCode: String?  //证券唯一编码
    @objc var uniqueSecuCodeElement: String?  //成分股证券唯一编码
    @objc var secuCodeElement: String?  //成分股证券代码
    @objc var secuElement: String? //成分股名称
    @objc var investmentRationElement: Double = 0 //成分股投资占比
    
    @objc var isExist: Bool = false  //是否存在主表,0-不存在,1-存在
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}
