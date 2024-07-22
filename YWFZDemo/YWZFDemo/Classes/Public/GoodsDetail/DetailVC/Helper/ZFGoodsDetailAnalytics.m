//
//  ZFGoodsDetailAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "GoodsDetailModel.h"
#import "YWCFunctionTool.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFBranchAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFShareManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import "ZFGoodsDetailOutfitsModel.h"

@implementation ZFGoodsDetailAnalytics

/**
 * 统计优惠券点击
 */
+ (void)af_analyticsShowCoupon {
    NSString *ZFDetailShowCouponAFKey = @"productdetail_colletion_coupons";
    [ZFAnalytics appsFlyerTrackEvent:ZFDetailShowCouponAFKey
                          withValues:@{AFEventParamContentType : ZFDetailShowCouponAFKey}];
}

/**
 * 统计点击获取优惠券
 */
+ (void)af_growingIOGetCoupon:(NSString *)discounts {
    [ZFGrowingIOAnalytics ZFGrowingIOCouponGetSuccess:discounts
                                                 page:@"GoodsDetailCouponPage"];
}

/**
 * 统计查看购物车
 */
+ (void)af_analyticsShowCartBag {
    [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag"
                                        itemName:@"GoodsDetail_Bag"
                                     ContentType:@"Bag"
                                    itemCategory:@"Bag"];
}

// 统计退出商详页面
+ (void)af_analyticsExitProduct:(NSString *)goods_sn {
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_exit_product" withValues:@{
        @"af_content_type" : @"exit productdetail",
        @"af_content_id" : ZFToString(goods_sn)
    }];
}

/**
 * 统计点击评论
 */
+ (void)af_analyticsReviewClick:(NSString *)goods_sn {
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"More_Review_%@", goods_sn]
                                        itemName:@"Review"
                                     ContentType:@"Goods - Detail"
                                    itemCategory:@"Review"];
}

/**
 * 统计展示分享
 */
+ (void)af_analyticsShowShare:(NSString *)goods_sn {
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_GoodsDetail_Share_%@",goods_sn]
                                        itemName:@"GoodsDetail Share"
                                     ContentType:@"Share"
                                    itemCategory:@"Button"];
}

/**
 * 统计展示搭配购
 */
+ (void)af_analyticsShowCollocationBuy {
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_collocation_impression" withValues:@{}];
}

/**
 * FireBase统计计入商详
 */
+ (void)af_fireBaseShowDetail:(NSString *)goods_id {
    NSString *itemId = [NSString stringWithFormat:@"Click_GoodsDetail_Recommend_Goods_%@", goods_id];
    [ZFFireBaseAnalytics selectContentWithItemId:itemId
                                        itemName:@"GoodsDetail_Recommend"
                                     ContentType:@"Goods"
                                    itemCategory:@"Recommend_Goods"];
}

/**
 * 统计分享facebook, Message事件
 */
+ (void)af_analyticsShare:(ZFGoodsDetailViewController *)goodsDetailVC
                shareType:(ZFShareType)shareType
                 goods_sn:(NSString *)goods_sn
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    
    NSString *share_channel = [ZFShareManager fetchShareTypePlatform:shareType];
    if (ZFIsEmptyString(share_channel)) return;
    share_channel = [NSString stringWithFormat:@"Shared on %@", share_channel];
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goods_sn);
    valuesDic[AFEventParamContentType] = ZFToString(share_channel);
    valuesDic[@"af_country_code"] = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
    if (goodsDetailVC.deeplinkSource.length) {
        valuesDic[@"af_inner_mediasource"] = goodsDetailVC.deeplinkSource;
    } else {
        valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:goodsDetailVC.sourceType sourceID:goodsDetailVC.sourceID];
    }
    [ZFAnalytics appsFlyerTrackEvent:@"af_share" withValues:valuesDic];
}


/**
 * 商详主要信息接口请求成功时: AF统计代码
 */
