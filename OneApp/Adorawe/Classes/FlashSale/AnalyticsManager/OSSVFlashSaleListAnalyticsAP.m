//
//  OSSVFlashSaleListAnalyticsAP.m
// XStarlinkProject
//
//  Created by odd on 2021/3/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFlashSaleListAnalyticsAP.h"

@implementation OSSVFlashSaleListAnalyticsAP


- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVFlashSaleCell class]]) {
        OSSVFlashSaleCell *goodsCell = (OSSVFlashSaleCell *)cell;
        
        OSSVFlashSaleGoodsModel *goodModel = goodsCell.model;
        if (![goodModel isMemberOfClass:[OSSVFlashSaleGoodsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        // 没有分类id
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                    @"goods_sn":STLToString(goodModel.goods_sn),
                                                                                    @"currency":@"USD",
                                                                                    @"cat_id":STLToString(goodModel.cat_id)}];
        
        //GA埋点曝光 列表商品曝光
                       
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

        // Log view item list event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
        
    } else if([cell isKindOfClass:[OSSVFlashSaleNotStartCell class]]) {
        
        OSSVFlashSaleNotStartCell *goodsCell = (OSSVFlashSaleNotStartCell *)cell;
        OSSVFlashSaleGoodsModel *goodModel = goodsCell.model;
        if (![goodModel isMemberOfClass:[OSSVFlashSaleGoodsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        // 没有分类id
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                    @"goods_sn":STLToString(goodModel.goods_sn),
                                                                                    @"currency":@"USD",
                                                                                    @"cat_id":STLToString(goodModel.cat_id)}];
        
        //数据GA埋点曝光 列表商品曝光
                       
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

        // Log view item list event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[OSSVFlashSaleCell class]]) {
        OSSVFlashSaleCell *goodsCell = (OSSVFlashSaleCell *)cell;
        
        OSSVFlashSaleGoodsModel *goodModel = goodsCell.model;
        if ([goodModel isMemberOfClass:[OSSVFlashSaleGoodsModel class]]) {
            
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

    }  else if([cell isKindOfClass:[OSSVFlashSaleNotStartCell class]]) {
        
        OSSVFlashSaleNotStartCell *goodsCell = (OSSVFlashSaleNotStartCell *)cell;
        OSSVFlashSaleGoodsModel *goodModel = goodsCell.model;
        if ([goodModel isMemberOfClass:[OSSVFlashSaleGoodsModel class]]) {
            
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
