//
//  ZFCarPiecingAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/10/25.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCarPiecingAnalyticsAOP.h"
#import "ZFGoodsListItemCell.h"
#import "ZFAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFGrowingIOAnalytics.h"

@interface ZFCarPiecingAnalyticsAOP()

@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, copy) NSString *impressionName;

@end

@implementation ZFCarPiecingAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.impressionName = @"carpiecing";
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    if (!ZFToString(_title).length) {
        return;
    }
    //把title解析出来
    NSArray *titleList = [_title componentsSeparatedByString:@"-"];
    if (ZFJudgeNSArray(titleList)) {
        self.impressionName = [titleList lastObject];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.goodsModel;
        if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
        NSString *impression = [NSString stringWithFormat:@"GACarPiecingList_%@", self.impressionName];
        [ZFAnalytics showProductsWithProducts:@[goodsModel] position:(int)indexPath.row impressionList:impression screenName:@"凑单页" event:@"load"];
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:ZFAppsflyerInSourceTypeCartPiecing AFparams:nil];
    }
}


-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.goodsModel;
        NSString *impression = [NSString stringWithFormat:@"GACarPiecingList_%@", self.impressionName];
        [ZFAnalytics clickProductWithProduct:goodsModel position:(int)indexPath.row actionList:impression];
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"additem_page",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeOther,
                                                   GIOGoodsNameEvar : @"recommend_coudan"
        }];
    }
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
//                             NSStringFromSelector(@selector(collectionView:cellForItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:cellForItemAtIndexPath:)),
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:"
                             };
    return params;
}

-(NSMutableArray *)analyticsSet
{
    if (!_analyticsSet) {
        _analyticsSet = [[NSMutableArray alloc] init];
    }
    return _analyticsSet;
}

@end
