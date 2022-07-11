//
//  YXStokFilterQueryItemsResponseModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXStockFilterQueryType: Int {
    // 精确
    case accurate = 0
    // 范围
    case range
    // 多级范围
    case multiRange
}

class YXStockFilterQueryItemsResponseModel: YXModel {
    
    @objc var groups: [YXStokFilterGroup] = []
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["groups": YXStokFilterGroup.self]
    }
}

class YXStokFilterGroup: YXModel {
    @objc var items : [YXStockFilterItem] = []
    @objc var key : String?
    @objc var name : String?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["items": YXStockFilterItem.self]
    }
}

class YXStockFilterItem: YXModel {
    @objc var key : String?
    @objc var name : String?
    @objc var queryType : YXStockFilterQueryType = .accurate
    @objc var queryValueList : [YXStokFilterQueryValueListItem] = []
    @objc var isSelected = false
    @objc var unitType = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["queryValueList": YXStokFilterQueryValueListItem.self]
    }
}

class YXStokFilterQueryValueListItem: YXModel {
    @objc var list : [YXStokFilterListItem] = []
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXStokFilterListItem.self]
    }
}

class YXStokFilterListItem: YXModel {
    @objc var max : Double = 0.0
    @objc var key : String?
    @objc var min : Double = 0.0
    @objc var name : String?
    @objc var value : String?
    @objc var isSelected = false
}


class YXStockFilterUserFilter: YXModel {

    @objc var list: [YXStockFilterUserFilterList]?

    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXStockFilterUserFilterList.self]
    }
}

class YXStockFilterUserFilterList: YXModel {

    @objc var name = ""
    @objc var market = ""
    @objc var Id: Int64 = 0
    @objc var groups: [YXStokFilterGroup]?

    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["groups":"group"]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["groups": YXStokFilterGroup.self]
    }
}
