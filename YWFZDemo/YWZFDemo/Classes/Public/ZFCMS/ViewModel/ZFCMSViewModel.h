//
//  ZFCMSViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCMSSectionModel.h"
#import "ZFCMSBaseViewModel.h"
#import "ZFCMSCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSViewModel : ZFCMSBaseViewModel

/**
 * 检索出fb广告链接带进来的商品数据 放到浏览历史记录中
 */
- (void)retrievalAFGoodsGoodsData:(nullable void(^)(void))completion;

/**
 * 请求首页频道对应的列表广告接口
 * isCMSMainUrlType-> YES:请求cms主站接口(默认), NO:请求cms备份S3上的数据
 */
- (void)requestHomeListData:(NSString *)channelID
        isRequestCMSMainUrl:(BOOL)isRequestCMSMainUrl
                 completion:(void (^)(NSArray<ZFCMSSectionModel *> *, BOOL ))completion;

/**
* 请求推荐商品数据接口
* recommendType 推荐商品类型
*/
- (void)requestCmsRecommendData:(BOOL)firstPage
                   sectionModel:(ZFCMSSectionModel *)sectionModel
                      channelID:(NSString *)channelID
                     completion:(void (^)(NSArray<ZFGoodsModel *> *array, NSDictionary *pageInfo))completion
                        failure:(void (^)(NSError *error))failure;


/**
 * 首页优惠券组件后台数据,然后拼接到组件数组
 */
- (void)requestCMSCouponData:(NSString *)couponsStrng
                  completion:(void (^)(NSArray<ZFCMSCouponModel *> *array))completion
                     failure:(void (^)(NSError *error))failure;


/// V5.4.0 增加统计触发S3的请求事件 (AF+公司统计SDK)
+ (void)analyticRequestS3:(NSString *)httpCode
                cmsResult:(NSString *)cmsResult
               requestUrl:(NSString *)url
               serverTime:(NSString *)serverTime;

/**
 * 如果滑动SKU组件没有返回数据时再请求商品运营平台的接口
 */
- (void)requestSlidSkuModuleData:(ZFCMSSectionModel *)sectionModel
                       channelID:(NSString *)channelID
                      completion:(void (^)(NSArray<ZFGoodsModel *> *array))completion
                         failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
