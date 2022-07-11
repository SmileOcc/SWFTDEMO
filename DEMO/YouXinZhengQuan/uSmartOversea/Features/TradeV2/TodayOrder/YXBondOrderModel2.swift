//
//  YXBondOrderModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/8/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXBondOrderModel2: YXModel {
    @objc var bondId : String = ""
    @objc var bondName : String = ""
    @objc var clinchPrice : String = ""
    @objc var clinchQuantity : NSNumber?
    @objc var createTime : String = ""
    @objc var direction : Direction2 = Direction2()
    @objc var entrustPrice : String = ""
    @objc var entrustQuantity : NSNumber?
    @objc var externalStatus : Int = 0
    @objc var externalStatusName : String = ""
    @objc var failedRemark : String = ""
    @objc var bondMarket : Market2 = Market2()
    @objc var finalStatus: Bool = false
    @objc var orderNo : String = ""
}

class Direction2 : NSObject {
    @objc var dictCode : String = ""
    @objc var name : String = ""
    @objc var type : Int = 0
}

class ExternalStatus2 : NSObject {
    @objc var dictCode : String = ""
    @objc var name : String = ""
    @objc var type : Int = 0
}

class Market2 : NSObject {
    @objc var dictCode : String = ""
    @objc var name : String = ""
    @objc var type : Int = 0
}
