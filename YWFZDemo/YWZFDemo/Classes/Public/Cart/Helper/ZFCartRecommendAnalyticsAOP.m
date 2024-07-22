//
//  ZFCartRecommendAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/12/19.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCartRecommendAnalyticsAOP.h"
#import "ZFCarRecommendGoodsCell.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"

@interface ZFCartRecommendAnalyticsAOP ()

@property (nonatomic, strong) AFparams *currentAFParams;
@property (nonatomic, strong) NSMutableArray *analyticsSet;

@end

@implementation ZFCartRecommendAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.analyticsSet = [[NSMutableArray alloc] init];
        self.sourceType = ZFAppsflyerInSourceTypeCarRecommend;
    }
    return self;
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFCarRecommendGoodsCell class]]) {
        ZFCarRecommendGoodsCell *carCell = (ZFCarRecommendGoodsCell *)cell;
        ZFGoodsModel *goodsModel = carCell.goodsModel;
        if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
        // 统计
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel]
                                inSourceType:self.sourceType
                                    sourceID:@""
                                    aFparams:self.currentAFParams];
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceCartRecommend];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFCarRecommendGoodsCell class]]) {
        ZFCarRecommendGoodsCell *carCell = (ZFCarRecommendGoodsCell *)cell;
        ZFGoodsModel *goodsModel = carCell.goodsModel;
        // 谷歌统计
        [ZFAnalytics clickButtonWithCategory:@"Cart List Screen" actionName:@"Cart List Screen" label:@"Cart List Screen"];
        NSString *name = [NSString stringWithFormat:@"%@_%@", ZFGACarRecommendList, ZFToString(goodsModel.goods_id)];
        [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:name];
        
        // appflyer统计
        NSMutableDictionary *appsflyerParams = [NSMutableDictionary dictionary];
        appsflyerParams[@"af_content_id"] = ZFToString(goodsModel.goods_sn);
        appsflyerParams[@"af_spu_id"] = ZFToString(goodsModel.goods_spu);
        appsflyerParams[@"af_user_type"] = ZFToString([AccountManager sharedManager].af_user_type);
        
        NSString *recommendName = @"recommend_cartpage";
        NSString *pageName = @"cartpage";
        if (self.aopTpye == RecommendPageNullCart) {
            recommendName = @"recommend_nullcartpage";
            pageName = @"cartpage";
        } else if (self.aopTpye == RecommendPagePaysuccessView) {
            recommendName = @"recommend_purchasepage";
            pageName = @"pay_success";
        }
        appsflyerParams[@"af_recommend_name"] = recommendName;
        appsflyerParams[@"af_first_entrance"] = pageName;
        appsflyerParams[@"af_page_name"] = pageName;
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceCartRecommend sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
            GIOGoodsNameEvar : recommendName,
            GIOFistEvar : GIOSourceCartRecommend,
            GIOSndNameEvar : GIOSourceCartRecommend
        }];
    }
}

- (void)after_setDataArray:(NSArray<ZFGoodsModel *> *)dataArray afParams:(AFparams *)afParams
{
    self.currentAFParams = afParams;
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{@"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"setDataArray:afParams:" :
                                 @"after_setDataArray:afParams:"
                             };
    return params;
}

@end
