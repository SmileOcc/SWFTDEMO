//
//  YXImportPicResponeModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation


struct YXImportPicResponseModel: Codable {
    let arrList: [ImportSecu]?
    
    enum CodingKeys: String, CodingKey {
        case arrList = "arr_list"
    }
}

// MARK: - ArrList
struct ImportSecu: Codable, Equatable {
    let market, symbol, stockName: String?
    
    enum CodingKeys: String, CodingKey {
        case market, symbol
        case stockName = "stock_name"
    }
}
