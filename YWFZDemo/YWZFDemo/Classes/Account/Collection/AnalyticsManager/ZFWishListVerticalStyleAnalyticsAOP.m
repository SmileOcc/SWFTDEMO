//
//  ZFWishListVerticalStyleAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/7/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWishListVerticalStyleAnalyticsAOP.h"

#import "YWCFunctionTool.h"
#import "Constants.h"

#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFBranchAnalytics.h"

#import "ZFWishListVerticalStyleCell.h"

@interface ZFWishListVerticalStyleAnalyticsAOP ()

@end

@implementation ZFWishListVerticalStyleAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFWishListVerticalStyleAnalyticsAOP dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(self.class);
        self.sourceType = ZFAppsflyerInSourceTypeWishListSourceMedia;
    }
    return self;
}

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFWishListVerticalStyleCell class]]) {//收藏推荐商品
        ZFWishListVerticalStyleCell *baseCell = (ZFWishListVerticalStyleCell *)cell;
        ZFGoodsModel *goodsModel = baseCell.goodsModel;
        if (!goodsModel) {
            return;
        }
        
        ZFAnalyticsExposureSet *recentSet = [ZFAnalyticsExposureSet sharedInstance];
        if ([recentSet containsObject:ZFToString(goodsModel.goods_id) analyticsId:self.idx] || ZFIsEmptyString(goodsModel.goods_id)) {
            return;
        }
        [recentSet addObject:ZFToString(goodsModel.goods_id) analyticsId:self.idx];
        goodsModel.af_rank = indexPath.row + 1;;
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.sourceType AFparams:nil];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceWishList];
    }
}

- (void)after_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ZFGoodsModel *goodsModel;
    if ([cell isKindOfClass:[ZFWishListVerticalStyleCell class]]) {
        ZFWishListVerticalStyleCell *baseCell = (ZFWishListVerticalStyleCell *)cell;
        goodsModel = baseCell.goodsModel;
        if (!goodsModel) {
            return;
        }
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"mycollection_page",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceWishList sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeOther,
            GIOGoodsNameEvar : @"recommend_wishlist",
            GIOFistEvar : GIOSourceAccount,
            GIOSndNameEvar : GIOSourceWishList
        }];
    }
}

- (void)after_requestPageData:(BOOL)firstPage
{
    if (firstPage) {
        [[ZFAnalyticsExposureSet sharedInstance] removeAllObjectsAnalyticsId:self.idx];
    }
}

- (void)after_handlerAddToBagSuccess:(GoodsDetailModel *)model
{
    //添加商品至购物车事件统计
    NSString *goodsSN = model.goods_sn;
    NSString *spuSN = @"";
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goodsSN;
    }
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
    valuesDic[@"af_spu_id"] = ZFToString(spuSN);
    valuesDic[AFEventParamPrice] = ZFToString(model.shop_price);
    valuesDic[AFEventParamQuantity] = @"1";
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[@"af_content_category"] = ZFToString(model.long_cat_name);
    valuesDic[AFEventParamCurrency] = @"USD";
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeWishListSourceMedia sourceID:nil];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]           = @[[model gainAnalyticsParams]];
    
    //V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
    valuesDic[@"af_purchase_way"]      = @"1";
    
    [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
    
    model.buyNumbers = 1;
    [ZFAnalytics addToCartWithProduct:model fromProduct:YES];
    [ZFFireBaseAnalytics addToCartWithGoodsModel:model];
    //Branch
    [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:model number:1];
    [ZFGrowingIOAnalytics ZFGrowingIOAddCart:model];
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)) :
                                 @"after_tableView:willDisplayCell:forRowAtIndexPath:",
                             NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_tableView:didSelectRowAtIndexPath:)),
                             @"requestPageData:" :
                                 @"after_requestPageData:",
                             @"handlerAddToBagSuccess:" :
                                 @"after_handlerAddToBagSuccess:"
                             };
    return params;
}

@end
