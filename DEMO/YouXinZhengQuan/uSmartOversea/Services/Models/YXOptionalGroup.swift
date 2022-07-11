//
//  YXOptionalGroup.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import YXKit

struct YXOptionalGroup: Codable {
    let version: UInt?
    let sortflag: UInt?
    let group: [SecuGroup]?
}

struct SecuGroup: Codable {
    let gid: UInt?
    let gname: String?
    let list: [SecuId]?
}

struct SecuId: Codable {
    let market, symbol: String?
    let sort: UInt?
}
