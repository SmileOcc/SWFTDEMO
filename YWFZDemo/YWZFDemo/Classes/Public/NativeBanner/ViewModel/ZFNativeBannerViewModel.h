//
//  ZFNativeBannerViewModel.h
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNativeBannerBranchLayout.h"
#import "ZFNativeBannerSKUBannerLayout.h"
#import "ZFNativeBannerSlideLayout.h"
#import "ZFNativeBannerResultModel.h"
#import "ZFAnalytics.h"

@class ZFNativeNavgationGoodsModel;

@interface ZFNativeBannerViewModel : NSObject

//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpressionSpecial;

//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpressionGoodsList;

/**
 * 请求原生专题数据
 */
- (void)requestNativeBannerDataWithSpecialId:(NSString *)specialId
                                  completion:(void (^)(ZFNativeBannerResultModel *bannerModel,BOOL isSuccess))completion;

/**
 * 请求商品列表数据
 */
- (void)requestBannerGoodsListData:(BOOL)firstPage
                             navId:(NSString *)navId
                         specialId:(NSString *)specialId
                        completion:(void (^)(ZFNativeNavgationGoodsModel *model,NSArray *currentPageArray,NSDictionary *pageInfo))completion;

/**
 * 领取coupon
 */
- (void)getCouponWithCouponId:(NSString*)coupon_center_id
                   completion:(void (^)(id obj))completion;

/**
 * 获取分馆 section
 */
- (NSMutableArray<ZFNativeBannerBaseLayout *> *)queryLayoutSections;

/**
 * 每个分馆 size
 */
- (CGSize)itemSizeAtIndexPath:(NSIndexPath *)indexPath;

@end
