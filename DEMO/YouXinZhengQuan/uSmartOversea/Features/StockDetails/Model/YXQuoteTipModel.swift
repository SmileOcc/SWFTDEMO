//
//  YXQuoteTipModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/8/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXQuoteTipModel: YXModel {
    @objc var list: [YXQuoteTipInfo]?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXQuoteTipInfo.self]
    }
}

class YXQuoteTipInfo: YXModel {
    @objc var activated: Int = 0 //是否已激活，待使用状态才有用;1、待激活；2、已激活、3：激活失败
    @objc var couponBusinessId: String = ""
    @objc var couponCode: String = ""
    @objc var couponName: String = ""
    @objc var couponType: Int = 0 //优惠券类型；1、返现券、2：送股券、3：佣金计划时长券、4：行情卡、5：礼品卡、6：返佣券、7：策略卡、 8：未定额现金券
    @objc var status: Int = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
}
