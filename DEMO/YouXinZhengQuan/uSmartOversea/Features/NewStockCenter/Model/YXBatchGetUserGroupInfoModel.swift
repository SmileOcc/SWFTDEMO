//
//  YXBatchGetUserGroupInfoModel.swift
//  uSmartOversea
//
//  Created by Mac on 2020/1/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - DataClass
struct YXYXBatchGetUserGroupInfoModel: Codable {
    let orderList: [YXUserGroupInfoOrderList]?

    enum CodingKeys: String, CodingKey {
        case orderList = "order_list"
    }
}

// MARK: - OrderList
struct YXUserGroupInfoOrderList: Codable {
    /*
     // 1：未成团 2:已成团 3:已满员 4：过期
     已成团未满人   可以分享
     已成团已满人   不可以分享  文案：已满人
     
     1、2可分享， 其他不可分享
     */
    let status: Int?
    let headFlag: Bool?                     // true：团长 false:团员
    let orderCount: Int?                    // 团当前成员人数
    let mostCount: Int?                     // 团成员人数上限
    let feeInfo: YXUserGroupInfoFeeModel?   // 1：基金 服务费 2:手续费 ecmFee 3: ecm 销售服务费serviceFee
    let orderID: Double?
    let orderIDStr: String?
    let bizID: Int?
    let bizIDStr: String?
    let groupID: Int?
    
    var productName: String = ""
    var appType: Int = 2  //app类型 1-大陆版  2-港版

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case headFlag = "head_flag"
        case orderCount = "order_count"
        case mostCount = "most_count"
        case feeInfo = "fee_info"
        case orderID = "order_id"
        case orderIDStr = "order_id_str"
        case bizID = "biz_id"
        case bizIDStr = "biz_id_str"
        case groupID = "group_id"
        case appType = "app_type"
    }
}

struct YXUserGroupInfoFeeModel: Codable {
    let fundFee: YXUserGroupInfoFeeInfo?        // 基金 服务费
    let ecmFee: YXUserGroupInfoFeeInfo?         // ecm手续费
    let ecmServiceFee: YXUserGroupInfoFeeInfo?  // ecm 销售服务费
    
    enum CodingKeys: String, CodingKey {
        case fundFee = "1"
        case ecmFee = "2"
        case ecmServiceFee = "3"
    }
}

struct YXUserGroupInfoFeeInfo: Codable {
    
    let fee: Int32?
    let discount: Int32?
    
    enum CodingKeys: String, CodingKey {
        case fee, discount
    }
}
