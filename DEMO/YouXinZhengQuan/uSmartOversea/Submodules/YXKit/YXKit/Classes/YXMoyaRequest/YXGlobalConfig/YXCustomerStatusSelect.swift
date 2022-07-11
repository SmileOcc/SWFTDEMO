//
//  YXCustomerStatusSelect.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/5/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - DataClass
/*
 customerTel    客服电话
 onlineTime     在线服务时间
 showType       展示选项 1-电话 2-在线 3-电话+在线
 telTime        电话服务时间
*/
// MARK: - DataClass
public struct YXCustomerStatusSelect: Codable, Equatable {
    public let showType: Int?
    public let customerTel: String?
    public let telTime: String?
    public let onlineTime: String?
    
    enum CodingKeys: String, CodingKey {
        case showType = "showType"
        case customerTel = "customerTel"
        case telTime = "telTime"
        case onlineTime = "onlineTime"
    }
}