+ (void)af_analysicsDetail:(ZFGoodsDetailViewController *)goodsDetailVC
            detailModel:(GoodsDetailModel *)detailModel
         selectSkuCount:(NSInteger)selectSkuCount
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return;
    
    [ZFFireBaseAnalytics scanGoodsWithGoodsModel:detailModel];
    [ZFAnalytics scanProductDetailWithProduct:detailModel screenName:@"Product Detail"];
    
    //用户点击查看商品
    NSMutableDictionary *valuesDic     = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]   = ZFToString(detailModel.goods_sn);
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[AFEventParamPrice]       = ZFToString(detailModel.shop_price);
    valuesDic[AFEventParamCurrency]    = @"USD";
    if (goodsDetailVC.deeplinkSource.length) {
        valuesDic[@"af_inner_mediasource"] = goodsDetailVC.deeplinkSource;
    }else{
        valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:goodsDetailVC.sourceType sourceID:goodsDetailVC.sourceID];
    }
    valuesDic[@"af_changed_size_or_color"] = (selectSkuCount > 0) ? @"1" : @"0";
    valuesDic[@"af_sort"]              = ZFToString(goodsDetailVC.analyticsSort);
    valuesDic[BigDataParams]           = [detailModel gainAnalyticsParams];
    valuesDic[@"af_rank"]              = @(goodsDetailVC.af_rank);
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
    //Branch
    [[ZFBranchAnalytics sharedManager] branchViewItemDetailWithProduct:detailModel];
    //GrowingIO商品详情查看
    [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
}

/**
 * 统计商品加入购物车事件
 */
+ (void)af_analysicsAddToBag:(ZFGoodsDetailViewController *)goodsDetailVC
                 detailModel:(GoodsDetailModel *)detailModel
              selectSkuCount:(NSInteger)selectSkuCount
                 fastBuyFlag:(BOOL)fastBuyFlag
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return;
    
    //添加商品至购物车事件统计
    NSString *goodsSN = detailModel.goods_sn;
    NSString *spuSN = @"";
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goodsSN;
    }
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
    valuesDic[@"af_spu_id"] = ZFToString(spuSN);
    valuesDic[AFEventParamPrice] = ZFToString(detailModel.shop_price);
    valuesDic[AFEventParamQuantity] = @"1";
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[@"af_content_category"] = ZFToString(detailModel.long_cat_name);
    valuesDic[AFEventParamCurrency] = @"USD";
    if (goodsDetailVC.deeplinkSource.length) {
        valuesDic[@"af_inner_mediasource"] = goodsDetailVC.deeplinkSource;
    }else{
        valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:goodsDetailVC.sourceType sourceID:goodsDetailVC.sourceID];
    }
    valuesDic[@"af_changed_size_or_color"] = (selectSkuCount > 0) ? @"1" : @"0";
    valuesDic[@"af_sort"]              = ZFToString(goodsDetailVC.analyticsSort);
    valuesDic[BigDataParams]           = @[[detailModel gainAnalyticsParams]];
    valuesDic[@"af_rank"]              = @(goodsDetailVC.af_rank);
    //V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
    valuesDic[@"af_purchase_way"]      = fastBuyFlag ? @"0" : @"1";
    
    //【af_add_to_bag】之前，要记得【af_view_product】show一下商品详情
    [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
    
    // 一键购买事件过来增加统计事件
    if (fastBuyFlag) {
        [ZFAnalytics appsFlyerTrackEvent:@"af_buy_it_now" withValues:valuesDic];
    }
    
    detailModel.buyNumbers = 1;
    //Branch
    [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:detailModel number:1];
    
    [ZFAnalytics addToCartWithProduct:detailModel fromProduct:YES];
    
    [ZFFireBaseAnalytics addToCartWithGoodsModel:detailModel];
    
    [ZFGrowingIOAnalytics ZFGrowingIOAddCart:detailModel];
}

/**
 * 点击商详推荐位商品统计
 */
