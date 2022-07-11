//
//  OSSVSearchResultAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchResultAnalyseAP.h"

@interface OSSVSearchResultAnalyseAP ()

@end

@implementation OSSVSearchResultAnalyseAP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVHomeItemssCell class]]) {
        OSSVHomeItemssCell *goodsCell = (OSSVHomeItemssCell *)cell;
        OSSVHomeGoodsListModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVHomeGoodsListModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goods_sn;
        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceSearchResult sourceID:self.sourceKey];
        
//        NSDictionary *sensorDic = @{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceSearchResult sourceID:self.sourceKey],
//                                    @"url":STLToString(self.sourceKey),
//                                    @"goods_sn":STLToString(goodModel.goods_sn),
//                                    @"currency":@"USD",
//                                    @"cat_id":STLToString(goodModel.cat_id),
//                                    @"key_word": STLToString(self.searchModel.searchKey),
//                                    @"position_number":@(indexPath.row + 1),
//                                    @"third_part_id":STLToString(self.searchModel.btm_sid),
//        };
        
        NSDictionary *sensorDic = @{kAnalyticsAction:STLToString(self.sourecDic[kAnalyticsAction]),
                                    kAnalyticsUrl:STLToString(self.sourecDic[kAnalyticsUrl]),
                                    @"goods_sn":STLToString(goodModel.goods_sn),
                                    @"currency":@"USD",
                                    @"cat_id":STLToString(goodModel.cat_id),
                                    @"position_number":@(indexPath.row + 1),
                                    kAnalyticsKeyWord: STLToString(self.sourecDic[kAnalyticsKeyWord]),
                                    kAnalyticsThirdPartId:STLToString(self.sourecDic[kAnalyticsThirdPartId]),
                                    };

        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:sensorDic];
        
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

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OSSVHomeItemssCell class]]) {
        
        OSSVHomeItemssCell *goodsCell = (OSSVHomeItemssCell *)cell;
        OSSVHomeGoodsListModel *goodModel = goodsCell.model;
        
        if ([goodModel isMemberOfClass:[OSSVHomeGoodsListModel class]]) {
            
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
