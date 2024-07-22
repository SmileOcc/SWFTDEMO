//
//  ZFCollectionGoodsAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionGoodsAnalyticsAOP.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

#import "ZFGoodsListItemCell.h"
#import "ZFCMSRecommendGoodsCCell.h"

@interface ZFCollectionGoodsAnalyticsAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;

@end

@implementation ZFCollectionGoodsAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFCollectionAnalyticsAOP dealloc");
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(ZFCollectionGoodsAnalyticsAOP.class);
        self.sourceType = ZFAppsflyerInSourceTypeWishListRecommend;
    }
    return self;
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {//收藏推荐商品
        ZFCMSRecommendGoodsCCell *baseCell = (ZFCMSRecommendGoodsCCell *)cell;
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
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceWishListRecommend];
    } else if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        
        ZFGoodsListItemCell *baseCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = baseCell.goodsModel;
        if (!goodsModel) {
            return;
        }
        if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
        goodsModel.af_rank = indexPath.row + 1;
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.sourceType AFparams:nil];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceWishList];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    ZFGoodsModel *goodsModel;
    if ([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {
        ZFCMSRecommendGoodsCCell *baseCell = (ZFCMSRecommendGoodsCCell *)cell;
        goodsModel = baseCell.goodsModel;
        if (!goodsModel) {
            return;
        }
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_recommend_name" : @"recommend_wishlist",
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"recommend_wishlist",    // 当前页面名称
                                          @"af_second_entrance" : @"recommend_wishilist"
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceWishListRecommend sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
            GIOGoodsNameEvar : @"recommend_wishlist",
            GIOFistEvar : GIOSourceAccount,
            GIOSndNameEvar : GIOSourceWishListRecommend
        }];
        
    } else if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        
        ZFGoodsListItemCell *baseCell = (ZFGoodsListItemCell *)cell;
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

- (void)after_requestPageData:(BOOL)firstPage {
    if (firstPage) {
        [[ZFAnalyticsExposureSet sharedInstance] removeAllObjectsAnalyticsId:self.idx];
    }
}

- (void)after_requestCMSCommenderData:(BOOL)firstPage {
    if (firstPage) {
        [[ZFAnalyticsExposureSet sharedInstance] removeAllObjectsAnalyticsId:self.idx];
    }
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"requestCMSCommenderData:":@"after_requestCMSCommenderData:",
                             @"requestPageData:":@"after_requestPageData:",
                             };
    return params;
}

- (NSMutableArray *)analyticsSet {
    if (!_analyticsSet) {
        _analyticsSet = [NSMutableArray array];
    }
    return _analyticsSet;
}

@end
