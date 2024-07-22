//
//  ZFGoodsDetailAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFShareManager.h"
#import "ZFAnalytics.h"

@class ZFGoodsDetailViewController, GoodsDetailModel, AFparams,
       GoodsDetailSameModel, ZFOrderCheckInfoDetailModel, ZFGoodsDetailOutfitsModel;


@interface ZFGoodsDetailAnalytics : NSObject


/**
 * 统计优惠券点击
 */
+ (void)af_analyticsShowCoupon;

/**
 * 统计点击获取优惠券
 */
+ (void)af_growingIOGetCoupon:(NSString *)discounts;

/**
 * 统计查看购物车
 */
+ (void)af_analyticsShowCartBag;

/**
* 统计退出商详页面
*/
+ (void)af_analyticsExitProduct:(NSString *)goods_sn;

/**
 * 统计点击评论
 */
+ (void)af_analyticsReviewClick:(NSString *)goods_sn;

/**
 * 统计展示分享
 */
+ (void)af_analyticsShowShare:(NSString *)goods_sn;

/**
 * 统计展示搭配购
 */
+ (void)af_analyticsShowCollocationBuy;

/**
 * FireBase统计计入商详
 */
+ (void)af_fireBaseShowDetail:(NSString *)goods_id;

// 商详请求成功统计
+ (void)af_analysicsDetail:(ZFGoodsDetailViewController *)goodsDetailVC
               detailModel:(GoodsDetailModel *)detailModel
            selectSkuCount:(NSInteger)selectSkuCount;

/**
 * 统计商品加入购物车事件
 */
+ (void)af_analysicsAddToBag:(ZFGoodsDetailViewController *)goodsDetailVC
                 detailModel:(GoodsDetailModel *)detailModel
              selectSkuCount:(NSInteger)selectSkuCount
                 fastBuyFlag:(BOOL)fastBuyFlag;

/**
 * 点击商详推荐位商品统计
 */
+ (void)af_analysicsClickRecommend:(GoodsDetailSameModel *)model
                     detailGoodsId:(NSString *)detailGoodsId;

/**
 * 商详主要信息接口请求成功时: GA统计代码
 */
+ (void)ga_analyticsDetail:(ZFGoodsDetailViewController *)goodsDetailVC
               detailModel:(GoodsDetailModel *)detailModel;

/**
 * 商品详情推荐商品统计
 */
+ (ZFAnalyticsProduceImpression *)fetchRecommendAnalytics:(ZFGoodsDetailViewController *)goodsDetailVC
                                              detailModel:(GoodsDetailModel *)detailModel;

/**
 * 统计:商详页评论模块曝光
 * 统计:商详页评论列表页曝光
 */
+ (void)af_analyticsReview:(ZFGoodsDetailViewController *)goodsDetailVC
               detailModel:(GoodsDetailModel *)detailModel;

/**
 * 统计分享facebook, Message事件
 */
+ (void)af_analyticsShare:(ZFGoodsDetailViewController *)goodsDetailVC
                shareType:(ZFShareType)shareType
                 goods_sn:(NSString *)goods_sn;

/**
 * 添加收藏统计
 */
+ (void)af_analyticsClickCollect:(ZFGoodsDetailViewController *)goodsDetailVC
                     detailModel:(GoodsDetailModel *)detailModel
                       isCollect:(BOOL)isCollect
                  selectSkuCount:(NSInteger)selectSkuCount;

/**
 * 快速购买下单统计
 */
+ (void)fastBugAnalytics:(ZFOrderCheckInfoDetailModel *)checkInfoModel;


/**
 * 统计穿搭展示
 */
+ (void)outfitsShowGoods:(ZFGoodsDetailOutfitsModel *)outfitsModel;

/**
* 统计穿搭点击
*/
+ (void)outfitsClickGoods:(ZFGoodsModel *)goodsModel
                outfitsId:(NSString *)tmpShowOutfitsId;

/**
* 统计穿搭加入购物车点击
*/
+ (void)outfitsClickGoods:(GoodsDetailModel *)detailModel
                goods_spu:(NSString *)goods_spu
                outfitsId:(NSString *)outfitsId;

@end