+ (void)af_analysicsClickRecommend:(GoodsDetailSameModel *)model
                     detailGoodsId:(NSString *)detailGoodsId
{
    if (![model isKindOfClass:[GoodsDetailSameModel class]]) return;
    
    [ZFAnalytics clickButtonWithCategory:@"Detail" actionName:@"Product Detail - Recommand" label:@"Product Detail - Recommand"];
    NSString *name = [NSString stringWithFormat:@"%@_%@", ZFGAGoodsDetailRecommendList, detailGoodsId];
    [ZFAnalytics clickProductWithProduct:[self sameGoodsAdapterToGoodsModel:model] position:1 actionList:name];
    ZFGoodsModel *gioGoodsModel = [self sameGoodsAdapterToGoodsModel:model];
    gioGoodsModel.recommentType = GIORecommYour;
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:gioGoodsModel page:@"商品详情推荐位" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
        GIOGoodsNameEvar : @"recommend productdetail"
    }];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(gioGoodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(gioGoodsModel.goods_spu),
                                      @"af_recommend_name" : @"recommend productdetail",
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"goods_page",    // 当前页面名称
                                      @"af_second_entrance" : @"goods_page"
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                                               GIOGoodsNameEvar : @"recommend productdetail"
    }];
}

+ (ZFGoodsModel *)sameGoodsAdapterToGoodsModel:(GoodsDetailSameModel *)sameModel {
    if (sameModel.goods_id && sameModel.goods_title) {
        ZFGoodsModel *goodsModel = [ZFGoodsModel new];
        goodsModel.goods_id = sameModel.goods_id;
        goodsModel.goods_title = sameModel.goods_title;
        goodsModel.goods_sn = sameModel.goods_sn;
        goodsModel.cat_level_column = sameModel.cat_level_column;
        return goodsModel;
    }
    return nil;
}

/**
 * 商详主要信息接口请求成功时: GA统计代码
 */
+ (void)ga_analyticsDetail:(ZFGoodsDetailViewController *)goodsDetailVC
               detailModel:(GoodsDetailModel *)detailModel
{    
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return;
    if (!goodsDetailVC.analyticsProduceImpression) return;
    
    //occ v3.7.0hacker 添加 ok
    ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
    goodsModel.goods_sn = detailModel.goods_sn;
    goodsModel.goods_title = detailModel.goods_name;
    goodsModel.cat_name = detailModel.long_cat_name;
    
    [ZFAnalytics showProductsWithProducts:@[goodsModel]
                                 position:goodsDetailVC.analyticsProduceImpression.position
                           impressionList:ZFToString(goodsDetailVC.analyticsProduceImpression.impressionList)
                               screenName:ZFToString(goodsDetailVC.analyticsProduceImpression.screenName)
                                    event:ZFToString(goodsDetailVC.analyticsProduceImpression.event)];
    // 谷歌统计
    [ZFAnalytics clickCategoryProductWithProduct:goodsModel position:1 actionList:ZFToString(goodsDetailVC.analyticsProduceImpression.impressionList)];
}

/**
 * 商品详情推荐商品统计
 */
+ (ZFAnalyticsProduceImpression *)fetchRecommendAnalytics:(ZFGoodsDetailViewController *)goodsDetailVC
                                              detailModel:(GoodsDetailModel *)detailModel
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return nil;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return nil;
    if (detailModel.recommendModelArray.count == 0) return nil;
    
    NSMutableArray <ZFGoodsModel *> *goodsModelArray = [NSMutableArray new];
    for (int i = 0; i < detailModel.recommendModelArray.count; i++) {
        GoodsDetailSameModel *sameModel = detailModel.recommendModelArray[i];
        if (ZFIsEmptyString(sameModel.goods_sn)) continue;
        
        ZFGoodsModel *goodsModel = [ZFGoodsModel new];
        goodsModel.goods_id = sameModel.goods_id;
        goodsModel.goods_sn = sameModel.goods_sn;
        goodsModel.goods_title = sameModel.goods_title;
        goodsModel.cat_level_column = sameModel.cat_level_column;
        goodsModel.af_rank = i + 1; //+1的原因是统计需要从1开始
        [goodsModelArray addObject:goodsModel];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:@"商品详情推荐位"];
    }
    if (goodsModelArray.count == 0) return nil;
    
    // 推荐商品曝光统计
    [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray
                            inSourceType:ZFAppsflyerInSourceTypeGoodsDetail
                                AFparams:detailModel.af_recommend_params];//这里一定要用商详页面的
    // 谷歌统计
    ///这里区分一下，商品详情的推荐商品是从哪个商品的底部推荐购买的
    NSString *name = [NSString stringWithFormat:@"%@_%@", ZFGAGoodsDetailRecommendList, detailModel.goods_id];
    [ZFAnalytics showProductsWithProducts:goodsModelArray position:1 impressionList:name screenName:@"Product Detail" event:nil];
    
    //occ v3.7.0hacker 添加 ok
    return  [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                        impressionList:name
                                                            screenName:@"Product Detail"
                                                                 event:@""];
}

