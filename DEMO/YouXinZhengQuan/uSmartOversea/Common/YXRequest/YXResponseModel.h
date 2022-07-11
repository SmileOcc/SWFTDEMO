//
//  YXResponseModel.h
//  uSmartOversea
//
//  Created by rrd on 2018/7/23.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXModel.h"


typedef NS_ENUM(NSUInteger, YXResponseStatusCode) {
  
    YXResponseStatusCodeSuccess = 0,
    YXResponseStatusCodeAccountTokenFailure  = 300101, //token失效
    YXResponseStatusCodeAccountCheakTimeout  = 300202, //手机双重认证时间超时
    YXResponseStatusCodeAccountFreeze        = 300102, //手机账户被冻结
    YXResponseStatusCodeAccountUnregistered  = 300701, //帐号未注册
    YXResponseStatusCodeAccountLockout       = 300702, //密码错误次数过多账号已锁定，请%d分钟后重新登录或找回密码
    YXResponseStatusCodeActivationTimeout = 300305, //验证码过期
    YXResponseStatusCodeAccountActivation    = 300706, //预注册账号激活
    YXResponseStatusCodeAccountActivationNoTip    = 300707, //预注册账号激活/无提示
    YXResponseStatusCodeCheakActivation      = 300708, //检测手机号是否注册为预注册
    YXResponseStatusCodeAccountNoPwd         = 300705, //未设置密码
    YXResponseStatusCodeAccountDoubleCheck   = 300809, //在新设备登录，需要双重认证
    YXResponseStatusCodeAccountEmailDoubleCheck   = 304006, //在新设备登录，需要双重认证
    YXResponseStatusCodeAccountNeedBindPhone = 301018, //第三方登录需要绑定手机号
    YXResponseStatusCodeBindPhonePreRegist   = 301020, //第三方登录绑定手机号预注册
    YXResponseStatusCodeWechatExisting       = 301405, //此微信号已存在账号可直接登录或解绑后再绑定
     YXResponseStatusCodeAliExisting         = 301428,//此支付宝号已存在账号可直接登录或解绑后再绑定
    YXResponseStatusCodeWeiboExisting        = 301407,  //此微博号已存在账号可直接登录或解绑后再绑定
    YXResponseStatusCodeAuthCodeRepeatSent   = 300302,  //短信验证码刚刚发送过，请60s后重试
    YXResponseStatusCodeOrganizerUnregistered    = 304001, // 机构户未注册
    YXResponseStatusCodeOrganizerUnActivity      = 304005, //机构户未激活
    YXResponseStatusCodeNewsNoOptional       = 810305, //用户没有相关自选股
    YXResponseStatusCodeNewsNoUser           = 806906, //用户信息不存在
    
    YXResponseStatusCodeTradePwdDigitalError = 301001,  //交易密码需为6位纯数字，请重新输入
    YXResponseStatusCodeTradePwdLockError    = 301002,  //错误次数过多交易密码已锁定，请%s小时后重新尝试或找回密码
    YXResponseStatusCodeTradePwdError        = 301003,  //交易密码错误，请重新输入，您还可以尝试%s次
    YXResponseStatusCodeTradePwdAccountLock  = 301005,  //账户被冻结
    
    YXResponseStatusCodeChangePhoneAccountExisting   =  300700, //更换手机号时改手机号已经注册
    YXResponseStatusCodeChangePhoneAccountTimeout    =  300202, //更换手机号时改手机号超时
    YXResponseStatusCodeBindPhoneAccountExisting    =  300307, //绑定手机号时手机号已注册
    YXResponseStatusCodeThirdBindPhoneExisting    =  301019, //第三方登录绑定手机号，手机号不可绑定
    YXResponseStatusCodeThirdBindPhoneIpadUser    =   301021,//ipad 开户手机号码
    YXResponseStatusCodeThirdBindPhoneIpadUserNoData  =  301022,//ipad 开户手机号码未提交资料
    YXResponseStatusCodeVersionDifferent     = 806901, //自选股版本号不一致
    YXResponseStatusCodeVersionEqual         = 806916, //自选股版本号一致
    YXResponseStatusCodeOptionalNone         = 806907, //没有上传过自选股列表
    YXResponseStatusCodeTradePwdInvalid      = 409984, //交易密码失效
    YXResponseStatusCodeOverMaxLPD           = 408964, // 超过兑换汇累计额度
    YXResponseStatusCodeOrderBroken          = 406472, //卖出委托交易包含碎股单
    YXResponseStatusCodeMoreThanNineMultiple = 407295, //超过9倍24档
    YXResponseStatusCodeMoreThanThreePercentage = 410207, //买入价格偏离最优买入价超3%
    YXResponseStatusCodeCreditLimit             = 410211, //北向交易额度上限
    YXResponseStatusCodeNoOpenHSAccount         = 410214, //未开通A股
    
    YXResponseStatusCodeOptionTradePwdInvalid   = 800013,
    YXResponseStatusCodeOptionInsufficientPurchasePower = 400055, //期权购买力不足
    YXResponseStatusCodeOptionForceEntrust      = 400056, //末日期权开仓强制下单
    
    //聚合接口相关
    YXResponseStatusCodeAggregationError          = 108000, //服务器内部错误，请联系管理员
    YXResponseStatusCodeAggregationHalfError      = 108007, //部分接口请求失败
    YXResponseStatusCodeAggregationUserError      = 108008, //user服务不可用
    YXResponseStatusCodeAggregationStockError     = 108009, //stock-capital服务不可用
    YXResponseStatusCodeAggregationProductError   = 108010, //product服务不可用
    YXResponseStatusCodeAggregationInfoError      = 108011, //用户信息查询接口异常
    YXResponseStatusCodeAggregationLoginError     = 108012, //用户登录接口异常
    YXResponseStatusCodeAggregationRegistError    = 108013, //用户注册接口异常
    YXResponseStatusCodeAggregationMoneyError     = 108014, //入金查询接口异常
    YXResponseStatusCodeAggregationPermissionsError     = 108015, //行情权限信息查询接口异常
    YXResponseStatusCodeAggregationWechatError          = 108017, //用户微信登录接口异常
    YXResponseStatusCodeAggregationWeiboError           = 108018, //用户微博登录接口异常
    YXResponseStatusCodeMRTestError                 = 107005, //MR测试
    YXResponseStatusCodeAccountBlocking                 = 301005, // 账户被冻结
    YXResponseStatusCodeIPOPurchaseAccountBlocking  = 409948, // 账户被冻结
    
    YXResponseStatusCodeCanNotJoin                  = 302005, //该idfa不能参与活动
    
    YXResponseStatusCodeNotOpenAShareAccount        = 408602, //未开通A股账户
    
    YXResponseStatusCodeCurrencyNotOpenAShareAccount = 408603, //货币兑换未开通A股账户
    
    YXResponseStatusCodeTradePwdInvalid1      = 100058, //交易密码失效
    YXResponseStatusCodeTradePwdError1        = 350209,  //交易密码错误，请重新输入，您还可以尝试%s次
    
    YXResponseStatusCodeTradeSpacError          = 100031, //Spac股票,禁止下单
    YXResponseStatusCodeSmartTradeSpacError     = 100110, //Spac股票,禁止下单
};


@interface YXResponseModel : NSObject

@property (nonatomic, strong, readonly) NSDictionary * _Nullable data;
@property (nonatomic, assign, readonly) YXResponseStatusCode code;
@property (nonatomic, copy, readonly) NSString * _Nullable msg;


@end
