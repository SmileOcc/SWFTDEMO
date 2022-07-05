//
//  HCLoginUser.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit

struct HCLoginUser: Codable {
    var uuidStr: String?
    var areaCode, phoneNumber: String?
    var thirdBindBit: UInt64?
    let marketBit: Int?
    
//    enum CodingKeys: String, CodingKey {
//        case uuid, uuidString, areaCode, phoneNumber,thirdBindBit
//        case marketBit = "marketBit"
//    }
}
