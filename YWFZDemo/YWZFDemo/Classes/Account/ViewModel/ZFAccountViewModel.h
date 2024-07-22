//
//  ZFAccountViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFBannerModel.h"
#import "ZFGoodsModel.h"
@class AccountModel;

@interface ZFAccountViewModel : BaseViewModel

@property (nonatomic, assign) NSInteger pageIndex;

/*
 * 请求个人中心显示数据
 * 订单数，Banner多分管
 */
- (void)requestUserInfoData:(void (^)(AccountModel *))completion
                    failure:(void (^)(NSError *error))failure;

/**
 * 获取个人中心banner接口
 */
- (void)requestUserCoreBannerData:(void (^)(NSArray *banners))completion
                          failure:(void (^)(id obj))failure;

/**
 * 获取个人中心显示的Banner CMS广告
 */
- (void)requestUserCoreCMSBanner:(void (^)(NSArray<ZFNewBannerModel *> *))completion;

/**
 * 统计个人中心banner内推广告
 */
- (void)analyticsGABanner:(NSArray<ZFNewBannerModel *> *)bannersArr;


/**
 *  在requestAccountRecommendProduct接口前调用,重新获取第一页推荐商品数据,用于页面下拉刷新请求
 */
- (void)requestFirstPageRecommendProduct;

/**
 *  获取个人中心推荐位商品
 */
- (void)requestAccountRecommendProduct:(void (^)(NSDictionary *object, NSError *error))completion;

/**
 *  获取个人中心推荐位商品
 */
- (void)requestAccountRecommend:(BOOL)isFirstPage
                     completion:(void (^)(NSDictionary *object, NSError *error))completion;

@end
