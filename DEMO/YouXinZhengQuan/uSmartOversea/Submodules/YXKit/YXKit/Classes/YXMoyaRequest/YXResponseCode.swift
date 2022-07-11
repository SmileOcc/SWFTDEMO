//
//  YXResponseCode.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objc public enum YXResponseCode: Int {
  
    case success = 0
    case unsetLoginPwd        = 300705 //未设置登录密码
    case invalidRequest       = 300100 //非法请求
    case accountTokenFailure  = 300101 //token失效
    case accountCheakTimeout  = 300202 //手机双重认证时间超时
    case vertifyTooMuch       = 300304 //验证次数过多，请稍后重试
    case codeTimeout          = 300305 //抱歉，验证码已过期，请重新获取
    case accountFreeze        = 300102 //手机账户被冻结
    case accountUnregistered  = 300701 //帐号未注册
    case accountLockout       = 300702 //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    case accountDoubleCheak   = 300809 //在新设备登录，需要双重认证
    case accountEmailDoubleCheak   = 304006 //在新设备登录，需要双重认证
    case wechatExisting       = 301405 //此微信号已存在账号可直接登录或解绑后再绑定
    case weiboExisting        = 301407  //此微博号已存在账号可直接登录或解绑后再绑定
    case authCodeRepeatSent   = 300302  //短信验证码刚刚发送过，请60s后重试
    case newsNoOptional       = 810305 //用户没有相关自选股
    case newsNoUser           = 806906 //用户信息不存在
    case inputCorrectPhone    = 300309 // 请输入正确的手机号码
    
    case accountActivation          = 300706 //预注册账号激活
    case accountActivationNoTip     = 300707 //预注册账号激活/无提示
    case codeCheckActivation        = 300708  //验证手机号是否注册的 已激活
    
    case thirdLoginUnbindPhone      = 301018 //第三方登录没有绑定手机号
    case thirdLoginPhoneBinded      = 301019 //该手机号码已经被绑定了。
    case thirdbindPhoneActivated    = 301020 //该手机号码已经通过ipad注册了。
    case thirdLoginAlertOne         = 301021 //iPad开户手机号码
    case thirdLoginAlertTwo         = 301022 //iPad开户只是提交申请，未提交资料
    
    case tradePwdDigitalError = 301001  //交易密码需为6位纯数字，请重新输入
    case tradePwdLockError    = 301002  //错误次数过多交易密码已锁定，请%s小时后重新尝试或找回密码
    case tradePwdError        = 301003  //交易密码错误，请重新输入，您还可以尝试%s次
    case tradeFrozenError     = 301005  //賬戶被凍結，無法登入如有疑問請聯繫客服
    case userFrozenError      = 409948  //账户被冻结
    
    case changePhoneAccountExisting   =  300700 //更换手机号时改手机号已经注册
    case versionDifferent     = 806901 //自选股版本号不一致
    case versionEqual         = 806916 //自选股版本号一致
    case optionalNone         = 806907 //没有上传过自选股列表
    case tradePwdInvalid      = 409984 //交易密码失效
    case needBrokenError = 406472 //包含碎股的错误
    case outPriceRange = 407295      //超出价格档位校验设置范围
    case outMostLowPrice3Percent = 410207 //委托价格偏离最优买入价超过3%，下单可能失败，是否继续提交？
    case overUpperLimitOfBuying = 410211  //北向交易净买盘每日额度已达上限，下单可能失败，是否继续提交？
    case notSupportHSStockTrade = 410214  //您的賬戶暫不支持A股交易，請開通A股通賬戶
    
    case overMaxLPD           = 408964  // 超过兑换汇累计额度
    case newStockNotEnoughFunds = 409919 //新股交易资金不足
    case smartNoHoldStocks = 807004 //智能盯盘无持仓
    case smartNoSelfStocks = 806000 //智能盯盘无自选股
    case notOpenAShareAccount = 408602 //未開通A股賬戶
    case notOpenAShareAccount2 = 408603 //You have not opened China Connect Account, cannot exchange CNH. Open Now
    case sameCurrency = 450007 //源币种跟目标币种是同一币种类型
    
    case noMsgNote = 800000 // 消息中心无消息
    
    //聚合接口相关
    case aggregationError          = 108000 //服务器内部错误，请联系管理员
    case aggregationHalfError      = 108007 //部分接口请求失败
    case aggregationUserError      = 108008 //user服务不可用
    case aggregationStockError     = 108009 //stock-capital服务不可用
    case aggregationProductError   = 108010 //product服务不可用
    case aggregationInfoError      = 108011 //用户信息查询接口异常
    case aggregationLoginError     = 108012 //用户登录接口异常
    case aggregationRegistError    = 108013 //用户注册接口异常
    case aggregationMoneyError     = 108014 //入金查询接口异常
    case aggregationPermissionsError     = 108015 //行情权限信息查询接口异常
    case aggregationWechatError          = 108017 //用户微信登录接口异常
    case aggregationWeiboError           = 108018 //用户微博登录接口异常
    case aggregationFacebookError        = 108019 //用户facebook登录接口异常
    case aggregationGoogleError          = 108020 //用户google登录接口异常
    case aggregationOverseaUnservice     = 108021 //user-oversea服务不可用
    case aggregationHKWechatError        = 108022 //用户HK微信登录接口异常
    
    //海外版新增
    case accountUnSignup                = 301108   //海外账号未注册
    case mobileHasRegisted              = 300810   //手机号已注册
    case passwordWrong                  = 300703   //密码错误提示
    case emailHasRegisted               = 301109   //邮箱已注册
    case tradePwdSetted                 = 350211   //设置过交易密码
    case tradePwdLockError2             = 350205  //错误次数过多交易密码已锁定，请%s小时后重新尝试或找回密码
    case tradePwdError2                 = 350209  //交易密码错误，请重新输入，您还可以尝试%s次
    case mobileNoRegist                 = 300709     //手机未注册
    case emaliNoRegist                  = 306004     //邮箱未注册
    
    case userPhoneHasRegistered         = 301114   // 手机已注册
    case userEmialHasRegistered         = 306002   // 邮箱已注册
    case registePhoneSMSError           = 300800   // 手机注册 验证码错误
    case registeEmailCodeError          = 300407   // 邮箱注册 验证码错误
    case registeEmailCodeTimesOverMuch  = 300405   // 邮箱注册 验证次数过多，请稍后重试
    case registeEmailCodeOverdue        = 300406   // 邮箱注册 验证码过期

}

