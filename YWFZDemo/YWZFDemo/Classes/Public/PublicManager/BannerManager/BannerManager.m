//
//  BannerManager.m
//  ZZZZZ
//
//  Created by YW on 16/10/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BannerManager.h"
#import "ZFBannerModel.h"
#import "ZFWebViewViewController.h"
#import "JumpModel.h"
#import "JumpManager.h"
#import "CategoryDataApi.h"
#import "CategoryNewModel.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation BannerManager

/**
 Deeplink参数

 @param target Deeplink跳转VC
 @param bannerModel Deeplink跳转数据源
 */
+ (void)doBannerActionTarget:(id)target withBannerModel:(ZFBannerModel *)bannerModel {
    if (!target) return;
    NSString *url = bannerModel.deeplink_uri;
    if ([NSStringUtils isBlankString:url]) {
        return;
    }
    
    UIViewController *targetVC = target;
    NSString *str1 = ZFEscapeString(url, YES);
    NSURL *banner_url = [NSURL URLWithString:str1];
    NSString *scheme = [banner_url scheme];
    if ([scheme isEqualToString:kZZZZZScheme]) {
        NSDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:banner_url];
        [BannerManager jumpDeeplinkTarget:targetVC deeplinkParam:paramDict];
        return;
    }
    
    if ([url hasPrefix:@"http"]) {
        ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
        webViewVC.link_url = url;
        webViewVC.title = ZFToString(bannerModel.name);
        [targetVC.navigationController pushViewController:webViewVC animated:YES];
    }
}

/**
 包装Deeplink参数

 @param target Deeplink跳转VC
 @param paramDict Deeplink跳转解析数据源
 */
+ (void)jumpDeeplinkTarget:(id)target deeplinkParam:(NSDictionary *)paramDict {
    JumpModel *jumpModel = [[JumpModel alloc] init];
    jumpModel.actionType = [NSStringUtils isEmptyString:paramDict[@"actiontype"]] ? JumpDefalutActionType : [paramDict[@"actiontype"] integerValue];
    jumpModel.url        = NullFilter(paramDict[@"url"]);
    jumpModel.name       = NullFilter(paramDict[@"name"]);
    jumpModel.sort       = NullFilter(paramDict[@"sort"]);
    jumpModel.refine     = NullFilter(paramDict[@"refine"]);
    jumpModel.minprice   = NullFilter(paramDict[@"minPrice"]);
    jumpModel.maxprice   = NullFilter(paramDict[@"maxPrice"]);
    jumpModel.isCouponListDeeplink = [NullFilter(paramDict[@"isCouponListDeeplink"]) boolValue];
    jumpModel.giftId     = NullFilter(paramDict[@"giftId"]);
    jumpModel.source     = NullFilter(paramDict[@"source"]);
    jumpModel.bucketid   = NullFilter(paramDict[@"buckid"]);
    jumpModel.versionid  = NullFilter(paramDict[@"versionid"]);
    jumpModel.planid     = NullFilter(paramDict[@"planid"]);
    jumpModel.featuring  = NullFilter(paramDict[@"featuring"]);
    jumpModel.coupon     = NullFilter(paramDict[@"coupon"]);
    jumpModel.noNeedAnimated = [NullFilter(paramDict[@"noNeedAnimated"]) boolValue];
    [JumpManager doJumpActionTarget:target withJumpModel:jumpModel];
}

/**
 * 根据url解析Deeplink参数
 * ZZZZZ://action?actiontype=2&url=66&name=woment&source=deeplink
 */
+ (NSMutableDictionary *)parseDeeplinkParamDicWithURL:(NSURL *)url {
    NSMutableDictionary *deeplinkParamDic = [NSMutableDictionary dictionary];
    
    if ([url isKindOfClass:[NSURL class]] && url.query) {
        NSString *deeplinkAddress = url.query;
        
        //V4.5.0 防止url中有逗号(,)导致获取参数失败
        NSString *componentKey = @"actiontype=";
        if ([url.absoluteString containsString:@","] && [url.absoluteString containsString:componentKey]) {
            NSString *componentObj = [[url.absoluteString componentsSeparatedByString:componentKey] lastObject];
            deeplinkAddress = [NSString stringWithFormat:@"%@%@", componentKey, componentObj];
        }
        
        NSArray *arr = [deeplinkAddress componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str rangeOfString:@"="].location != NSNotFound) {
                NSString *key = [str componentsSeparatedByString:@"="][0];
                NSString *value;
                if ([key isEqualToString:@"url"]) {
                    value = [str substringFromIndex:4];
                }else{
                    value = [str componentsSeparatedByString:@"="][1];
                }
                NSString *decodeValue = [value stringByRemovingPercentEncoding];
                
                // 防止多次编码,判断如果还有百分号就再解码一次
                if ([key isEqualToString:@"url"] && [decodeValue containsString:@"%"]) {
                    decodeValue = [decodeValue stringByRemovingPercentEncoding];
                }
                
                if (key && decodeValue) {
                    [deeplinkParamDic setObject:decodeValue forKey:key];
                }
            }
        }
    }
    YWLog(@"\n================================ Deeplink 参数 =======================================\n👉: %@", deeplinkParamDic);
    return deeplinkParamDic;
}

@end