/**
 * 统计:商详页评论模块曝光
 * 统计:商详页评论列表页曝光
 */
+ (void)af_analyticsReview:(ZFGoodsDetailViewController *)goodsDetailVC
               detailModel:(GoodsDetailModel *)detailModel
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return;
    
    NSString *goodsSN = detailModel.goods_sn;
    if (ZFIsEmptyString(goodsSN)) return;
    
    NSString *af_analytics_key = @"af_view_product_review";
    
    NSString *spuSN = goodsSN;
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }
    NSMutableDictionary *valuesDic      = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]    = ZFToString(goodsSN);
    [ZFAnalytics appsFlyerTrackEvent:af_analytics_key withValues:valuesDic];
}

/**
 * 添加收藏统计
 */
+ (void)af_analyticsClickCollect:(ZFGoodsDetailViewController *)goodsDetailVC
                     detailModel:(GoodsDetailModel *)detailModel
                       isCollect:(BOOL)isCollect
                  selectSkuCount:(NSInteger)selectSkuCount
{
    if (![goodsDetailVC isKindOfClass:[ZFGoodsDetailViewController class]]) return;
    if (![detailModel isKindOfClass:[GoodsDetailModel class]]) return;
    
    // 收藏添加统计
    if (isCollect) {
        [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"GoodsDetail_Goods_%@", detailModel.goods_sn] itemName:@"Goods_Collection" ContentType:@"Goods_Collection" itemCategory:@"Button"];
        
        // 统计添加商品至收藏夹
        NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
        valuesDic[AFEventParamContentId] = ZFToString(detailModel.goods_sn);
        valuesDic[AFEventParamPrice] = ZFToString(detailModel.shop_price);
        valuesDic[AFEventParamContentType] = @"product";
        valuesDic[@"af_content_category"] = ZFToString(detailModel.long_cat_name);
        valuesDic[AFEventParamCurrency] = @"USD";
        if (goodsDetailVC.deeplinkSource.length) {
            valuesDic[@"af_inner_mediasource"] = goodsDetailVC.deeplinkSource;
        }else{
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:goodsDetailVC.sourceType
                                                                                   sourceID:goodsDetailVC.sourceID];
        }
        valuesDic[@"af_changed_size_or_color"] = (selectSkuCount > 0) ? @"1" : @"0";
        valuesDic[@"af_sort"]              = ZFToString(goodsDetailVC.analyticsSort);
        valuesDic[BigDataParams]           = @[[detailModel gainAnalyticsParams]];
        valuesDic[@"af_rank"]              = @(goodsDetailVC.af_rank);
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_add_to_wishlist" withValues:valuesDic];
        [ZFFireBaseAnalytics addCollectionWithGoodsModel:detailModel];
        // 谷歌统计
        // [ZFAnalytics clickButtonWithCategory:@"Detail" actionName:@"Product Detail - Favorites" label:@"Product Detail - Favorites"];
    } else {
        NSString *itemId = [NSString stringWithFormat:@"GoodsDetail_Goods_%@", detailModel.goods_sn];
        [ZFFireBaseAnalytics selectContentWithItemId:itemId
                                            itemName:@"Goods_Collection"
                                         ContentType:@"Goods_DesCollection"
                                        itemCategory:@"Button"];
    }
}

/**
 * 快速购买下单统计
 */
