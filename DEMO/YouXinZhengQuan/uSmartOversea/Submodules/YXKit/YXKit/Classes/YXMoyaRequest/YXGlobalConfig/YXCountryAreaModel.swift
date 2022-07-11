//
//  YXCountryAreaModel.swift
//  AFNetworking
//
//  Created by 井超 on 2019/10/28.
//

import UIKit
@objcMembers public class YXCountryAreaModel: NSObject ,Codable {

    public var commonCountry: [Country]?
    public var othersCountry: [Country]?
    public var version: NumberInt64?
    
    enum CodingKeys: String, CodingKey {
        case commonCountry = "commonCountry"
        case othersCountry = "othersCountry"
        case version = "version"
    }
}

// MARK: - Country
@objcMembers public class Country: NSObject, Codable {
    public var area: String?
    public var cn: String?
    public var en: String?
    public var hk: String?
    public var my: String?
    public var th: String?
    public var cnPinyin: String?

    enum CodingKeys: String, CodingKey {
        case area = "area"
        case cn = "cn"
        case en = "en"
        case hk = "hk"
        case my = "my"
        case th = "th"
        case cnPinyin = "cnPinyin"
    }
}


@objcMembers public class YXFilterModuleModel: NSObject ,Codable {
    
    public var bitValue: Int?
    
    enum CodingKeys: String, CodingKey {
        case bitValue
    }
    
}
