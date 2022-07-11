//
//  OSSVAccountsHistoyAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2020/10/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountsHistoyAnalyseAP.h"

@implementation OSSVAccountsHistoyAnalyseAP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVHomeItemssCell class]]) {
        OSSVHomeItemssCell *goodsCell = (OSSVHomeItemssCell *)cell;
        CommendModel *goodModel = goodsCell.commendModel;
        
        if (![goodModel isMemberOfClass:[CommendModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goodsSn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goodsSn)];

        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goodsSn;
        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceHistory sourceID:self.sourceKey];
        
        
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                    @"url":@"",
                                                                                    @"goods_sn":STLToString(goodModel.goodsSn),
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
          @"position": @"ProductList_RegularProduct",
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
    
    if ([cell isKindOfClass:[OSSVHomeItemssCell class]]) {
        OSSVHomeItemssCell *goodsCell = (OSSVHomeItemssCell *)cell;
        CommendModel *goodModel = goodsCell.commendModel;
        
        if (![goodModel isMemberOfClass:[CommendModel class]]) {
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
                             };
    return params;
}

@end