+ (void)fastBugAnalytics:(ZFOrderCheckInfoDetailModel *)model {
    if (![model isKindOfClass:[ZFOrderCheckInfoDetailModel class]]) return;
    
    ZFOrderManager *manager = [[ZFOrderManager alloc] init];
    NSString *goodsStr      = [manager appendGoodsSN:model];
    NSString *goodsPrices   = [manager appendGoodsPrice:model];
    NSString *goodsQuantity = [manager appendGoodsQuantity:model];
    
    //添加商品至购物车事件
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goodsStr);
    valuesDic[AFEventParamPrice] = ZFToString(goodsPrices);
    valuesDic[AFEventParamQuantity] = ZFToString(goodsQuantity);
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[AFEventParamCurrency] = @"USD";
    [ZFAnalytics appsFlyerTrackEvent:@"af_process_to_pay" withValues:valuesDic];
    [ZFFireBaseAnalytics beginCheckOutWithGoodsInfo:model];
    //GrowingIO 统计
    [ZFGrowingIOAnalytics ZFGrowingIOCartCheckOut:model];
}

/**
* 统计穿搭展示
*/
+ (void)outfitsShowGoods:(ZFGoodsDetailOutfitsModel *)outfitsModel
{
    if (outfitsModel.hasStatisticsShowGoods)return;
    outfitsModel.hasStatisticsShowGoods = YES;
    
    [outfitsModel.goodsModelArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.af_rank = idx + 1;
    }];
    [ZFAppsflyerAnalytics trackGoodsList:outfitsModel.goodsModelArray
                            inSourceType:ZFAppsflyerInSourceTypeDetailOutfits
                                sourceID:outfitsModel.outfitsId];
}

/**
* 统计穿搭点击
*/
+ (void)outfitsClickGoods:(ZFGoodsModel *)goodsModel
                outfitsId:(NSString *)tmpShowOutfitsId {
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeOther,
                                               GIOGoodsNameEvar : [NSString stringWithFormat:@"product_detail_outfits_%@", tmpShowOutfitsId]
    }];
    
    NSString *af_user_type = [AccountManager sharedManager].af_user_type;
    NSString *spuSN = nil;
    if (goodsModel.goods_sn.length > 7) {
        spuSN = [goodsModel.goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goodsModel.goods_sn;
    }
    
    NSDictionary *appsflyerParams = @{@"af_content_id"  : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id"      : ZFToString(spuSN),
                                      @"af_user_type"   : ZFToString(af_user_type),
                                      @"af_page_name"   : @"goodsDetail",
                                      @"af_first_entrance" : @"product_detail_outfits" };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
}

/**
* 统计穿搭点击
*/
+ (void)outfitsClickGoods:(GoodsDetailModel *)detailModel
                goods_spu:(NSString *)goods_spu
                outfitsId:(NSString *)tmpShowOutfitsId
{
    //用户点击查看商品
    NSMutableDictionary *viewDict     = [NSMutableDictionary dictionary];
    viewDict[AFEventParamContentId]   = ZFToString(detailModel.goods_sn);
    viewDict[AFEventParamContentType] = @"product";
    viewDict[AFEventParamPrice]       = ZFToString(detailModel.shop_price);
    viewDict[AFEventParamCurrency]    = @"USD";
    viewDict[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeDetailOutfits sourceID:nil];
    viewDict[@"af_changed_size_or_color"] = @"1";
    viewDict[BigDataParams]           = [detailModel gainAnalyticsParams];
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:viewDict];
    [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
    
    //用户点击加购商品
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]    = ZFToString(detailModel.goods_sn);
    valuesDic[@"af_spu_id"]             = ZFToString(goods_spu);
    valuesDic[AFEventParamPrice]        = ZFToString(detailModel.shop_price);
    valuesDic[AFEventParamQuantity]     = @"1";
    valuesDic[AFEventParamContentType]  = @"product";
    valuesDic[@"af_content_category"]   = ZFToString(detailModel.long_cat_name);
    valuesDic[AFEventParamCurrency]     = @"USD";
    valuesDic[@"af_inner_mediasource"]  = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeDetailOutfits sourceID:tmpShowOutfitsId];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]               = @[[detailModel gainAnalyticsParams]];
    valuesDic[@"af_purchase_way"]           = @"1";
    
    [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
    [ZFGrowingIOAnalytics ZFGrowingIOAddCart:detailModel];
}

@end
