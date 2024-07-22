//
//  ZFNativeBannerModel.h
//  ZZZZZ
//
//  Created by YW on 31/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZFBannerCouponStateType) {
    ZFBannerCouponStateTypeReceive  = 1,   // 可领取
    ZFBannerCouponStateTypeClaimed,        // 已领取
    ZFBannerCouponStateTypeExpired,        // 过期
    ZFBannerCouponStateTypeUsed            // 领取完
};

typedef NS_ENUM(NSInteger, ZFBannerType) {
    ZFBannerTypeNormal  = 1,   // 普通类型
    ZFBannerTypeCoupon  = 2,   // coupon类型
    ZFBannerTypeVideo   = 6    // 视频类型
};

@interface ZFNativeBannerModel : NSObject
@property (nonatomic, copy) NSString   *deeplinkUri;
@property (nonatomic, copy) NSString   *bannerName;
@property (nonatomic, copy) NSString   *bannerImg;
@property (nonatomic, copy) NSString   *bannerHeight;
@property (nonatomic, copy) NSString   *bannerWidth;
@property (nonatomic, copy) NSString   *couponId;
@property (nonatomic, copy) NSString   *bannerCountDown;
@property (nonatomic, copy) NSString   *countdownShow;
/**
 * banner 类型
 */
@property (nonatomic, assign) ZFBannerType   bannerType;
/**
 * 用户是否已经领取优惠
 */
@property (nonatomic, assign) ZFBannerCouponStateType   couponStatuType;

/**
 * 非服务端返回 ,在请求到数据发现有倒计时定时器时才创建,页面上去接取这个key取对应的定时器
 */
@property (nonatomic, copy) NSString *nativeCountDownTimerKey;

@end
