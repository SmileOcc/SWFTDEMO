//
//  YXResponse.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public struct YXResult<C: Codable>: Codable {
    public let code: Int
    public let msg: String?
    public let data: C?
    
}
