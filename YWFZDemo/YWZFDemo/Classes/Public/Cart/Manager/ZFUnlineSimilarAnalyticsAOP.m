//
//  ZFUnlineSimilarAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/5/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFUnlineSimilarAnalyticsAOP.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFAnalytics.h"

#import "ZFGoodsListItemCell.h"


@interface ZFUnlineSimilarAnalyticsAOP ()

@property (nonatomic, strong) NSMutableArray            *goodsAnalyticsSet;

@end

@implementation ZFUnlineSimilarAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFUnlineSimilarAnalytics dealloc");
}


-(instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.goodsModel;
        if ([self.goodsAnalyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:ZFToString(goodsModel.goods_id)];
        
        //Appsflyer 统计
        goodsModel.af_rank = indexPath.row + 1;
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.sourceType sourceID:@""];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGoodsListItemCell class]]) {
        ZFGoodsListItemCell *goodsCell = (ZFGoodsListItemCell *)cell;
        ZFGoodsModel *goodsModel = goodsCell.goodsModel;
  
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : ZFToString(self.page),    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    }
}


- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             };
    return params;
}

@end
