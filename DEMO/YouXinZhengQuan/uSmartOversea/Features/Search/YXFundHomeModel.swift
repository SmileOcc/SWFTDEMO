//
//  YXFundHomeModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

struct YXFundHomeModel: Codable {
    let fundHomepageOne: FundHomeOne?
}

// MARK: - FundHomepageOne
struct FundHomeOne: Codable {
    let masterTitle: String?
    let data: [YXFund]?
}

// MARK: - Datum
struct YXFund: Codable {
    let fundID: String?
    let assetType: Int?
    let assetTypeName: String?
    let tradeCurrency: Int?
    let initialInvestAmount, fundSize: String?
    let fundSizeCurrency: Int?
    let title, apy: String?
    let apyType: Int?
    let apyTypeName: String?
    let fundHomepagePointList: [FundPointList]?

    enum CodingKeys: String, CodingKey {
        case fundID = "fundId"
        case assetType, assetTypeName, tradeCurrency, initialInvestAmount, fundSize, fundSizeCurrency, title, apy, apyType, apyTypeName, fundHomepagePointList
    }
}

// MARK: - FundHomepagePointList
struct FundPointList: Codable {
    let belongDay: Int?
    let pointData: String?
}
