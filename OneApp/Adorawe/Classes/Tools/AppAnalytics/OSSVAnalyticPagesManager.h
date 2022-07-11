//
//  OSSVAnalyticPagesManager.h
// XStarlinkProject
//
//  Created by odd on 2021/1/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kAnalyticsPageType @"pageType"
#define kAnalyticsPageCode @"pageCode"

//跳转页面类型
typedef NS_ENUM(NSInteger, AnalyticsPageType) {
    /** 默认备注，没有返回*/
    AnalyticsPageTypeDefault = 0,
    /** 频道首页*/
    AnalyticsPageTypeHomeChannel = 1,
    /** 分页类*/
    AnalyticsPageTypeCategory = 2,
    /** 商品详情页*/
    AnalyticsPageTypeGoodDetail = 3,
    /** 搜索*/
    AnalyticsPageTypeSearch = 4,
    /** 嵌入H5*/
    AnalyticsPageTypeInsertH5 = 5,
    /** 买家秀*/
    AnalyticsPageTypeBuyShow = 6,
    /** 外部链接*/
    AnalyticsPageTypeExternalLink = 7,
    /** 店铺列表*/
    AnalyticsPageTypeStoreList = 8,
    /** 订单详情*/
    AnalyticsPageTypeOrderDetail = 9,
    /** My Coupon*/
    AnalyticsPageTypeOrderCoupon = 10,
    /** Cart*/
    AnalyticsPageTypeCart = 11,
    /** My WishList*/
    AnalyticsPageTypeMyWishList = 12,
    /** 虚拟商品列表*/
    AnalyticsPageTypeVirtualGoodsList = 13,
    /** 原生专题*/
    AnalyticsPageTypeNativeCustom = 14,
    /** 0元商品列表*/
    AnalyticsPageTypeSpecialList = 16,
    /** 闪购活动页*/
    AnalyticsPageTypeFlashActivity = 17,
    /** 从消息中心跳转到订单详情*/
    AnalyticsPageTypeMsgToOrderDetail = 99,
};

@interface OSSVAnalyticPagesManager : NSObject
///所有统计页信息
@property (nonatomic, strong) NSDictionary *pageData;
///上一个页面name
@property (nonatomic, copy, readonly) NSString *lastPageName;
///上一个编码
@property (nonatomic, copy) NSString    *lastPageCode;
///当前的编码
@property (nonatomic, copy) NSString    *currentPageCode;
///当前页面
@property (nonatomic, copy) NSString *currentPageName;

///上一个按钮
@property (nonatomic, copy, readonly) NSString *lastButtonKey;

///当前按钮
@property (nonatomic, copy) NSString *currentButtonKey;

//所有也对应的按钮key
@property (nonatomic, strong) NSMutableDictionary *pageButtonKey;

//页面停留时长
@property (nonatomic, strong) NSMutableDictionary *pageStartEndTimeDic;

@property (nonatomic, copy) NSString                *systemCountryCode;
@property (nonatomic, copy) NSString                *systemLanguage;


- (void)pageStartTime:(NSString *)pageName;
- (NSString *)pageEndTimeLength:(NSString *)pageName;

- (NSString *)startPageTime:(NSString *)pageName;

- (NSString *)endPageTime:(NSString *)pageName;

+ (OSSVAnalyticPagesManager *)sharedManager;

///上一个页面信息
+ (NSDictionary *)lastPageInformDiction;

+ (NSDictionary *)currentPageInformDiction;

+ (NSDictionary *)analyticsEvent:(NSString *)event paramsDic:(NSDictionary *)params;
+ (NSString *)jsonStringAnalyticsEvent:(NSString *)event paramsDic:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
