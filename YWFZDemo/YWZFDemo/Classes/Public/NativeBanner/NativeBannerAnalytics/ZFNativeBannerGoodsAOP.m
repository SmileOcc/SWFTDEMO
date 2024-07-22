//
//  ZFNativeBannerGoodsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/10/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeBannerGoodsAOP.h"
#import "ZFNativePlateGoodsModel.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"

@interface ZFNativeBannerGoodsAOP ()

@property (nonatomic, strong) NSMutableArray *historyAnalyticsList;

@end

@implementation ZFNativeBannerGoodsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataList = [[NSArray alloc] init];
    }
    return self;
}

-(void)after_collectionView:(UICollectionView *)collectionView
     cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id model = [self.dataList firstObject];
    NSUInteger index = 0;
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        index = indexPath.row;
    }
    if ([model isKindOfClass:[ZFNativePlateGoodsModel class]]) {
        index = indexPath.section;
    }
    if ([self.dataList count] <= index) {
        return;
    }
    model = self.dataList[index];
    
    ZFGoodsModel *goodsModel = nil;
    
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        goodsModel = (ZFGoodsModel *)model;
        if ([self.historyAnalyticsList containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.historyAnalyticsList addObject:ZFToString(goodsModel.goods_id)];
    }
    if ([model isKindOfClass:[ZFNativePlateGoodsModel class]]) {
        ZFNativePlateGoodsModel *plateGoodsModel = (ZFNativePlateGoodsModel *)model;
        goodsModel = plateGoodsModel.goodsArray[indexPath.section];
        if ([self.historyAnalyticsList containsObject:ZFToString(goodsModel.goods_id)]) {
            return;
        }
        [self.historyAnalyticsList addObject:ZFToString(goodsModel.goods_id)];
    }
    
    if (goodsModel) {
        NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.specialTitle];
        NSString *screenName = [NSString stringWithFormat:@"native_%@", self.specialTitle];
        
        //AF 统计
        [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:ZFAppsflyerInSourceTypePromotion sourceID:self.specialTitle];
        //GA 统计
        [ZFAnalytics showProductsWithProducts:@[goodsModel] position:1 impressionList:impression screenName:screenName event:@"load"];
        //GrowingIO 统计
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:@"原生专题"];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id model = self.dataList[indexPath.row];
    
    NSUInteger index = 0;
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        index = indexPath.row;
    }
    if ([model isKindOfClass:[ZFNativePlateGoodsModel class]]) {
        index = indexPath.section;
    }
    model = self.dataList[index];
    
    ZFGoodsModel *goodsModel = nil;
    
    if ([model isKindOfClass:[ZFGoodsModel class]]) {
        goodsModel = (ZFGoodsModel *)model;
    }
    if ([model isKindOfClass:[ZFNativePlateGoodsModel class]]) {
        ZFNativePlateGoodsModel *plateGoodsModel = (ZFNativePlateGoodsModel *)model;
        goodsModel = plateGoodsModel.goodsArray[indexPath.section];
    }
    
    //GA 统计
    NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGANativeList, self.specialTitle];
    [ZFAnalytics clickProductWithProduct:goodsModel position:1 actionList:impression];
    
    //GrowingIO 统计
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"原生专题" sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeOther,
        GIOGoodsNameEvar : @"native_activety"
    }];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"native_activety",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:cellForItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:cellForItemAtIndexPath:)),
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             };
    return params;
}

-(NSMutableArray *)historyAnalyticsList
{
    if (!_historyAnalyticsList) {
        _historyAnalyticsList = [[NSMutableArray alloc] init];
    }
    return _historyAnalyticsList;
}

@end
