//
//  YXHistoryResponseModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

struct YXHistoryResponseModel: Codable {
    let pageNum, pageSize, total: Int
    let list: [YXHistoryList]
    let systemDate: String
}

struct YXHistoryList: Codable {
    public enum BizType: String {
        case deposit = "0", withdraw = "1", exchange = "2"
    }
    
    var statusColor: UIColor? {
        get {
            if self.statusValue == "Processed" {
                return UIColor.qmui_color(withHexString: "#00C767")
            } else if self.statusValue == "Pending" {
                return UIColor.qmui_color(withHexString: "#3489FF")
            }  else if self.statusValue == "Rejected" {
                return UIColor.qmui_color(withHexString: "#FF415D")
            } else {
                return QMUITheme().themeTextColor()
            }
        }
    }
    
    let type, title, occurBalance, postBalance: String?
    var statusDesc: String?
    var reasonHeight: CGFloat = 0
    var reason: String?
    var statusValue: String?
    let applyTime, businessID: String
    
    enum CodingKeys: String, CodingKey {
        case type, title, occurBalance, postBalance, statusDesc, statusValue, applyTime, reason
        case businessID = "businessId"
    }
}
