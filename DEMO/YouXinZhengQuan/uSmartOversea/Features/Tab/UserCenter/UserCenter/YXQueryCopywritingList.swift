//
//  YXQueryCopywritingList.swift
//  uSmartOversea
//
//  Created by Mac on 2020/1/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


struct YXQueryCopywritingList: Codable {
    let dataList: [YXQueryCopywritListModel]?
    
    enum CodingKeys: String, CodingKey {
        case dataList = "data_list"
    }
}

struct YXQueryCopywritListModel: Codable {
    let copyID: Int?
    let copyDesc: String?
    let positionID: Int?
    
    enum CodingKeys: String, CodingKey {
        case copyID = "copy_id"
        case copyDesc = "copy_desc"
        case positionID = "position_id"
    }
}
