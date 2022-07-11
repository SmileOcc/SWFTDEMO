//
//  YXBondDetailModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct YXBondDetailModel: Codable {
    let bondInfoVO: YXBondInfoVO?
    let bondOrderClinchVO: YXBondOrderClinchVO?
    let bondOrderEntrustVO: YXBondOrderEntrustVO?
    let bottomRemark, commission: String?
    let createTime: Int64?
    let direction: YXBondDirection?
    let orderDirection: String?
    let externalStatus: Int?
    let externalStatusName, failedRemark, finraFee, externalStatusFinalName: String?
    let finishedTime: Int64?
    let orderNo, platformFee: String?
}

// MARK: - BondInfoVO
struct YXBondInfoVO: Codable {
    let bondCode: String?
    let bondID: Int64?
    let bondMarket: YXBondDirection?
    let bondName, bondStockCode: String?
    let currency: YXBondDirection?
    let minFaceValue: Int64?
    
    enum CodingKeys: String, CodingKey {
        case bondCode
        case bondID = "bondId"
        case bondMarket, bondName, bondStockCode, currency, minFaceValue
    }
}

// MARK: - Direction
struct YXBondDirection: Codable {
    let name: String?
    let type: Int?
}

// MARK: - BondOrderClinchVO
struct YXBondOrderClinchVO: Codable {
    let clinchAmount, clinchCharge, clinchInterest, clinchMarketValue: String?
    let clinchPrice, clinchQuantity, copies: String?
}

// MARK: - BondOrderEntrustVO
struct YXBondOrderEntrustVO: Codable {
    let copies, entrustAmount, entrustInterest, entrustMarketValue: String?
    let entrustPrice, entrustQuantity, estimateCharge: String?
}
