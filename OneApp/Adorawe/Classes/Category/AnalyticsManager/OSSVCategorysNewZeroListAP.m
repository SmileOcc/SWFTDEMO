//
//  STLCategoryNewZeroListAOP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/17.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysNewZeroListAP.h"
#import "OSSVCategorysSpecialssCCell.h"

@implementation OSSVCategorysNewZeroListAP

- (void)after_baseViewChangePV:(NSDictionary *)params first:(BOOL)isFirst{
    if (!STLJudgeNSDictionary(params)) {
        return;
    }
    if (STLJudgeNSDictionary(params) && !STLIsEmptyString(params[@"specialId"]) && ![STLToString(params[@"specialId"]) isEqualToString:@"0"]) {
        
    }
    
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVCategorysSpecialssCCell class]]) {
        OSSVCategorysSpecialssCCell *speciallCell = (OSSVCategorysSpecialssCCell *)cell;
        
        OSSVThemeZeroPrGoodsModel *goodsModel = speciallCell.model;
        
        if (![goodsModel isMemberOfClass:[OSSVThemeZeroPrGoodsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goodsSn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goodsSn)];

        
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodsModel.goodsSn;
//        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceCategoryList sourceID:self.sourceKey];
        
        
        // 没有分类ID，分类name
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                    @"goods_sn":STLToString(goodsModel.goodsSn),
                                                                                    @"currency":@"USD",
                                                                                    @"cat_id":STLToString(goodsModel.cat_id)}];
        
        //数据GA埋点曝光 列表商品曝光
                       
                            // item
        NSMutableDictionary *item = [@{
          kFIRParameterItemID: STLToString(goodsModel.goods_sn),
          kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
          kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
          //产品规格
          kFIRParameterItemVariant: @"",
          kFIRParameterItemBrand: @"",
          kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
          kFIRParameterCurrency: @"USD",
          kFIRParameterQuantity: @(1)
        } mutableCopy];


        // Add items indexes
        item[kFIRParameterIndex] = @(indexPath.row+1);

        // Prepare ecommerce parameters
        NSMutableDictionary *itemList = [@{
          kFIRParameterItemListID: STLToString(goodsModel.cat_id),
          kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
          @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
          @"position": @"ProductList_RegularProduct"
        } mutableCopy];

        // Add items array
        itemList[kFIRParameterItems] = @[item];

        // Log view item list event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];

    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OSSVCategorysSpecialssCCell class]]) {
        OSSVCategorysSpecialssCCell *speciallCell = (OSSVCategorysSpecialssCCell *)cell;
        
        OSSVThemeZeroPrGoodsModel *goodModel = speciallCell.model;
        if (![goodModel isMemberOfClass:[OSSVThemeZeroPrGoodsModel class]]) {
            return;
        }
        //数据GA埋点曝光 列表商品 点击
        // item
        NSMutableDictionary *item = [@{
          kFIRParameterItemID: STLToString(goodModel.goods_sn),
          kFIRParameterItemName: STLToString(goodModel.goodsTitle),
          kFIRParameterItemCategory: STLToString(goodModel.cat_id),
          //产品规格
          kFIRParameterItemVariant: @"",
          kFIRParameterItemBrand: @"",
          kFIRParameterPrice: @([STLToString(goodModel.shop_price) doubleValue]),
          kFIRParameterCurrency: @"USD",
          kFIRParameterQuantity: @(1)
        } mutableCopy];

        // Add items indexes
        item[kFIRParameterIndex] = @(indexPath.row+1);

        // Prepare ecommerce parameters
        NSMutableDictionary *itemList = [@{
          kFIRParameterItemListID: STLToString(goodModel.cat_id),
          kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
          @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
          @"position": @"ProductList_RegularProduct"
        } mutableCopy];

        // Add items array
        itemList[kFIRParameterItems] = @[item];

        // Log select item event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
        
    }
}


- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"baseViewChangePV:first:" :
                             @"after_baseViewChangePV:first:",
                             };
    return params;
}
@end
