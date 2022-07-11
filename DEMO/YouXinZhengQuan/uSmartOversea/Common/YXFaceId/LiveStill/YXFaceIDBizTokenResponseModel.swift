//
//  YXFaceIDBizTokenResponseModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/29.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

struct YXFaceIDBizTokenResponseModel: Codable {
    let bizToken: String?
    let timeUsed: Int?
    let requestID: String?
    
    enum CodingKeys: String, CodingKey {
        case bizToken = "biz_token"
        case timeUsed = "time_used"
        case requestID = "request_id"
    }
}

