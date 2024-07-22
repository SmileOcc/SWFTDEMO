//
//  ZFAccountHistoryAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/8/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountHistoryAOP.h"
#import "ZFGoodsListItemCell.h"
#import "YWCFunctionTool.h"
#import "ZFGoodsModel.h"
#import "AccountManager.h"
#import "ZFGrowingIOAnalytics.h"

@interface ZFAccountHistoryAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;

@end

@implementation ZFAccountHistoryAOP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *productCell = (ZFGoodsListItemCell *)cell;
        if ([productCell.goodsModel isKindOfClass:[ZFGoodsModel class]]) {
            ZFGoodsModel *goodsModel = (ZFGoodsModel *)productCell.goodsModel;
            if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
                return;
            }
            [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
            goodsModel.af_rank = indexPath.row + 1;
            [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:ZFAppsflyerInSourceTypeAccountRecentviewedProduct AFparams:nil];
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceRecenty];
        }
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *productCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = (ZFGoodsModel *)productCell.goodsModel;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"recently_viewed",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceAccount sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeOther,
            GIOGoodsNameEvar : @"recommend_personnal_recentviewed",
            GIOFistEvar : GIOSourceAccount,
            GIOSndNameEvar : GIOSourceRecenty
        }];
    }
}

- (NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:willDisplayCell:forItemAtIndexPath:)),
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
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
