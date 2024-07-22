//
//  ZFAccountGoodsListViewAop.m
//  ZZZZZ
//
//  Created by YW on 2019/11/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountGoodsListViewAop.h"
#import "YWCFunctionTool.h"
#import "ZFProductCCell.h"
#import "ZFAccountBannerCCell.h"
#import "ZFAccountCategoryCCell.h"
#import "ZFAccountDetailTextCCell.h"

#import "ZFGrowingIOAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"

#import "AccountManager.h"
#import "ZFGoodsModel.h"

#import "ZFAccountProductCCell.h"
#import "ZFAccountCategorySectionModel.h"

@interface ZFAccountGoodsListViewAop ()
@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
@property (nonatomic, copy) NSString *af_first_entrance;
@end

@implementation ZFAccountGoodsListViewAop

- (instancetype)initAopWithSourceType:(ZFAppsflyerInSourceType)sourceType
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType;
        self.analyticsSet = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)gainCurrentAopClass:(id)currentAopClass
{
    self.currentController = currentAopClass;
    
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFAccountViewController540"]) {
    }
}

- (void)after_resetPageIndexToFirst
{
    [self.analyticsSet removeAllObjects];
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFAccountProductCCell class]]) {
        
        ZFAccountProductCCell *productCell = (ZFAccountProductCCell *)cell;
        if ([productCell.goodsModel isKindOfClass:[ZFGoodsModel class]]) {
            ZFGoodsModel *goodsModel = (ZFGoodsModel *)productCell.goodsModel;
            if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
                return;
            }
            [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
            goodsModel.af_rank = indexPath.row + 1;
            [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.sourceType AFparams:nil];
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceAccountRecommend];
        }
    }
}

// appflyer统计
-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[ZFAccountProductCCell class]]) {
        
        ZFAccountProductCCell *productCell = (ZFAccountProductCCell *)cell;
        if (![productCell.goodsModel isKindOfClass:[ZFGoodsModel class]])return;
        ZFGoodsModel *goodsModel = productCell.goodsModel;
        
        if (self.sourceType == ZFAppsflyerInSourceTypeSerachRecommendPersonal) {
            NSDictionary *appsflyerParams = @{
                @"af_content_id"    : ZFToString(goodsModel.goods_sn),
                @"af_spu_id"        : ZFToString(goodsModel.goods_spu),
                @"af_recommend_name": @"recommend_personal",
                @"af_user_type"     : ZFToString([AccountManager sharedManager].af_user_type),
                @"af_page_name"     : @"account_page",
                @"af_first_entrance": @"account_page"
            };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
            
            [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceAccountRecommend sourceParams:@{
                GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                GIOGoodsNameEvar : @"recommend_personal",
                GIOFistEvar : GIOSourceAccount,
                GIOSndNameEvar : GIOSourceAccountRecommend
            }];
            
        } else if (self.sourceType == ZFAppsflyerInSourceTypeAccountRecentviewedProduct) {
            NSDictionary *appsflyerParams = @{
                @"af_content_id"    : ZFToString(goodsModel.goods_sn),
                @"af_spu_id"        : ZFToString(goodsModel.goods_spu),
                @"af_user_type"     : ZFToString([AccountManager sharedManager].af_user_type),
                @"af_page_name"     : @"account_page",    // 当前页面名称
                @"af_first_entrance": @"recently_viewed"
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
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
        NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:willDisplayCell:forItemAtIndexPath:)),
        
        NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
            NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
        
        @"resetPageIndexToFirst" : @"after_resetPageIndexToFirst",
    };
    return params;
}

@end
