//
//  ZFReuqestModel.m
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRequestModel.h"
#import "YWLocalHostManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFAnalytics.h"
#import "ExchangeManager.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFRequestModel ()
//警告: 这个不能删除, 防止底层每次调用get方法生成的json都一样
@property (nonatomic, strong) NSDictionary *zfParmaters;
@end

@implementation ZFRequestModel

@synthesize parmaters = _parmaters;
@synthesize url = _url;
@synthesize uploadRequestLogToUrl = _uploadRequestLogToUrl;
@synthesize requestHttpHeaderField = _requestHttpHeaderField;


/**
 * 在get方法统一设置公共参数
 */
- (NSDictionary *)parmaters {
    if (_forbidAddPublicArgument) {
        return _parmaters;
    }
    
    if (!_zfParmaters) {
        NSMutableDictionary *fullParmaters = [NSMutableDictionary dictionary];
        if (_parmaters) {
            [fullParmaters setDictionary:_parmaters];
        }
        fullParmaters[ZFApiIsencKey] = @"0"; //默认不加密
        
        fullParmaters[ZFApiTokenKey] = ZFToString(TOKEN); //Token
        
        NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
        fullParmaters[ZFApiLangKey] = ZFToString(lang); //语言标识
        
        //国家Id, 供后期每个接口运营配置数据
        ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
        fullParmaters[ZFApiCountryIdKey] = ZFToString(accountModel.region_id);
        fullParmaters[ZFApiCountryCodeKey] = ZFToString(accountModel.region_code);
        
        if (self.isCommunityRequest) { //社区请求参数里面固定要加版本号,其他模块不需要
            fullParmaters[ZFApiVersionKey] = ZFToString(ZFSYSTEM_VERSION); //版本号
        }
        
        //设备唯一标识,即使删除再次安装也是唯一
        NSString *device_id = [AccountManager sharedManager].device_id;
        fullParmaters[ZFApiDeviceId] = ZFToString(device_id);
        
        //用户信息定位
        NSString *countryId = [[NSUserDefaults standardUserDefaults] valueForKey:kLocationInfoCountryId];
        if (ZFIsEmptyString(countryId)) {
            countryId = ZFToString(accountModel.region_id);
        }
        fullParmaters[ZFApiCommunityCountryId] = countryId;
        
        fullParmaters[ZFApiAppsFlyerUID] = ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]);
        
        fullParmaters[ZFApiBtsUniqueID] = ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]);
        
        fullParmaters[ZFApiCurrencySymbol] = ZFToString([ExchangeManager localCurrencyName]);
        
        // 关于购物车中的公共参数
        if (![fullParmaters.allKeys containsObject:ZFTestForbidUserCoupon]) {
            
            // 购物车显示了优惠券一栏
            fullParmaters[@"ab_cart_price"] = @(1);
            
            // 是否在购物车页面选择了优惠券: 0选择  1不选中
            if (!ISLOGIN) {
                fullParmaters[@"no_login_select"] = [AccountManager sharedManager].no_login_select_coupon ? @"1" : @"0";
            }
            if ([AccountManager sharedManager].hasSelectedAppCoupon) {
                fullParmaters[@"auto_coupon"] = @"0";    // 是否为最优优惠券 0不是最优, 1最优
                fullParmaters[@"coupon"] = ZFToString([AccountManager sharedManager].selectedAppCouponCode);// 选择的优优惠券码
            } else {
                fullParmaters[@"auto_coupon"] = @"0"; //V5.4.0版本改成不自动使用最优coupon
                if (![fullParmaters.allKeys containsObject:@"coupon"]) {
                    fullParmaters[@"coupon"] = @"";
                }
            }
        }
        
        _zfParmaters = fullParmaters;
    }
    return _zfParmaters;
}

/**
 * 上传请求日志的接口
 */
- (NSString *)uploadRequestLogToUrl {
    NSString *catchLogUrl = GetUserDefault(kInputCatchLogUrlKey);
    if (ZFIsEmptyString(catchLogUrl)) {
        return ZZZZZUploadRequestLogUrl;
    } else {
        if (![catchLogUrl containsString:@":"]) {
            catchLogUrl = [catchLogUrl stringByAppendingString:@":8090"];
        }
        return [NSString stringWithFormat:@"http://%@/pullLogcat",catchLogUrl];;
    }
}

- (NSDictionary<NSString *,NSString *> *)requestHttpHeaderField {
    
    // 推送通知打开 所以请求标记处理 5s内
    NSString *userAgent = [YWLocalHostManager requestFlagePushUserAgent];
    if (!ZFIsEmptyString(userAgent)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:_requestHttpHeaderField];
        [dic setValue:userAgent forKey:@"User-Agent"];
        _requestHttpHeaderField = dic;
    }
        
    return _requestHttpHeaderField;
}
@end

