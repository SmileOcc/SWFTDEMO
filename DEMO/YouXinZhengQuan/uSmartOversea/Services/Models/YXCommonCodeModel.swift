//
//  YXCommonCodeModel.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
//通用的获取验证码model
struct YXCommonCodeModel: Codable {
    let captcha: String?
}

//
struct YXOrgCheckAccountModel: Codable {
    let existPassword: Bool?
}

struct YXOrgActivateModel: Codable {
    let existPassword: Bool
    let msg: String
    
}
