//
//  ZFNativeBannerModel.m
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerModel.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

@implementation ZFNativeBannerModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"couponStatuType"  : @"couponGetStatus"
             };
}



-(NSString *)bannerWidth{
    if ([_bannerWidth isEqualToString:@"0"] || _bannerWidth == nil || ZFIsEmptyString(_bannerWidth)) {
        if ([_bannerHeight isEqualToString:@"0"] || _bannerHeight == nil || ZFIsEmptyString(_bannerHeight)) {
            return [NSString stringWithFormat:@"%f",KScreenWidth];
        }else{
            return _bannerHeight;
        }
    }
    return _bannerWidth;
}

-(NSString *)bannerHeight{
    if ([_bannerHeight isEqualToString:@"0"] || _bannerHeight == nil || ZFIsEmptyString(_bannerHeight)) {
        if ([_bannerWidth isEqualToString:@"0"] || _bannerWidth == nil || ZFIsEmptyString(_bannerWidth)) {
            return [NSString stringWithFormat:@"%f",KScreenWidth];
        }else{
            return _bannerWidth;
        }
    }
    return _bannerHeight;
}

/**
 * 非服务端返回 ,在请求到数据发现有倒计时定时器时才创建,页面上去接取这个key取对应的定时器
 */
- (NSString *)nativeCountDownTimerKey {
    if (!_nativeCountDownTimerKey || ZFIsEmptyString(_nativeCountDownTimerKey)) {
        return HomeTimerKey;//防止异常
    }
    return _nativeCountDownTimerKey;
}

@end
