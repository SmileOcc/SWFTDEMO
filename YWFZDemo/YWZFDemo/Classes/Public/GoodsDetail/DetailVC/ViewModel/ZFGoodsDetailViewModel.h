//
//  ZFGoodsDetailViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsDetailProtocol.h"
#import "ZFAnalytics.h"
#import "GoodsDetailsReviewsModel.h"

static NSString *kShowLoadingFlag = @"kNeedShowLoading";

typedef void(^ZFGoodsDetailFinishBlock)(GoodsDetailModel *detailModel);


@class GoodsDetailModel, ZFGoodsDetailView, ZFGoodsDetailCouponModel;

@interface ZFGoodsDetailViewModel : NSObject

/* 是否为搭配购过来 */
@property (nonatomic, assign) BOOL isCollocationBuy;

@property (nonatomic, weak) id<GoodsDetailVCActionProtocol> actionProtocol;

@property (nonatomic, strong) ZFGoodsDetailView *goodsDetailView;

@property (nonatomic, strong) GoodsDetailModel *detailModel;

@property (nonatomic, assign) BOOL isNotShowError;


// 商品详情内部商品
@property (nonatomic, strong) ZFAnalyticsProduceImpression *recommendAnalyticsImpression;

/**
 * 商详页面AB布局调整
 * photoAndSimilarBtsDict : @{请求商详博主图, 找相似的bts}
 */
- (void)requestGoodsDetailAllBts:(NSDictionary *)detailInfoDict;

/**
 * 请求商品详情接口
 */
- (void)requestGoodsDetailPort:(NSDictionary *)detailInfoDict;

/**
 * 请求商品详情页商品信息 (供商详以外的类调用请求商品数据)
 */
- (void)requestGoodsDetailData:(NSDictionary *)dict
                    completion:(ZFGoodsDetailFinishBlock)completion
                       failure:(void (^)(NSError *))failure;

/**
 * 请求商品添加到购物车 (供商详以外的类调用请求商品数据)
 */
- (void)requestAddToCart:(NSString *)goodsId
             loadingView:(UIView *)loadingView
                goodsNum:(NSInteger)goodsNum
              completion:(void (^)(BOOL isSuccess))completion;

/**
 * 请求商详穿搭商品关联的SKU
 */
- (void)requestOutfitsSkuPortOutfits:(NSString *)outfitsId
                            goods_sn:(NSString *)goods_sn
                          completion:(void(^)(NSArray<ZFGoodsModel *> *))completion;

/**
 * 详情页面领取coupon
 */
- (void)requestGetCouponPort:(ZFGoodsDetailCouponModel *)couponModel
                   indexPath:(NSIndexPath *)indexPath;

/*
 * 添加购物车 , 执行动画  然后刷新购物车数量
 */
- (void)requestAddGoodsToCartPort:(BOOL)isFastBuy;


/**
 * 商品评论数据，前3条
 */
- (void)requestGoodsReviewsPort:(GoodsDetailModel *)detailModel completion:(void (^)(GoodsDetailsReviewsModel *reviewsModel))completion;

/**
 * 退出关闭当前页面时取消所有请求
 */
- (void)cancelAllDataTask;

@end

