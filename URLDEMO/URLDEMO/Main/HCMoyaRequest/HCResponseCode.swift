//
//  HCResponseCode.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

@objc public enum HCResponseCode: Int {
  
    case success = 200
    case unsetLoginPwd        = 300705 //未设置登录密码
    case invalidRequest       = 300100 //非法请求
    case accountTokenFailure  = 300101 //token失效
    case accountCheakTimeout  = 300202 //手机双重认证时间超时
    case vertifyTooMuch       = 300304 //验证次数过多，请稍后重试
    case codeTimeout          = 300305 //抱歉，验证码已过期，请重新获取
    case accountFreeze        = 300102 //手机账户被冻结
}

